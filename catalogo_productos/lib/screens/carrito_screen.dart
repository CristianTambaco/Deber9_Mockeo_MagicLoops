import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../models/carrito_item.dart';
import '../widgets/loading_overlay.dart'; //

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    return LoadingOverlay(
      isLoading: carrito.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carrito de Compras'),
          actions: [
            if (carrito.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // Mostrar diálogo de confirmación
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Vaciar Carrito'),
                    content: const Text('¿Está seguro que desea vaciar el carrito? Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false), // Cancelar
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true), // Aceptar
                        child: const Text('Aceptar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                // Si el usuario aceptó, proceder a vaciar el carrito
                if (shouldClear == true) {
                  try {
                    await carrito.vaciarCarrito();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Carrito vaciado')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: carrito.items.isEmpty
            ? const Center(child: Text('El carrito está vacío'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.items.length,
                      itemBuilder: (context, index) {
                        final item = carrito.items[index];
                        return _CarritoItemWidget(item: item);
                      },
                    ),
                  ),
                  _buildTotales(context, carrito.totales),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Lógica de finalizar compra
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Compra finalizada')),
                        );
                      },
                      child: const Text(
                        'Finalizar Compra',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }

  Widget _buildTotales(BuildContext context, Map<String, double> totales) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal', totales['subtotal']!),
          if (totales['descuento']! > 0)
            _buildTotalRow('Descuento (10%)', -totales['descuento']!),
          _buildTotalRow('Impuestos (12%)', totales['impuestos']!),
          const Divider(),
          _buildTotalRow(
            'Total',
            totales['total']!,
            bold: true,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double valor, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarritoItemWidget extends StatelessWidget {
  final CarritoItem item;

  const _CarritoItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(_getIcono(item.producto.imagenUrl), size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('\$${item.producto.precio.toStringAsFixed(2)}'),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () async {
                    if (item.cantidad <= 1) return;
                    try {
                      await carrito.actualizarCantidad(
                        item.producto.id,
                        item.cantidad - 1,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
                Text('${item.cantidad}', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    try {
                      await carrito.actualizarCantidad(
                        item.producto.id,
                        item.cantidad + 1,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  await carrito.eliminarProducto(item.producto.id);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

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
