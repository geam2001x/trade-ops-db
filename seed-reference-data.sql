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
