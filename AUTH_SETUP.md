# Configuración del Módulo de Autenticación

## Estructura del Proyecto

Este proyecto implementa un módulo de autenticación completo usando Clean Architecture, Bloc para manejo de estado, y Supabase como backend.

### Arquitectura

```
lib/
├── core/
│   ├── constants/
│   │   └── supabase_config.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── injection/
│   │   └── injection_container.dart
│   └── navigation/
│       └── app_router.dart
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── auth_remote_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       ├── sign_in_usecase.dart
│       │       ├── sign_up_usecase.dart
│       │       ├── sign_out_usecase.dart
│       │       └── get_current_user_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── auth_bloc.dart
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           └── pages/
│               ├── login_page.dart
│               ├── signup_page.dart
│               ├── admin_home_page.dart
│               ├── gestor_home_page.dart
│               └── cliente_home_page.dart
└── main.dart
```

## Configuración de Supabase

### 1. Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Crea una nueva cuenta o inicia sesión
3. Crea un nuevo proyecto
4. Obtén tu URL y anon key del proyecto

### 2. Configurar Variables

Edita el archivo `lib/core/constants/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'TU_SUPABASE_URL_AQUI';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY_AQUI';
}
```

### 3. Configurar Base de Datos

Ejecuta el siguiente SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de perfiles de usuario
CREATE TABLE user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'gestor_tienda', 'cliente')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índice único para user_id
CREATE UNIQUE INDEX user_profiles_user_id_idx ON user_profiles(user_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo puedan ver su propio perfil
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

-- Política para que los usuarios puedan insertar su propio perfil
CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios puedan actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- Función para crear perfil automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Usuario'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'cliente')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil automáticamente
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

create policy "Permitir leer todo"
    on user_profiles
    for select
    using (true);
```

## Tipos de Usuario

### 1. Administrador (admin)
- Acceso completo al sistema
- Puede gestionar usuarios
- Panel de administración con opciones avanzadas

### 2. Gestor de Tienda (gestor_tienda)
- Acceso limitado a funciones de tienda
- Pantalla de bienvenida con información de próximas funcionalidades

### 3. Cliente (cliente)
- Acceso básico
- Pantalla de bienvenida con información de próximas funcionalidades

## Instalación y Ejecución

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Ejecutar la Aplicación

```bash
flutter run
```

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de Clean Architecture
- [x] Inyección de dependencias con GetIt
- [x] Manejo de estado con Bloc 
- [x] Integración con Supabase
- [x] Autenticación (login/signup)
- [x] Tres tipos de usuario
- [x] Navegación basada en roles
- [x] Pantallas específicas por rol
- [x] Validación de formularios
- [x] Manejo de errores

### 🔄 Próximas Funcionalidades
- [x] Gestión de tiendas (Admin) - ✅ COMPLETADO
- [ ] Gestión de usuarios (Admin)
- [ ] Gestión de productos (Gestor de Tienda)
- [ ] Catálogo de productos (Cliente)
- [ ] Carrito de compras (Cliente)
- [ ] Reportes y estadísticas
- [ ] Configuración del sistema

## Estructura de Datos

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

### Roles de Usuario
```dart
enum UserRole {
  admin,
  gestorTienda,
  cliente,
}
```

## Notas Importantes

1. **Configuración de Supabase**: Asegúrate de configurar correctamente las credenciales en `supabase_config.dart`
2. **Base de Datos**: Ejecuta el SQL proporcionado para crear las tablas necesarias
3. **Seguridad**: Las políticas RLS están configuradas para proteger los datos
4. **Escalabilidad**: La arquitectura está preparada para agregar nuevas funcionalidades fácilmente
5. **Manejo de Estado**: Se usa solo Bloc sin streams para simplificar la implementación
6. **Módulo de Tiendas**: Ver `STORES_SETUP.md` para configuración del CRUD de tiendas

## Troubleshooting

### Error de Conexión a Supabase
- Verifica que las credenciales estén correctas
- Asegúrate de que el proyecto de Supabase esté activo

### Error de Autenticación
- Verifica que las políticas RLS estén configuradas correctamente
- Revisa que la tabla `user_profiles` exista

### Error de Navegación
- Verifica que todas las rutas estén definidas en `app_router.dart`
- Asegúrate de que los BlocProviders estén configurados correctamente
