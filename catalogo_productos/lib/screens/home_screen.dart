// Aquí aprenderemos: LayoutBuilder, MediaQuery y diseño adaptativo


import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';
import '../widgets/barra_navegacion.dart';






class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indiceNavegacion = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      // COLUMN: Estructura principal vertical
      body: Column(
        children: [
          // Contenido principal (se expande)
          Expanded(
            child: _buildContenidoPrincipal(),
          ),
          // Barra de navegación (altura fija)
          BarraNavegacion(
            indiceActual: _indiceNavegacion,
            onTap: (indice) {
              setState(() {
                _indiceNavegacion = indice;
              });
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    // MEDIAQUERY: Obtener información del dispositivo
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      // ROW dentro del título para layout horizontal
      title: Row(
        children: [
          const Icon(Icons.store, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Mi Tienda',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Mostrar ancho de pantalla (para debug/aprendizaje)
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${screenWidth.toInt()}px',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildContenidoPrincipal() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Si el ancho es >= 900px, mostrar layout con sidebar
      if (constraints.maxWidth >= 900) {
        return Row(
          children: [
            // Sidebar con categorías
            SizedBox(
              width: 250,
              child: _buildSidebar(),
            ),
            const SizedBox(width: 24),
            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    _buildEncabezado(),
                    const SizedBox(height: 20),
                    // Título de sección
                    const Text(
                      'Productos Destacados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Grid de productos
                    _buildGridProductos(),
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        // Layout móvil (actual)
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              _buildEncabezado(),
              const SizedBox(height: 20),
              // Categorías (scroll horizontal)
              _buildCategorias(),
              const SizedBox(height: 20),
              // Título de sección
              const Text(
                'Productos Destacados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Grid de productos (RESPONSIVO)
              _buildGridProductos(),
            ],
          ),
        );
      }
    },
  );
}

// Nuevo método para el sidebar
Widget _buildSidebar() {
  final categorias = ['Todos', 'Electrónica', 'Fotografía', 'Accesorios'];
  
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: SingleChildScrollView( 
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ...categorias.map((categoria) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _getIconoCategoria(categoria),
              color: Colors.blue,
            ),
            title: Text(categoria),
            onTap: () {},
            hoverColor: Colors.blue[50],
          );
        }).toList(),
      ],
    ),
    ),
  );
}

// Método auxiliar para obtener iconos de categorías
IconData _getIconoCategoria(String categoria) {
  switch (categoria) {
    case 'Electrónica':
      return Icons.electrical_services; // ✅ Corregido
    case 'Fotografía':
      return Icons.camera_alt;
    case 'Accesorios':
      return Icons.devices;
    default:
      return Icons.category;
  }
}


  Widget _buildEncabezado() {
    // LAYOUTBUILDER: Construye UI según el espacio disponible
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es mayor a 600px, mostrar en ROW
        if (constraints.maxWidth > 600) {
          return Row(
            children: [
              Expanded(child: _buildBannerPrincipal()),
              const SizedBox(width: 16),
              Expanded(child: _buildBannerSecundario()),
            ],
          );
        }
        // Si no, mostrar solo el banner principal
        return _buildBannerPrincipal();
      },
    );
  }

  Widget _buildBannerPrincipal() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      // STACK: Texto superpuesto sobre el fondo
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡Ofertas de Temporada!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hasta 50% de descuento',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Ver ofertas'),
                ),
              ],
            ),
          ),
          // Icono decorativo posicionado
          Positioned(
            right: 20,
            bottom: 20,
            child: Icon(
              Icons.local_offer,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSecundario() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 40, color: Colors.orange[700]),
            const SizedBox(height: 8),
            Text(
              'Envío Gratis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
            ),
            Text(
              'En compras +\$50',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorias() {
    final categorias = ['Todos', 'Electrónica', 'Fotografía', 'Accesorios'];
    
    return SizedBox(
      height: 40,
      // ROW con scroll horizontal
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final esSeleccionado = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: esSeleccionado ? Colors.blue : Colors.white,
                foregroundColor: esSeleccionado ? Colors.white : Colors.black,
                elevation: esSeleccionado ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: esSeleccionado ? Colors.blue : Colors.grey[300]!,
                  ),
                ),
              ),
              child: Text(categorias[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridProductos() {
    // LAYOUTBUILDER: Determinar número de columnas según el ancho
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular columnas según el ancho disponible
        int columnas;
        double childAspectRatio;
        
        if (constraints.maxWidth >= 1200) {
          // Desktop grande: 4 columnas
          columnas = 4;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 900) {
          // Desktop: 3 columnas
          columnas = 3;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth >= 600) {
          // Tablet: 3 columnas
          columnas = 3;
          childAspectRatio = 0.7;
        } else {
          // Móvil: 2 columnas
          columnas = 2;
          childAspectRatio = 0.65;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: productosEjemplo.length,
          itemBuilder: (context, index) {
            return ProductoCard(producto: productosEjemplo[index]);
          },
        );
      },
    );
  }
}


