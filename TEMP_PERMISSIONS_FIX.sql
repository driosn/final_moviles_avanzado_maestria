-- POLÍTICAS TEMPORALES PARA DEBUG - PERMITIR ACCESO TOTAL
-- ⚠️  IMPORTANTE: Estas políticas son solo para debug. NO usar en producción.

-- 1. Eliminar todas las políticas existentes de store_assignments
DROP POLICY IF EXISTS "Admins can view all store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Admins can insert store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Admins can update store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Admins can delete store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Store managers can view their own assignments" ON store_assignments;

-- 2. Crear política temporal que permite a CUALQUIER usuario ver todos los store_assignments
CREATE POLICY "TEMP: Anyone can view all store assignments" ON store_assignments
  FOR SELECT USING (true);

-- 3. Crear política temporal que permite a CUALQUIER usuario insertar store_assignments
CREATE POLICY "TEMP: Anyone can insert store assignments" ON store_assignments
  FOR INSERT WITH CHECK (true);

-- 4. Crear política temporal que permite a CUALQUIER usuario actualizar store_assignments
CREATE POLICY "TEMP: Anyone can update store assignments" ON store_assignments
  FOR UPDATE USING (true);

-- 5. Crear política temporal que permite a CUALQUIER usuario eliminar store_assignments
CREATE POLICY "TEMP: Anyone can delete store assignments" ON store_assignments
  FOR DELETE USING (true);

-- 6. Eliminar todas las políticas existentes de stores
DROP POLICY IF EXISTS "Admins can view all stores" ON stores;
DROP POLICY IF EXISTS "Admins can insert stores" ON stores;
DROP POLICY IF EXISTS "Admins can update stores" ON stores;
DROP POLICY IF EXISTS "Admins can delete stores" ON stores;

-- 7. Crear política temporal que permite a CUALQUIER usuario ver todos los stores
CREATE POLICY "TEMP: Anyone can view all stores" ON stores
  FOR SELECT USING (true);

-- 8. Crear política temporal que permite a CUALQUIER usuario insertar stores
CREATE POLICY "TEMP: Anyone can insert stores" ON stores
  FOR INSERT WITH CHECK (true);

-- 9. Crear política temporal que permite a CUALQUIER usuario actualizar stores
CREATE POLICY "TEMP: Anyone can update stores" ON stores
  FOR UPDATE USING (true);

-- 10. Crear política temporal que permite a CUALQUIER usuario eliminar stores
CREATE POLICY "TEMP: Anyone can delete stores" ON stores
  FOR DELETE USING (true);

-- 11. Verificar que las políticas se crearon correctamente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('store_assignments', 'stores')
ORDER BY tablename, policyname;
