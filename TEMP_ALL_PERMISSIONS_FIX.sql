-- POLÍTICAS TEMPORALES PARA DEBUG - ACCESO COMPLETO A TODAS LAS TABLAS
-- ⚠️  IMPORTANTE: Estas políticas son solo para debug. NO usar en producción.

-- ========================================
-- PRODUCTS - ACCESO COMPLETO
-- ========================================

-- Eliminar todas las políticas existentes de products
DROP POLICY IF EXISTS "Admins can view all products" ON products;
DROP POLICY IF EXISTS "Admins can insert products" ON products;
DROP POLICY IF EXISTS "Admins can update products" ON products;
DROP POLICY IF EXISTS "Admins can delete products" ON products;

-- Crear políticas temporales para products
CREATE POLICY "TEMP: Anyone can view all products" ON products
  FOR SELECT USING (true);

CREATE POLICY "TEMP: Anyone can insert products" ON products
  FOR INSERT WITH CHECK (true);

CREATE POLICY "TEMP: Anyone can update products" ON products
  FOR UPDATE USING (true);

CREATE POLICY "TEMP: Anyone can delete products" ON products
  FOR DELETE USING (true);

-- ========================================
-- STORES - ACCESO COMPLETO
-- ========================================

-- Eliminar todas las políticas existentes de stores
DROP POLICY IF EXISTS "Admins can view all stores" ON stores;
DROP POLICY IF EXISTS "Admins can insert stores" ON stores;
DROP POLICY IF EXISTS "Admins can update stores" ON stores;
DROP POLICY IF EXISTS "Admins can delete stores" ON stores;

-- Crear políticas temporales para stores
CREATE POLICY "TEMP: Anyone can view all stores" ON stores
  FOR SELECT USING (true);

CREATE POLICY "TEMP: Anyone can insert stores" ON stores
  FOR INSERT WITH CHECK (true);

CREATE POLICY "TEMP: Anyone can update stores" ON stores
  FOR UPDATE USING (true);

CREATE POLICY "TEMP: Anyone can delete stores" ON stores
  FOR DELETE USING (true);

-- ========================================
-- STORE_ASSIGNMENTS - ACCESO COMPLETO
-- ========================================

-- Eliminar todas las políticas existentes de store_assignments
DROP POLICY IF EXISTS "Admins can view all store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Admins can insert store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Admins can update store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Admins can delete store assignments" ON store_assignments;
DROP POLICY IF EXISTS "Store managers can view their own assignments" ON store_assignments;

-- Crear políticas temporales para store_assignments
CREATE POLICY "TEMP: Anyone can view all store assignments" ON store_assignments
  FOR SELECT USING (true);

CREATE POLICY "TEMP: Anyone can insert store assignments" ON store_assignments
  FOR INSERT WITH CHECK (true);

CREATE POLICY "TEMP: Anyone can update store assignments" ON store_assignments
  FOR UPDATE USING (true);

CREATE POLICY "TEMP: Anyone can delete store assignments" ON store_assignments
  FOR DELETE USING (true);

-- ========================================
-- INVENTORY_ITEMS - ACCESO COMPLETO
-- ========================================

-- Eliminar todas las políticas existentes de inventory_items
DROP POLICY IF EXISTS "Admins can view all inventory items" ON inventory_items;
DROP POLICY IF EXISTS "Admins can insert inventory items" ON inventory_items;
DROP POLICY IF EXISTS "Admins can update inventory items" ON inventory_items;
DROP POLICY IF EXISTS "Admins can delete inventory items" ON inventory_items;
DROP POLICY IF EXISTS "Store managers can view their store inventory" ON inventory_items;
DROP POLICY IF EXISTS "Store managers can update their store inventory" ON inventory_items;

-- Crear políticas temporales para inventory_items
CREATE POLICY "TEMP: Anyone can view all inventory items" ON inventory_items
  FOR SELECT USING (true);

CREATE POLICY "TEMP: Anyone can insert inventory items" ON inventory_items
  FOR INSERT WITH CHECK (true);

CREATE POLICY "TEMP: Anyone can update inventory items" ON inventory_items
  FOR UPDATE USING (true);

CREATE POLICY "TEMP: Anyone can delete inventory items" ON inventory_items
  FOR DELETE USING (true);

-- ========================================
-- STOCK_MOVEMENTS - ACCESO COMPLETO
-- ========================================

-- Eliminar todas las políticas existentes de stock_movements
DROP POLICY IF EXISTS "Admins can view all stock movements" ON stock_movements;
DROP POLICY IF EXISTS "Admins can insert stock movements" ON stock_movements;
DROP POLICY IF EXISTS "Store managers can view their store stock movements" ON stock_movements;
DROP POLICY IF EXISTS "Store managers can insert stock movements" ON stock_movements;

-- Crear políticas temporales para stock_movements
CREATE POLICY "TEMP: Anyone can view all stock movements" ON stock_movements
  FOR SELECT USING (true);

CREATE POLICY "TEMP: Anyone can insert stock movements" ON stock_movements
  FOR INSERT WITH CHECK (true);

-- ========================================
-- VERIFICACIÓN FINAL
-- ========================================

-- Verificar que todas las políticas se crearon correctamente
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('products', 'stores', 'store_assignments', 'inventory_items', 'stock_movements')
ORDER BY tablename, policyname;
