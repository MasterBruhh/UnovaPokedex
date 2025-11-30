import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/region_config.dart';
import '../../domain/entities/map_area.dart';
import '../../data/parsers/map_parser.dart';
import '../widgets/location_info_dialog.dart';

/// Widget genérico para visualizar mapas interactivos de regiones Pokémon
/// 
/// Características:
/// - Zoom y pan con InteractiveViewer
/// - Detección de toques en áreas definidas
/// - Escala dinámica adaptada a cada mapa
/// - Soporte para orientación portrait y landscape
class InteractiveMapPage extends ConsumerStatefulWidget {
  /// Nombre de la región a mostrar (en minúsculas)
  final String regionName;

  const InteractiveMapPage({
    super.key,
    required this.regionName,
  });

  @override
  ConsumerState<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends ConsumerState<InteractiveMapPage> {
  /// Configuración de la región actual
  RegionConfig? _config;
  
  /// Áreas interactivas cargadas del archivo de datos
  List<MapArea> _mapAreas = [];
  
  /// Estado de carga de los datos
  bool _isLoading = true;
  
  /// Error si no se encuentra la región
  String? _error;
  
  /// Controlador para transformaciones (zoom/pan)
  final TransformationController _transformationController =
      TransformationController();
  
  /// Key para acceder al RenderBox de la imagen
  final GlobalKey _imageKey = GlobalKey();
  
  /// Tamaño actual del viewport
  Size? _viewportSize;
  
  /// Último tamaño del viewport (para detectar cambios de orientación)
  Size? _lastViewportSize;

  /// Flag para aplicar escala inicial solo una vez
  bool _initialScaleApplied = false;
  
  /// Escala mínima permitida (sin bordes negros)
  double _minScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeRegion();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Inicializa la configuración de la región
  void _initializeRegion() {
    final config = RegionConfig.fromName(widget.regionName);
    if (config == null) {
      setState(() {
        _error = 'Region "${widget.regionName}" not found';
        _isLoading = false;
      });
      return;
    }
    
    _config = config;
    _loadMapData();
  }

  /// Carga las áreas interactivas desde el archivo de datos
  Future<void> _loadMapData() async {
    if (_config == null) return;
    
    try {
      final areas = await MapParser.parseMapFile(_config!.mapDataPath);
      
      if (mounted) {
        setState(() {
          _mapAreas = areas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading map: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ${_config!.name} map: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Aplica la escala inicial adaptada al mapa y viewport
  void _applyInitialScaleIfNeeded(BoxConstraints constraints) {
    if (_initialScaleApplied || _isLoading || _config == null) return;
    
    final double viewportWidth = constraints.maxWidth;
    final double viewportHeight = constraints.maxHeight;
    _viewportSize = Size(viewportWidth, viewportHeight);
    _lastViewportSize = _viewportSize;

    // Calcular escalas para ancho y alto
    final double scaleX = viewportWidth / _config!.originalWidth;
    final double scaleY = viewportHeight / _config!.originalHeight;
    
    // Estrategia de escala según orientación del mapa
    final double coverScale = _config!.isVertical
        ? scaleX // Mapas verticales: escalar por ancho
        : (scaleX > scaleY ? scaleX : scaleY); // Mapas horizontales: cover
    
    _minScale = coverScale;

    // Escala inicial con zoom extra
    final double initialScale = coverScale * 1.4;
    final double scaledWidth = _config!.originalWidth * initialScale;
    final double scaledHeight = _config!.originalHeight * initialScale;

    // Centrar la imagen
    final double translateX = (viewportWidth - scaledWidth) / 2;
    final double translateY = (viewportHeight - scaledHeight) / 2;

    final matrix = Matrix4.identity();
    matrix.setTranslationRaw(translateX, translateY, 0.0);
    matrix.multiply(Matrix4.diagonal3Values(initialScale, initialScale, 1.0));
    _transformationController.value = matrix;
    
    _initialScaleApplied = true;
  }

  /// Aplica una escala específica con límites y ajuste de traslación
  void _applyScale(double targetScale) {
    if (_config == null) return;
    
    // Clampear escala dentro de límites permitidos
    final double clampedScale = targetScale.clamp(_minScale, _minScale * 1.5);
    
    // Obtener traslación actual
    final Matrix4 current = _transformationController.value;
    final translation = current.getTranslation();
    double tx = translation.x;
    double ty = translation.y;
    
    // Ajustar traslación para evitar bordes blancos
    if (_viewportSize != null) {
      final double vw = _viewportSize!.width;
      final double vh = _viewportSize!.height;
      final double scaledWidth = _config!.originalWidth * clampedScale;
      final double scaledHeight = _config!.originalHeight * clampedScale;
      
      // Clampear para que la imagen siempre cubra el viewport
      tx = tx.clamp(vw - scaledWidth, 0.0);
      ty = ty.clamp(vh - scaledHeight, 0.0);
      
      // En escala mínima para mapas verticales, forzar centrado horizontal
      if (clampedScale == _minScale && _config!.isVertical) {
        tx = 0.0;
      }
    }
    
    final matrix = Matrix4.identity();
    matrix.setTranslationRaw(tx, ty, 0.0);
    matrix.multiply(Matrix4.diagonal3Values(clampedScale, clampedScale, 1.0));
    _transformationController.value = matrix;
  }

  /// Maneja el evento de tap en el mapa
  void _handleTapOnMap(TapDownDetails details) {
    if (_config == null) return;

    // Obtener el RenderBox de la imagen
    final RenderBox? renderBox = 
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) {
      return;
    }

    // Convertir posición global a local
    final Offset globalPosition = details.globalPosition;
    final Offset localPosition = renderBox.globalToLocal(globalPosition);
    final Size imageSize = renderBox.size;

    // Calcular coordenadas normalizadas (0-1)
    final double normalizedX = localPosition.dx / imageSize.width;
    final double normalizedY = localPosition.dy / imageSize.height;

    // Convertir a coordenadas de la imagen original
    final double x = normalizedX * _config!.originalWidth;
    final double y = normalizedY * _config!.originalHeight;

    // Verificar que las coordenadas estén dentro del rango válido
    if (x < 0 || x > _config!.originalWidth || 
        y < 0 || y > _config!.originalHeight) {
      return;
    }

    // Buscar el área que contiene este punto
    final area = MapParser.findAreaAtPoint(_mapAreas, x, y);

    if (area != null) {
      _showLocationInfo(area);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No location found at (${x.toStringAsFixed(0)}, ${y.toStringAsFixed(0)})'
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  /// Muestra el diálogo con información de la ubicación
  void _showLocationInfo(MapArea area) {
    if (_config == null) return;
    
    showDialog(
      context: context,
      builder: (context) => LocationInfoDialog(
        area: area,
        regionName: _config!.name,
      ),
    );
  }

  /// Muestra el diálogo de ayuda
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use'),
        content: const Text(
          'Pan (drag) to move around the map.\n'
          'Pinch to zoom in/out.\n'
          'Tap locations to view their names.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar error si la región no existe
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text('${_config?.name ?? 'Loading'} Region'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Loading ${_config?.name ?? ''} map...'),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Detectar cambios de orientación/tamaño
                if (_lastViewportSize == null ||
                    (_lastViewportSize!.width - constraints.maxWidth).abs() > 1 ||
                    (_lastViewportSize!.height - constraints.maxHeight).abs() > 1) {
                  _initialScaleApplied = false;
                }
                
                // Aplicar escala inicial después del primer frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _applyInitialScaleIfNeeded(constraints);
                });
                
                return SizedBox.expand(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: _minScale,
                    maxScale: _minScale * 2.2,
                    boundaryMargin: EdgeInsets.zero,
                    constrained: false,
                    panEnabled: true,
                    scaleEnabled: true,
                    clipBehavior: Clip.hardEdge,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: _handleTapOnMap,
                      child: SizedBox(
                        width: _config!.originalWidth,
                        height: _config!.originalHeight,
                        child: Image.asset(
                          _config!.mapImagePath,
                          key: _imageKey,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade800,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 64,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Map image not found',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: _isLoading || _config == null
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in_${_config!.name}',
                  mini: true,
                  onPressed: () {
                    final currentScale = 
                        _transformationController.value.getMaxScaleOnAxis();
                    _applyScale(currentScale * 1.25);
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_out_${_config!.name}',
                  mini: true,
                  onPressed: () {
                    final currentScale = 
                        _transformationController.value.getMaxScaleOnAxis();
                    _applyScale(currentScale / 1.25);
                  },
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
    );
  }
}
