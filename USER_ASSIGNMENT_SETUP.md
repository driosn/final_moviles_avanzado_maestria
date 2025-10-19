# Configuración del Módulo de Asignación de Usuarios a Tiendas

## Estructura del Proyecto

Este módulo implementa la funcionalidad para asignar y desasignar usuarios gestores a tiendas específicas, usando Clean Architecture, Bloc para manejo de estado, y Supabase como backend.

### Arquitectura

```
lib/features/users/
├── data/
│   ├── datasources/
│   │   └── store_assignment_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── store_assignment_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── store_assignment.dart
│   ├── repositories/
│   │   └── store_assignment_repository.dart
│   └── usecases/
│       ├── get_all_stores_usecase.dart
│       ├── get_gestor_users_usecase.dart
│       ├── get_assigned_users_usecase.dart
│       ├── get_available_users_usecase.dart
│       ├── assign_user_to_store_usecase.dart
│       └── remove_user_from_store_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── store_assignment_bloc.dart
    │   ├── store_assignment_event.dart
    │   └── store_assignment_state.dart
    └── pages/
        ├── user_management_page.dart
        └── store_assignment_page.dart
```

## Configuración de Base de Datos

### 1. Crear Tabla de Asignaciones

Ejecuta el siguiente SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de asignaciones usuario-tienda
CREATE TABLE store_assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, store_id) -- Evita asignaciones duplicadas
);

-- Crear índices para optimizar consultas
CREATE INDEX store_assignments_user_id_idx ON store_assignments(user_id);
CREATE INDEX store_assignments_store_id_idx ON store_assignments(store_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE store_assignments ENABLE ROW LEVEL SECURITY;

-- Política para que solo los administradores puedan ver todas las asignaciones
CREATE POLICY "Admins can view all store assignments" ON store_assignments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan insertar asignaciones
CREATE POLICY "Admins can insert store assignments" ON store_assignments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan actualizar asignaciones
CREATE POLICY "Admins can update store assignments" ON store_assignments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política para que solo los administradores puedan eliminar asignaciones
CREATE POLICY "Admins can delete store assignments" ON store_assignments
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Política adicional: Los gestores pueden ver sus propias asignaciones
CREATE POLICY "Store managers can view their own assignments" ON store_assignments
  FOR SELECT USING (
    user_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'gestor_tienda'
    )
  );
```

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de Clean Architecture
- [x] Inyección de dependencias con GetIt
- [x] Manejo de estado con Bloc
- [x] Integración con Supabase
- [x] CRUD de asignaciones usuario-tienda
- [x] Validación de permisos (solo administradores)
- [x] Interfaz de usuario intuitiva
- [x] Navegación integrada con el admin

### 🏪 **Datos de Asignación**
- **Usuario**: Solo usuarios con rol `gestor_tienda`
- **Tienda**: Cualquier tienda existente en el sistema
- **Fecha de Asignación**: Timestamp automático

### 🎯 **Operaciones Disponibles**
1. **Ver Tiendas**: Lista todas las tiendas disponibles
2. **Ver Gestores Asignados**: Lista usuarios asignados a una tienda específica
3. **Ver Gestores Disponibles**: Lista usuarios gestores no asignados a la tienda
4. **Asignar Usuario**: Asigna un gestor a una tienda
5. **Remover Usuario**: Desasigna un gestor de una tienda

### 🎨 **Interfaz de Usuario**
- **Selector de Tienda**: Dropdown para seleccionar tienda
- **Lista de Asignados**: Cards con gestores ya asignados (con botón remover)
- **Lista de Disponibles**: Cards con gestores disponibles (con botón asignar)
- **Confirmación de Acciones**: Dialogs de confirmación para asignar/remover
- **Estados de Carga**: Indicadores de progreso
- **Mensajes de Éxito/Error**: Feedback visual al usuario

## Estructura de Datos

### Asignación de Tienda (StoreAssignment)
```dart
class StoreAssignment {
  final String id;
  final String userId;
  final String storeId;
  final DateTime assignedAt;
  final DateTime? updatedAt;
}
```

### Usuario (User)
```dart
class User {
  final String id;
  final String email;
  final String? name;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

## Navegación

### Rutas Disponibles
- `/user-management` - Gestión de usuarios (solo para administradores)
- `/store-assignment` - Asignación de tiendas (solo para administradores)

### Acceso
- Solo usuarios con rol `admin` pueden acceder a la gestión de asignaciones
- La navegación se integra automáticamente en el panel de administración

## Instalación y Ejecución

### 1. Ejecutar SQL
Ejecuta el SQL proporcionado en Supabase para crear la tabla `store_assignments`.

### 2. Verificar Dependencias
Las dependencias ya están configuradas en `injection_container.dart`.

### 3. Probar Funcionalidad
1. Inicia sesión como administrador
2. Ve al panel de administración
3. Toca "Usuarios" para acceder a la gestión
4. Toca "Asignación de Tiendas"
5. Selecciona una tienda
6. Prueba asignar y remover gestores

## Notas Importantes

1. **Seguridad**: Solo administradores pueden gestionar asignaciones
2. **Validación**: Solo usuarios con rol `gestor_tienda` pueden ser asignados
3. **Unicidad**: Un usuario no puede estar asignado a la misma tienda dos veces
4. **RLS**: Las políticas de seguridad están configuradas en Supabase
5. **Escalabilidad**: La arquitectura permite agregar más funcionalidades fácilmente

## Troubleshooting

### Error de Permisos
- Verifica que el usuario tenga rol `admin`
- Revisa las políticas RLS en Supabase

### Error de Conexión
- Verifica que la tabla `store_assignments` exista
- Revisa las credenciales de Supabase
- Verifica que las tablas `stores` y `user_profiles` existan

### Error de Asignación
- Asegúrate de que el usuario tenga rol `gestor_tienda`
- Verifica que la tienda exista
- Revisa que no haya asignaciones duplicadas
