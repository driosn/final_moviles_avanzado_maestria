# Configuración del Módulo de Tiendas

## Estructura del Proyecto

Este módulo implementa un CRUD completo de tiendas para el Administrador usando Clean Architecture, Bloc para manejo de estado, y Supabase como backend.

### Arquitectura

```
lib/features/stores/
├── data/
│   ├── datasources/
│   │   └── stores_remote_datasource.dart
│   ├── models/
│   │   └── store_model.dart
│   └── repositories/
│       └── stores_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── store.dart
│   ├── repositories/
│   │   └── stores_repository.dart
│   └── usecases/
│       ├── get_all_stores_usecase.dart
│       ├── get_store_by_id_usecase.dart
│       ├── create_store_usecase.dart
│       ├── update_store_usecase.dart
│       └── delete_store_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── stores_bloc.dart
    │   ├── stores_event.dart
    │   └── stores_state.dart
    └── pages/
        ├── stores_list_page.dart
        ├── create_store_page.dart
        └── edit_store_page.dart
```

## Configuración de Base de Datos

### 1. Crear Tabla de Tiendas

Ejecuta el siguiente SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de tiendas
CREATE TABLE stores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  city TEXT NOT NULL CHECK (city IN ('la_paz', 'cochabamba', 'santa_cruz')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índice para búsquedas por ciudad
CREATE INDEX stores_city_idx ON stores(city);

-- Habilitar RLS (Row Level Security)
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;\

-- Política para que solo los administradores puedan ver todas las tiendas
CREATE POLICY "Admins can view all stores" ON stores
  FOR SELECT USING (\
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan insertar tiendas
CREATE POLICY "Admins can insert stores" ON stores
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan actualizar tiendas
CREATE POLICY "Admins can update stores" ON stores
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan eliminar tiendas
CREATE POLICY "Admins can delete stores" ON stores
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );
```

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de Clean Architecture
- [x] Inyección de dependencias con GetIt
- [x] Manejo de estado con Bloc
- [x] Integración con Supabase
- [x] CRUD completo de tiendas
- [x] Validación de formularios
- [x] Manejo de errores
- [x] Navegación integrada con el admin
- [x] Interfaz de usuario intuitiva

### 🏪 **Datos de Tienda**
- **Nombre**: Texto libre (mínimo 2 caracteres)
- **Ciudad**: Selección entre La Paz, Cochabamba, Santa Cruz

### 🎯 **Operaciones CRUD**
1. **Create**: Crear nueva tienda
2. **Read**: Listar todas las tiendas
3. **Update**: Editar tienda existente
4. **Delete**: Eliminar tienda

### 🎨 **Interfaz de Usuario**
- **Lista de Tiendas**: Vista con cards para cada tienda
- **Formulario de Creación**: Campos para nombre y ciudad
- **Formulario de Edición**: Pre-llenado con datos existentes
- **Confirmación de Eliminación**: Dialog de confirmación
- **Estados de Carga**: Indicadores de progreso
- **Mensajes de Éxito/Error**: Feedback visual al usuario

## Estructura de Datos

### Tienda (Store)
```dart
class Store {
  final String id;
  final String name;
  final City city;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Ciudades Disponibles
```dart
enum City {
  laPaz,      // La Paz
  cochabamba, // Cochabamba
  santaCruz,  // Santa Cruz
}
```

## Navegación

### Rutas Disponibles
- `/stores` - Lista de tiendas (solo para administradores)

### Acceso
- Solo usuarios con rol `admin` pueden acceder a la gestión de tiendas
- La navegación se integra automáticamente en el panel de administración

## Instalación y Ejecución

### 1. Ejecutar SQL
Ejecuta el SQL proporcionado en Supabase para crear la tabla `stores`.

### 2. Verificar Dependencias
Las dependencias ya están configuradas en `injection_container.dart`.

### 3. Probar Funcionalidad
1. Inicia sesión como administrador
2. Ve al panel de administración
3. Toca "Tiendas" para acceder al CRUD
4. Prueba crear, editar y eliminar tiendas

## Notas Importantes

1. **Seguridad**: Solo administradores pueden gestionar tiendas
2. **Validación**: Nombres deben tener al menos 2 caracteres
3. **Ciudades**: Solo se permiten las 3 ciudades especificadas
4. **RLS**: Las políticas de seguridad están configuradas en Supabase
5. **Escalabilidad**: La arquitectura permite agregar más campos fácilmente

## Troubleshooting

### Error de Permisos
- Verifica que el usuario tenga rol `admin`
- Revisa las políticas RLS en Supabase

### Error de Conexión
- Verifica que la tabla `stores` exista
- Revisa las credenciales de Supabase

### Error de Validación
- Asegúrate de que el nombre tenga al menos 2 caracteres
- Verifica que la ciudad sea una de las 3 permitidas
