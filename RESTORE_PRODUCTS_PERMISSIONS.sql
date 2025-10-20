-- RESTAURAR POLÍTICAS ORIGINALES DE PRODUCTS DESPUÉS DEL DEBUG
-- Ejecutar este archivo después de confirmar que el problema era de permisos

-- 1. Eliminar todas las políticas temporales de products
DROP POLICY IF EXISTS "TEMP: Anyone can view all products" ON products;
DROP POLICY IF EXISTS "TEMP: Anyone can insert products" ON products;
DROP POLICY IF EXISTS "TEMP: Anyone can update products" ON products;
DROP POLICY IF EXISTS "TEMP: Anyone can delete products" ON products;

-- 2. Restaurar políticas originales de products
CREATE POLICY "Admins can view all products" ON products
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert products" ON products
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update products" ON products
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete products" ON products
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- 3. Verificar que las políticas se restauraron correctamente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'products'
ORDER BY policyname;
