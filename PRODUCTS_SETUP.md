# Configuración del Módulo de Productos

## Estructura del Proyecto

Este módulo implementa un CRUD completo de productos para el Administrador usando Clean Architecture, Bloc para manejo de estado, y Supabase como backend con funcionalidad de subida de imágenes.

### Arquitectura

```
lib/features/products/
├── data/
│   ├── datasources/
│   │   └── products_remote_datasource.dart
│   ├── models/
│   │   └── product_model.dart
│   └── repositories/
│       └── products_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── product.dart
│   ├── repositories/
│   │   └── products_repository.dart
│   └── usecases/
│       ├── get_all_products_usecase.dart
│       ├── get_product_by_id_usecase.dart
│       ├── create_product_usecase.dart
│       ├── update_product_usecase.dart
│       ├── delete_product_usecase.dart
│       └── upload_image_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── products_bloc.dart
    │   ├── products_event.dart
    │   └── products_state.dart
    └── pages/
        ├── products_list_page.dart
        ├── create_product_page.dart
        └── edit_product_page.dart
```

## Configuración de Base de Datos

### 1. Crear Tabla de Productos

Ejecuta el siguiente SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de productos
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price > 0),
  category TEXT NOT NULL,
  image_url TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índice para búsquedas por categoría
CREATE INDEX products_category_idx ON products(category);

-- Crear índice para búsquedas por nombre
CREATE INDEX products_name_idx ON products(name);

-- Habilitar RLS (Row Level Security)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Política para que solo los administradores puedan ver todos los productos
CREATE POLICY "Admins can view all products" ON products
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan insertar productos
CREATE POLICY "Admins can insert products" ON products
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan actualizar productos
CREATE POLICY "Admins can update products" ON products
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan eliminar productos
CREATE POLICY "Admins can delete products" ON products
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );
```

### 2. Crear Bucket para Imágenes

Ejecuta el siguiente SQL para crear el bucket de imágenes:

```sql
-- Crear bucket para imágenes
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true);

-- Política para que solo los administradores puedan subir imágenes
CREATE POLICY "Admins can upload images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'images' AND
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que todos puedan ver las imágenes (públicas)
CREATE POLICY "Anyone can view images" ON storage.objects
  FOR SELECT USING (bucket_id = 'images');
```

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de Clean Architecture
- [x] Inyección de dependencias con GetIt
- [x] Manejo de estado con Bloc
- [x] Integración con Supabase
- [x] CRUD completo de productos
- [x] Subida de imágenes a Supabase Storage
- [x] Validación de formularios
- [x] Manejo de errores
- [x] Navegación integrada con el admin
- [x] Interfaz de usuario intuitiva

### 🛍️ **Datos de Producto**
- **Nombre**: Texto libre (mínimo 2 caracteres)
- **Precio**: Número decimal positivo
- **Categoría**: Selección predefinida (Pinturas y Acabados, Pisos y Revestimientos, Iluminación, Accesorios Decorativos)
- **Imagen**: Subida obligatoria desde galería (se genera URL automáticamente)

### 🎯 **Operaciones CRUD**
1. **Create**: Crear nuevo producto
2. **Read**: Listar todos los productos
3. **Update**: Editar producto existente
4. **Delete**: Eliminar producto

### 🎨 **Interfaz de Usuario**
- **Lista de Productos**: Vista en lista horizontal con cards para cada producto (responsive)
- **Formulario de Creación**: Campos para nombre, precio, categoría e imagen obligatoria
- **Formulario de Edición**: Pre-llenado con datos existentes
- **Subida de Imágenes**: Proceso integrado - seleccionar imagen y crear/editar producto en un solo paso
- **Confirmación de Eliminación**: Dialog de confirmación
- **Estados de Carga**: Indicadores de progreso
- **Mensajes de Éxito/Error**: Feedback visual al usuario
- **Validación de Imagen**: No permite crear/editar sin imagen seleccionada
- **Diseño Responsive**: ListView se adapta a diferentes tamaños de pantalla

## Estructura de Datos

### Producto (Product)
```dart
class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Categorías Disponibles
```dart
const List<String> categories = [
  'Pinturas y Acabados',
  'Pisos y Revestimientos',
  'Iluminación',
  'Accesorios Decorativos',
];
```

## Navegación

### Rutas Disponibles
- Acceso desde AdminHomePage → "Productos"

### Acceso
- Solo usuarios con rol `admin` pueden acceder a la gestión de productos
- La navegación se integra automáticamente en el panel de administración

## Instalación y Ejecución

### 1. Ejecutar SQL
Ejecuta el SQL proporcionado en Supabase para crear la tabla `products` y el bucket `images`.

### 2. Verificar Dependencias
Las dependencias ya están configuradas en `injection_container.dart`.

### 3. Agregar Dependencia de Image Picker
Agrega esta dependencia a tu `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.0.4
```

Luego ejecuta:
```bash
flutter pub get
```

### 4. Probar Funcionalidad
1. Inicia sesión como administrador
2. Ve al panel de administración
3. Toca "Productos" para acceder al CRUD
4. Prueba crear, editar y eliminar productos
5. **Flujo de Creación**: Selecciona imagen → Presiona "Crear Producto" → Se sube imagen automáticamente → Se crea producto
6. **Flujo de Edición**: Modifica datos → (Opcional) Selecciona nueva imagen → Presiona "Actualizar Producto"
7. **Proceso Integrado**: La subida de imagen y creación/edición se manejan en un solo evento del BLoC
8. **Contexto del BLoC**: Se usa `BlocProvider.value` para compartir la misma instancia del BLoC entre páginas

## Notas Importantes

1. **Seguridad**: Solo administradores pueden gestionar productos
2. **Validación**: Nombres deben tener al menos 2 caracteres, precios deben ser positivos
3. **Imágenes**: Se suben a Supabase Storage en el bucket 'images'
4. **RLS**: Las políticas de seguridad están configuradas en Supabase
5. **Escalabilidad**: La arquitectura permite agregar más campos fácilmente

## Troubleshooting

### Error de Permisos
- Verifica que el usuario tenga rol `admin`
- Revisa las políticas RLS en Supabase

### Error de Conexión
- Verifica que la tabla `products` exista
- Revisa las credenciales de Supabase

### Error de Subida de Imágenes
- Verifica que el bucket 'images' exista
- Revisa las políticas de storage en Supabase
- Asegúrate de que `image_picker` esté instalado

### Error de Validación
- Asegúrate de que el nombre tenga al menos 2 caracteres
- Verifica que el precio sea un número positivo
- Verifica que se seleccione una categoría
- **IMPORTANTE**: Debes subir una imagen antes de crear/editar un producto

## Categorías de Decoración de Construcción

### 📋 **Categorías Disponibles:**
- **Pinturas y Acabados**: Pinturas, barnices, texturas, selladores
- **Pisos y Revestimientos**: Cerámicas, porcelanatos, madera, laminados
- **Iluminación**: Lámparas, focos, luces LED, accesorios de iluminación
- **Accesorios Decorativos**: Molduras, marcos, espejos, elementos decorativos
