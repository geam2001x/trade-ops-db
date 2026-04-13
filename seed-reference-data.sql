USE trade_operations_suite;

INSERT INTO roles (name, description)
VALUES
  ('admin', 'Administrador general del sistema'),
  ('operator', 'Operador general del flujo E2E'),
  ('sales', 'Responsable comercial y ventas'),
  ('warehouse', 'Responsable de bodega e inventario'),
  ('finance', 'Responsable financiero y de rentabilidad'),
  ('viewer', 'Usuario de consulta')
ON DUPLICATE KEY UPDATE
  description = VALUES(description);

INSERT INTO currencies (code, name, symbol, is_base_currency, is_active)
VALUES
  ('USD', 'US Dollar', '$', 1, 1),
  ('CLP', 'Chilean Peso', '$', 0, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  symbol = VALUES(symbol),
  is_base_currency = VALUES(is_base_currency),
  is_active = VALUES(is_active);

INSERT INTO warehouses (name, location, is_active)
VALUES
  ('Santiago Central Warehouse', 'Santiago, Chile', 1),
  ('Valparaiso Transit Hub', 'Valparaiso, Chile', 1)
ON DUPLICATE KEY UPDATE
  location = VALUES(location),
  is_active = VALUES(is_active);
