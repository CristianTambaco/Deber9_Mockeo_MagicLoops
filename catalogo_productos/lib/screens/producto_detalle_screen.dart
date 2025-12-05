import 'package:flutter/material.dart';
import '../models/producto.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart'; // 
import '../widgets/loading_overlay.dart'; // 



class ProductoDetalleScreen extends StatelessWidget {
  final Producto producto;
  
  const ProductoDetalleScreen({
    super.key,
    required this.producto,
  });

  @override
Widget build(BuildContext context) {
  final carritoProvider = Provider.of<CarritoProvider>(context);

  return LoadingOverlay(
    isLoading: carritoProvider.isLoading,
    child: Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 400,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Imagen del producto (icono)
                  Container(
                    width: double.infinity,
                    height: 400, // Asegura que ocupe el espacio completo
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Center(
                      child: Icon(
                        _getIcono(producto.imagenUrl),
                        size: 120,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  // Botón de volver atrás
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  // Ícono de favorito
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.red),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  // Badge de descuento
                  Positioned(
                    top: 40,
                    left: 16 + 48, // Desplazado del botón de atrás
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '25% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Botón flotante de agregar al carrito
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      onPressed: () async {
                        final provider = Provider.of<CarritoProvider>(context, listen: false);
                        try {
                          await provider.agregarProducto(producto, 1);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${producto.nombre} agregado al carrito')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del producto
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Precio
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Descripción detallada
                  Text(
                    producto.descripcion,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Botón de compra adicional
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'COMPRAR AHORA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // Método auxiliar para obtener iconos
  IconData _getIcono(String tipo) {
    switch (tipo) {
      case 'laptop':
        return Icons.laptop;
      case 'headphones':
        return Icons.headphones;
      case 'watch':
        return Icons.watch;
      case 'camera':
        return Icons.camera_alt;
      case 'keyboard':
        return Icons.keyboard;
      case 'mouse':
        return Icons.mouse;
      default:
        return Icons.shopping_bag;
    }
  }
}