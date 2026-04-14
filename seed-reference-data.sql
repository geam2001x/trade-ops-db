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

INSERT INTO suppliers (
  name,
  tax_id,
  country_code,
  contact_name,
  email,
  phone,
  address,
  is_active
)
VALUES
  (
    'Shenzhen Industrial Supply Co.',
    'CN-SIS-001',
    'CN',
    'Lina Chen',
    'orders@shenzhen-industrial.example',
    '+86 755 0000 0001',
    'Baoan District, Shenzhen, China',
    1
  ),
  (
    'Pacific Components Miami',
    'US-PCM-002',
    'US',
    'Mark Rivera',
    'sales@pacific-components.example',
    '+1 305 000 0002',
    'Doral, Florida, United States',
    1
  )
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  country_code = VALUES(country_code),
  contact_name = VALUES(contact_name),
  email = VALUES(email),
  phone = VALUES(phone),
  address = VALUES(address),
  is_active = VALUES(is_active);

INSERT INTO customers (
  customer_type,
  name,
  tax_id,
  email,
  phone,
  address,
  is_active
)
VALUES
  (
    'wholesale',
    'Distribuidora Andina SpA',
    '76.123.456-7',
    'compras@andina.example',
    '+56 2 2000 0001',
    'Santiago, Chile',
    1
  ),
  (
    'retail',
    'Cliente Retail Demo',
    '19.876.543-2',
    'retail.demo@example',
    '+56 9 8000 0002',
    'Providencia, Chile',
    1
  )
ON DUPLICATE KEY UPDATE
  customer_type = VALUES(customer_type),
  name = VALUES(name),
  email = VALUES(email),
  phone = VALUES(phone),
  address = VALUES(address),
  is_active = VALUES(is_active);

INSERT INTO products (
  sku,
  name,
  description,
  unit_measure,
  default_sale_price_usd,
  is_active
)
VALUES
  (
    'SKU-ADAPTER-001',
    'Adaptador universal 65W',
    'Adaptador universal para equipos electronicos de consumo',
    'unit',
    42.0000,
    1
  ),
  (
    'SKU-CABLE-002',
    'Cable USB-C reforzado',
    'Cable USB-C de alta resistencia para venta retail y wholesale',
    'unit',
    12.5000,
    1
  )
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  unit_measure = VALUES(unit_measure),
  default_sale_price_usd = VALUES(default_sale_price_usd),
  is_active = VALUES(is_active);

INSERT INTO exchange_rate_snapshots (
  base_currency_code,
  quote_currency_code,
  rate,
  buy_rate,
  sell_rate,
  rate_date,
  source_name,
  source_url,
  buy_sell_source_name,
  buy_sell_source_url
)
VALUES
  (
    'USD',
    'CLP',
    950.000000,
    NULL,
    NULL,
    TIMESTAMP(CURDATE(), '12:00:00'),
    'manual_seed',
    'https://si3.bcentral.cl/siete/ES/Siete/Cuadro/CAP_TIPO_CAMBIO/MN_TIPO_CAMBIO4/DOLAR_OBS_ADO?idSerie=F073.TCO.PRE.Z.D',
    NULL,
    NULL
  )
ON DUPLICATE KEY UPDATE
  rate = VALUES(rate),
  buy_rate = VALUES(buy_rate),
  sell_rate = VALUES(sell_rate),
  source_name = VALUES(source_name),
  source_url = VALUES(source_url),
  buy_sell_source_name = VALUES(buy_sell_source_name),
  buy_sell_source_url = VALUES(buy_sell_source_url);
