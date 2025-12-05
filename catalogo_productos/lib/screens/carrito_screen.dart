import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../models/carrito_item.dart';
import '../widgets/loading_overlay.dart'; // Importa el overlay
import '../models/producto.dart'; // Importa los productos
import '../widgets/cantidad_selector.dart';


class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  // Estado local para el producto seleccionado y la cantidad
  Producto? productoSeleccionado;
  int cantidad = 1;

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
        body: Column(
          children: [
            // --- NUEVA SECCIÓN: SELECCIONAR PRODUCTOS ---
            _buildSeleccionarProductos(context, carrito),
            // --- FIN DE LA NUEVA SECCIÓN ---

            // Lista de productos en el carrito
            Expanded(
              child: carrito.items.isEmpty
                  ? const Center(child: Text('El carrito está vacío'))
                  : ListView.builder(
                      itemCount: carrito.items.length,
                      itemBuilder: (context, index) {
                        final item = carrito.items[index];
                        return _CarritoItemWidget(item: item);
                      },
                    ),
            ),

            // Totales y botón de finalizar compra
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
                child: const Text('Finalizar Compra', style: TextStyle(fontSize: 18)),
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

  // Método privado para construir la sección de selección de productos
  // Ahora puedes usar setState en estos métodos
  Widget _buildSeleccionarProductos(BuildContext context, CarritoProvider carrito) {
    final List<Producto> productosDisponibles = productosEjemplo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionar Productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Dropdown para seleccionar el producto
              Expanded(
                child: DropdownButtonFormField<Producto>(
                  decoration: InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(),
                  ),
                  value: productoSeleccionado,
                  onChanged: (value) {
                    setState(() {
                      productoSeleccionado = value;
                    });
                  },
                  items: productosDisponibles.map((producto) {
                    return DropdownMenuItem<Producto>(
                      value: producto,
                      child: Text('${producto.nombre} - \$${producto.precio.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              // Selector de cantidad
              Container(
                width: 100,
                child: CantidadSelector(
                  valorInicial: 1,
                  minimo: 1,
                  maximo: 10,
                  onChanged: (nuevaCantidad) {
                    setState(() {
                      cantidad = nuevaCantidad;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Botón para agregar al carrito
              ElevatedButton.icon(
                onPressed: productoSeleccionado != null && cantidad > 0
                    ? () async {
                        try {
                          await carrito.agregarProducto(productoSeleccionado!, cantidad);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${productoSeleccionado!.nombre} agregado al carrito')),
                          );
                          // Reiniciar los campos
                          setState(() {
                            productoSeleccionado = null;
                            cantidad = 1;
                          });
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Agregar al Carrito'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método privado para construir los totales
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

// Clase para mostrar un ítem del carrito 
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
                  Text(item.producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      await carrito.actualizarCantidad(item.producto.id, item.cantidad - 1);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
                Text('${item.cantidad}', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    try {
                      await carrito.actualizarCantidad(item.producto.id, item.cantidad + 1);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
      case 'laptop': return Icons.laptop;
      case 'headphones': return Icons.headphones;
      case 'watch': return Icons.watch;
      case 'camera': return Icons.camera_alt;
      case 'keyboard': return Icons.keyboard;
      case 'mouse': return Icons.mouse;
      default: return Icons.shopping_bag;
    }
  }
}