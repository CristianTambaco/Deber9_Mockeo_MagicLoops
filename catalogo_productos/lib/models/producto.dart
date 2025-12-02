// Este archivo define la estructura de un producto.

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
  });
}

// Datos de ejemplo para el taller
List<Producto> productosEjemplo = [
  Producto(
    id: '1',
    nombre: 'Laptop Pro',
    descripcion: 'Laptop de alto rendimiento',
    precio: 1299.99,
    imagenUrl: 'laptop',
    categoria: 'Electrónica',
  ),
  Producto(
    id: '2',
    nombre: 'Auriculares BT',
    descripcion: 'Auriculares inalámbricos',
    precio: 89.99,
    imagenUrl: 'headphones',
    categoria: 'Electrónica',
  ),
  Producto(
    id: '3',
    nombre: 'Smartwatch',
    descripcion: 'Reloj inteligente deportivo',
    precio: 249.99,
    imagenUrl: 'watch',
    categoria: 'Electrónica',
  ),
  Producto(
    id: '4',
    nombre: 'Cámara Digital',
    descripcion: 'Cámara profesional 4K',
    precio: 599.99,
    imagenUrl: 'camera',
    categoria: 'Fotografía',
  ),
  Producto(
    id: '5',
    nombre: 'Teclado Mecánico',
    descripcion: 'Teclado gaming RGB',
    precio: 129.99,
    imagenUrl: 'keyboard',
    categoria: 'Accesorios',
  ),
  Producto(
    id: '6',
    nombre: 'Mouse Inalámbrico',
    descripcion: 'Mouse ergonómico',
    precio: 49.99,
    imagenUrl: 'mouse',
    categoria: 'Accesorios',
  ),
];
