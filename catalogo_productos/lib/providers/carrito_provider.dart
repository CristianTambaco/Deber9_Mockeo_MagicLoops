import 'package:flutter/foundation.dart';
import 'package:catalogo_productos/models/carrito_item.dart';
import 'package:catalogo_productos/models/producto.dart';
import 'package:catalogo_productos/services/carrito_service.dart';

class CarritoProvider with ChangeNotifier {
  final CarritoService _service = CarritoService();

  // Nuevo: Estado de carga
  bool? _isLoading; // Ahora puede ser null
  bool get isLoading => _isLoading ?? false; // Si es null, devuelve false

  List<CarritoItem> get items => _service.obtenerItems();
  Map<String, double> get totales => _service.calcularTotales();

  Future<void> _runWithLoading(Future<void> Function() operation) async {
    try {
      _isLoading = true;
      notifyListeners();
      await operation();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarProducto(Producto producto, int cantidad) async {
    await _runWithLoading(() => _service.agregarProducto(producto, cantidad));
  }

  Future<void> eliminarProducto(String productoId) async {
    await _runWithLoading(() => _service.eliminarProducto(productoId));
  }

  Future<void> actualizarCantidad(String productoId, int nuevaCantidad) async {
    await _runWithLoading(() => _service.actualizarCantidad(productoId, nuevaCantidad));
  }

  Future<void> vaciarCarrito() async {
    await _runWithLoading(() => _service.vaciarCarrito());
  }
}