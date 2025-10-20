-- POLÍTICAS TEMPORALES PARA PRODUCTS - ACCESO COMPLETO
-- ⚠️  IMPORTANTE: Estas políticas son solo para debug. NO usar en producción.

-- 1. Eliminar todas las políticas existentes de products
DROP POLICY IF EXISTS "Admins can view all products" ON products;
DROP POLICY IF EXISTS "Admins can insert products" ON products;
DROP POLICY IF EXISTS "Admins can update products" ON products;
DROP POLICY IF EXISTS "Admins can delete products" ON products;

-- 2. Crear política temporal que permite a CUALQUIER usuario ver todos los products
CREATE POLICY "TEMP: Anyone can view all products" ON products
  FOR SELECT USING (true);

-- 3. Crear política temporal que permite a CUALQUIER usuario insertar products
CREATE POLICY "TEMP: Anyone can insert products" ON products
  FOR INSERT WITH CHECK (true);

-- 4. Crear política temporal que permite a CUALQUIER usuario actualizar products
CREATE POLICY "TEMP: Anyone can update products" ON products
  FOR UPDATE USING (true);

-- 5. Crear política temporal que permite a CUALQUIER usuario eliminar products
CREATE POLICY "TEMP: Anyone can delete products" ON products
  FOR DELETE USING (true);

-- 6. Verificar que las políticas se crearon correctamente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'products'
ORDER BY policyname;
