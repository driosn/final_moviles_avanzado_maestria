-- RESTAURAR POLÍTICAS ORIGINALES DESPUÉS DEL DEBUG
-- Ejecutar este archivo después de confirmar que el problema era de permisos

-- 1. Eliminar todas las políticas temporales de store_assignments
DROP POLICY IF EXISTS "TEMP: Anyone can view all store assignments" ON store_assignments;
DROP POLICY IF EXISTS "TEMP: Anyone can insert store assignments" ON store_assignments;
DROP POLICY IF EXISTS "TEMP: Anyone can update store assignments" ON store_assignments;
DROP POLICY IF EXISTS "TEMP: Anyone can delete store assignments" ON store_assignments;

-- 2. Eliminar todas las políticas temporales de stores
DROP POLICY IF EXISTS "TEMP: Anyone can view all stores" ON stores;
DROP POLICY IF EXISTS "TEMP: Anyone can insert stores" ON stores;
DROP POLICY IF EXISTS "TEMP: Anyone can update stores" ON stores;
DROP POLICY IF EXISTS "TEMP: Anyone can delete stores" ON stores;

-- 3. Restaurar políticas originales de store_assignments
CREATE POLICY "Admins can view all store assignments" ON store_assignments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert store assignments" ON store_assignments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update store assignments" ON store_assignments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete store assignments" ON store_assignments
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Store managers can view their own assignments" ON store_assignments
  FOR SELECT USING (
    user_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'gestor_tienda'
    )
  );

-- 4. Restaurar políticas originales de stores
CREATE POLICY "Admins can view all stores" ON stores
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert stores" ON stores
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update stores" ON stores
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete stores" ON stores
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- 5. Verificar que las políticas se restauraron correctamente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('store_assignments', 'stores')
ORDER BY tablename, policyname;
