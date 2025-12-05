import 'dart:async';
import 'dart:math';
import 'package:catalogo_productos/models/carrito_item.dart';
import 'package:catalogo_productos/models/producto.dart';

class CarritoService {
  final List<CarritoItem> _items = [];
  static const int maxStock = 10;
  static const double impuestoPorcentaje = 0.12;
  static const double descuentoPorcentaje = 0.10;
  static const double umbralDescuento = 100.0;

  // Simulación de error aleatorio (20%)
  bool _debeFallar() {
    return Random().nextDouble() < 0.2;
  }

  Future<void> _simularDelay() async {
    await Future.delayed(Duration(seconds: Random().nextInt(2) + 1));
  }

  Future<bool> agregarProducto(Producto producto, int cantidad) async {
    await _simularDelay();
    if (_debeFallar()) {
      final errores = [
        'Stock insuficiente',
        'Error de conexión',
        'Producto no disponible',
        'Sesión expirada'
      ];
      throw Exception(errores[Random().nextInt(errores.length)]);
    }

    if (cantidad <= 0) {
      throw Exception('La cantidad debe ser mayor a 0');
    }

    if (cantidad > maxStock) {
      throw Exception('Stock insuficiente');
    }

    final itemExistente = _items.firstWhere(
      (item) => item.producto.id == producto.id,
      orElse: () => CarritoItem(producto: producto, cantidad: 0),
    );

    if (itemExistente.cantidad > 0) {
      final nuevaCantidad = itemExistente.cantidad + cantidad;
      if (nuevaCantidad > maxStock) {
        throw Exception('Stock insuficiente');
      }
      itemExistente.cantidad = nuevaCantidad;
    } else {
      _items.add(CarritoItem(producto: producto, cantidad: cantidad));
    }

    return true;
  }

  Future<bool> eliminarProducto(String productoId) async {
    await _simularDelay();
    if (_debeFallar()) {
      throw Exception('Error de conexión');
    }

    _items.removeWhere((item) => item.producto.id == productoId);
    return true;
  }

  Future<bool> actualizarCantidad(String productoId, int nuevaCantidad) async {
    await _simularDelay();
    if (_debeFallar()) {
      throw Exception('Error de conexión');
    }

    if (nuevaCantidad < 1) {
      throw Exception('La cantidad debe ser al menos 1');
    }
    if (nuevaCantidad > maxStock) {
      throw Exception('Stock insuficiente');
    }

    final item = _items.firstWhere(
      (item) => item.producto.id == productoId,
      orElse: () => throw Exception('Producto no encontrado'),
    );

    item.cantidad = nuevaCantidad;
    return true;
  }

  List<CarritoItem> obtenerItems() {
    return List.unmodifiable(_items);
  }

  Future<bool> vaciarCarrito() async {
    await _simularDelay();
    if (_debeFallar()) {
      throw Exception('Error de conexión');
    }

    _items.clear();
    return true;
  }

  Map<String, double> calcularTotales() {
    double subtotal = 0;
    for (var item in _items) {
      subtotal += item.producto.precio * item.cantidad;
    }

    double descuento = subtotal > umbralDescuento ? subtotal * descuentoPorcentaje : 0;
    double impuestos = (subtotal - descuento) * impuestoPorcentaje;
    double total = subtotal - descuento + impuestos;

    return {
      'subtotal': subtotal,
      'descuento': descuento,
      'impuestos': impuestos,
      'total': total,
    };
  }
}