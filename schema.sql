CREATE DATABASE IF NOT EXISTS trade_operations_suite
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE trade_operations_suite;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS profitability_snapshots;
DROP TABLE IF EXISTS landed_cost_allocations;
DROP TABLE IF EXISTS sales_order_item_lots;
DROP TABLE IF EXISTS sales_order_items;
DROP TABLE IF EXISTS sales_orders;
DROP TABLE IF EXISTS purchase_order_checkpoint_events;
DROP TABLE IF EXISTS inventory_movements;
DROP TABLE IF EXISTS inventory_lots;
DROP TABLE IF EXISTS import_expenses;
DROP TABLE IF EXISTS customs_entries;
DROP TABLE IF EXISTS shipment_events;
DROP TABLE IF EXISTS shipment_items;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS purchase_order_items;
DROP TABLE IF EXISTS purchase_orders;
DROP TABLE IF EXISTS purchase_quotation_items;
DROP TABLE IF EXISTS purchase_quotations;
DROP TABLE IF EXISTS document_validations;
DROP TABLE IF EXISTS document_extraction_items;
DROP TABLE IF EXISTS document_extractions;
DROP TABLE IF EXISTS document_uploads;
DROP TABLE IF EXISTS exchange_rate_snapshots;
DROP TABLE IF EXISTS currencies;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  description VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_roles_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_roles (
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user
    FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_user_roles_role
    FOREIGN KEY (role_id) REFERENCES roles (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE suppliers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(180) NOT NULL,
  tax_id VARCHAR(64) NULL,
  country_code CHAR(2) NOT NULL,
  contact_name VARCHAR(150) NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(80) NULL,
  address VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_suppliers_tax_id (tax_id),
  KEY idx_suppliers_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_type VARCHAR(32) NOT NULL,
  name VARCHAR(180) NOT NULL,
  tax_id VARCHAR(64) NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(80) NULL,
  address VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customers_tax_id (tax_id),
  KEY idx_customers_name (name),
  KEY idx_customers_type (customer_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sku VARCHAR(80) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  unit_measure VARCHAR(32) NOT NULL,
  default_sale_price_usd DECIMAL(18, 4) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE warehouses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  location VARCHAR(180) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_warehouses_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE currencies (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code CHAR(3) NOT NULL,
  name VARCHAR(64) NOT NULL,
  symbol VARCHAR(8) NULL,
  is_base_currency TINYINT(1) NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_currencies_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exchange_rate_snapshots (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  base_currency_code CHAR(3) NOT NULL,
  quote_currency_code CHAR(3) NOT NULL,
  rate DECIMAL(18, 6) NOT NULL,
  rate_date DATETIME NOT NULL,
  source_name VARCHAR(120) NOT NULL,
  fetched_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_exchange_rate_snapshots_pair_date (
    base_currency_code,
    quote_currency_code,
    rate_date
  ),
  KEY idx_exchange_rate_snapshots_rate_date (rate_date),
  CONSTRAINT fk_exchange_rate_snapshots_base_currency
    FOREIGN KEY (base_currency_code) REFERENCES currencies (code),
  CONSTRAINT fk_exchange_rate_snapshots_quote_currency
    FOREIGN KEY (quote_currency_code) REFERENCES currencies (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE document_uploads (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  document_type VARCHAR(64) NOT NULL,
  original_file_name VARCHAR(255) NOT NULL,
  storage_path VARCHAR(255) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  uploaded_by_user_id BIGINT UNSIGNED NOT NULL,
  status VARCHAR(64) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_document_uploads_type (document_type),
  KEY idx_document_uploads_status (status),
  CONSTRAINT fk_document_uploads_uploaded_by_user
    FOREIGN KEY (uploaded_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE document_extractions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  document_upload_id BIGINT UNSIGNED NOT NULL,
  detected_document_type VARCHAR(64) NOT NULL,
  raw_text LONGTEXT NULL,
  structured_payload_json JSON NULL,
  confidence_score DECIMAL(5, 4) NULL,
  status VARCHAR(64) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_document_extractions_status (status),
  CONSTRAINT fk_document_extractions_document_upload
    FOREIGN KEY (document_upload_id) REFERENCES document_uploads (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE document_extraction_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  document_extraction_id BIGINT UNSIGNED NOT NULL,
  line_index INT UNSIGNED NOT NULL,
  product_description VARCHAR(255) NOT NULL,
  sku_detected VARCHAR(80) NULL,
  quantity DECIMAL(18, 4) NOT NULL,
  unit_measure VARCHAR(32) NULL,
  unit_price DECIMAL(18, 4) NULL,
  line_total DECIMAL(18, 4) NULL,
  confidence_score DECIMAL(5, 4) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_document_extraction_items_line_index (line_index),
  CONSTRAINT fk_document_extraction_items_extraction
    FOREIGN KEY (document_extraction_id) REFERENCES document_extractions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE document_validations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  document_extraction_id BIGINT UNSIGNED NOT NULL,
  validated_by_user_id BIGINT UNSIGNED NOT NULL,
  validated_payload_json JSON NOT NULL,
  validation_notes TEXT NULL,
  validated_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_document_validations_extraction (document_extraction_id),
  CONSTRAINT fk_document_validations_extraction
    FOREIGN KEY (document_extraction_id) REFERENCES document_extractions (id),
  CONSTRAINT fk_document_validations_user
    FOREIGN KEY (validated_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE purchase_quotations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  supplier_id BIGINT UNSIGNED NOT NULL,
  source_document_upload_id BIGINT UNSIGNED NULL,
  quotation_number VARCHAR(100) NOT NULL,
  quotation_date DATE NOT NULL,
  currency_code CHAR(3) NOT NULL,
  incoterm VARCHAR(32) NULL,
  lead_time_days INT UNSIGNED NULL,
  notes TEXT NULL,
  status VARCHAR(64) NOT NULL,
  created_by_user_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_purchase_quotations_supplier_number (supplier_id, quotation_number),
  KEY idx_purchase_quotations_status (status),
  CONSTRAINT fk_purchase_quotations_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
  CONSTRAINT fk_purchase_quotations_source_document
    FOREIGN KEY (source_document_upload_id) REFERENCES document_uploads (id),
  CONSTRAINT fk_purchase_quotations_currency
    FOREIGN KEY (currency_code) REFERENCES currencies (code),
  CONSTRAINT fk_purchase_quotations_created_by_user
    FOREIGN KEY (created_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE purchase_quotation_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  purchase_quotation_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NULL,
  product_description VARCHAR(255) NOT NULL,
  quantity DECIMAL(18, 4) NOT NULL,
  unit_measure VARCHAR(32) NOT NULL,
  unit_price_original DECIMAL(18, 4) NOT NULL,
  exchange_rate_to_usd DECIMAL(18, 6) NOT NULL DEFAULT 1,
  unit_price_usd DECIMAL(18, 4) NOT NULL,
  line_total_original DECIMAL(18, 4) NOT NULL,
  line_total_usd DECIMAL(18, 4) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_purchase_quotation_items_quotation (purchase_quotation_id),
  CONSTRAINT fk_purchase_quotation_items_quotation
    FOREIGN KEY (purchase_quotation_id) REFERENCES purchase_quotations (id),
  CONSTRAINT fk_purchase_quotation_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE purchase_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  supplier_id BIGINT UNSIGNED NOT NULL,
  purchase_quotation_id BIGINT UNSIGNED NULL,
  proforma_document_upload_id BIGINT UNSIGNED NULL,
  invoice_document_upload_id BIGINT UNSIGNED NULL,
  order_number VARCHAR(100) NOT NULL,
  order_date DATE NOT NULL,
  supplier_invoice_number VARCHAR(100) NULL,
  supplier_invoice_date DATE NULL,
  currency_code CHAR(3) NOT NULL,
  payment_terms VARCHAR(120) NULL,
  estimated_dispatch_date DATE NULL,
  notes TEXT NULL,
  status VARCHAR(64) NOT NULL,
  current_checkpoint_status VARCHAR(64) NOT NULL DEFAULT 'quotation',
  current_checkpoint_updated_at DATETIME NULL,
  created_by_user_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_purchase_orders_order_number (order_number),
  KEY idx_purchase_orders_status (status),
  CONSTRAINT fk_purchase_orders_supplier
    FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
  CONSTRAINT fk_purchase_orders_quotation
    FOREIGN KEY (purchase_quotation_id) REFERENCES purchase_quotations (id),
  CONSTRAINT fk_purchase_orders_proforma_document
    FOREIGN KEY (proforma_document_upload_id) REFERENCES document_uploads (id),
  CONSTRAINT fk_purchase_orders_invoice_document
    FOREIGN KEY (invoice_document_upload_id) REFERENCES document_uploads (id),
  CONSTRAINT fk_purchase_orders_currency
    FOREIGN KEY (currency_code) REFERENCES currencies (code),
  CONSTRAINT fk_purchase_orders_created_by_user
    FOREIGN KEY (created_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE purchase_order_checkpoint_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  purchase_order_id BIGINT UNSIGNED NOT NULL,
  from_checkpoint VARCHAR(64) NULL,
  to_checkpoint VARCHAR(64) NOT NULL,
  changed_by_user_id BIGINT UNSIGNED NOT NULL,
  changed_at DATETIME NOT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_purchase_order_checkpoint_events_order (purchase_order_id),
  KEY idx_purchase_order_checkpoint_events_changed_at (changed_at),
  CONSTRAINT fk_purchase_order_checkpoint_events_order
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
  CONSTRAINT fk_purchase_order_checkpoint_events_user
    FOREIGN KEY (changed_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE purchase_order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  purchase_order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  product_description_snapshot VARCHAR(255) NOT NULL,
  quantity_ordered DECIMAL(18, 4) NOT NULL,
  quantity_received DECIMAL(18, 4) NOT NULL DEFAULT 0,
  unit_measure VARCHAR(32) NOT NULL,
  unit_price_original DECIMAL(18, 4) NOT NULL,
  exchange_rate_to_usd DECIMAL(18, 6) NOT NULL DEFAULT 1,
  unit_price_usd DECIMAL(18, 4) NOT NULL,
  line_total_original DECIMAL(18, 4) NOT NULL,
  line_total_usd DECIMAL(18, 4) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_purchase_order_items_order (purchase_order_id),
  CONSTRAINT fk_purchase_order_items_order
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id),
  CONSTRAINT fk_purchase_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  purchase_order_id BIGINT UNSIGNED NOT NULL,
  shipment_number VARCHAR(100) NOT NULL,
  transport_mode VARCHAR(32) NOT NULL,
  carrier_name VARCHAR(150) NULL,
  origin_location VARCHAR(150) NULL,
  destination_location VARCHAR(150) NULL,
  tracking_reference VARCHAR(120) NULL,
  etd DATE NULL,
  eta DATE NULL,
  actual_departure_at DATETIME NULL,
  actual_arrival_at DATETIME NULL,
  status VARCHAR(64) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_shipments_number (shipment_number),
  KEY idx_shipments_status (status),
  CONSTRAINT fk_shipments_purchase_order
    FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  shipment_id BIGINT UNSIGNED NOT NULL,
  purchase_order_item_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  quantity_shipped DECIMAL(18, 4) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_shipment_items_shipment (shipment_id),
  CONSTRAINT fk_shipment_items_shipment
    FOREIGN KEY (shipment_id) REFERENCES shipments (id),
  CONSTRAINT fk_shipment_items_purchase_order_item
    FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_items (id),
  CONSTRAINT fk_shipment_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shipment_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  shipment_id BIGINT UNSIGNED NOT NULL,
  event_type VARCHAR(64) NOT NULL,
  event_date DATETIME NOT NULL,
  location VARCHAR(150) NULL,
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_shipment_events_date (event_date),
  CONSTRAINT fk_shipment_events_shipment
    FOREIGN KEY (shipment_id) REFERENCES shipments (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customs_entries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  shipment_id BIGINT UNSIGNED NOT NULL,
  entry_number VARCHAR(100) NOT NULL,
  arrival_date_chile DATE NULL,
  clearance_date DATE NULL,
  status VARCHAR(64) NOT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customs_entries_number (entry_number),
  KEY idx_customs_entries_status (status),
  CONSTRAINT fk_customs_entries_shipment
    FOREIGN KEY (shipment_id) REFERENCES shipments (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE import_expenses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customs_entry_id BIGINT UNSIGNED NOT NULL,
  expense_type VARCHAR(64) NOT NULL,
  expense_date DATE NOT NULL,
  currency_code CHAR(3) NOT NULL,
  amount_original DECIMAL(18, 4) NOT NULL,
  exchange_rate_to_usd DECIMAL(18, 6) NOT NULL DEFAULT 1,
  amount_usd DECIMAL(18, 4) NOT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_import_expenses_type (expense_type),
  CONSTRAINT fk_import_expenses_customs_entry
    FOREIGN KEY (customs_entry_id) REFERENCES customs_entries (id),
  CONSTRAINT fk_import_expenses_currency
    FOREIGN KEY (currency_code) REFERENCES currencies (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_lots (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  purchase_order_item_id BIGINT UNSIGNED NOT NULL,
  shipment_item_id BIGINT UNSIGNED NULL,
  warehouse_id BIGINT UNSIGNED NOT NULL,
  lot_code VARCHAR(100) NOT NULL,
  received_quantity DECIMAL(18, 4) NOT NULL,
  available_quantity DECIMAL(18, 4) NOT NULL,
  reserved_quantity DECIMAL(18, 4) NOT NULL DEFAULT 0,
  status VARCHAR(64) NOT NULL,
  received_at DATETIME NOT NULL,
  purchase_unit_cost_usd DECIMAL(18, 4) NOT NULL,
  allocated_import_cost_usd DECIMAL(18, 4) NOT NULL DEFAULT 0,
  unit_landed_cost_usd DECIMAL(18, 4) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inventory_lots_code (lot_code),
  KEY idx_inventory_lots_status (status),
  CONSTRAINT fk_inventory_lots_product
    FOREIGN KEY (product_id) REFERENCES products (id),
  CONSTRAINT fk_inventory_lots_purchase_order_item
    FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_items (id),
  CONSTRAINT fk_inventory_lots_shipment_item
    FOREIGN KEY (shipment_item_id) REFERENCES shipment_items (id),
  CONSTRAINT fk_inventory_lots_warehouse
    FOREIGN KEY (warehouse_id) REFERENCES warehouses (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inventory_movements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  inventory_lot_id BIGINT UNSIGNED NOT NULL,
  movement_type VARCHAR(64) NOT NULL,
  quantity DECIMAL(18, 4) NOT NULL,
  reference_type VARCHAR(64) NULL,
  reference_id BIGINT UNSIGNED NULL,
  movement_date DATETIME NOT NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_inventory_movements_date (movement_date),
  CONSTRAINT fk_inventory_movements_lot
    FOREIGN KEY (inventory_lot_id) REFERENCES inventory_lots (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sales_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NULL,
  sale_type VARCHAR(32) NOT NULL,
  order_number VARCHAR(100) NOT NULL,
  order_date DATE NOT NULL,
  currency_code CHAR(3) NOT NULL,
  exchange_rate_to_usd DECIMAL(18, 6) NOT NULL DEFAULT 1,
  total_original DECIMAL(18, 4) NOT NULL,
  total_usd DECIMAL(18, 4) NOT NULL,
  status VARCHAR(64) NOT NULL,
  customer_name_snapshot VARCHAR(180) NULL,
  customer_tax_id_snapshot VARCHAR(64) NULL,
  notes TEXT NULL,
  created_by_user_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sales_orders_order_number (order_number),
  KEY idx_sales_orders_status (status),
  KEY idx_sales_orders_sale_type (sale_type),
  CONSTRAINT fk_sales_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id),
  CONSTRAINT fk_sales_orders_currency
    FOREIGN KEY (currency_code) REFERENCES currencies (code),
  CONSTRAINT fk_sales_orders_created_by_user
    FOREIGN KEY (created_by_user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sales_order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sales_order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  product_description_snapshot VARCHAR(255) NOT NULL,
  quantity DECIMAL(18, 4) NOT NULL,
  unit_price_original DECIMAL(18, 4) NOT NULL,
  unit_price_usd DECIMAL(18, 4) NOT NULL,
  line_total_original DECIMAL(18, 4) NOT NULL,
  line_total_usd DECIMAL(18, 4) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sales_order_items_order (sales_order_id),
  CONSTRAINT fk_sales_order_items_sales_order
    FOREIGN KEY (sales_order_id) REFERENCES sales_orders (id),
  CONSTRAINT fk_sales_order_items_product
    FOREIGN KEY (product_id) REFERENCES products (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sales_order_item_lots (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sales_order_item_id BIGINT UNSIGNED NOT NULL,
  inventory_lot_id BIGINT UNSIGNED NOT NULL,
  quantity_consumed DECIMAL(18, 4) NOT NULL,
  unit_landed_cost_usd_snapshot DECIMAL(18, 4) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sales_order_item_lots_sales_item (sales_order_item_id),
  CONSTRAINT fk_sales_order_item_lots_sales_order_item
    FOREIGN KEY (sales_order_item_id) REFERENCES sales_order_items (id),
  CONSTRAINT fk_sales_order_item_lots_inventory_lot
    FOREIGN KEY (inventory_lot_id) REFERENCES inventory_lots (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE landed_cost_allocations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  inventory_lot_id BIGINT UNSIGNED NOT NULL,
  import_expense_id BIGINT UNSIGNED NOT NULL,
  allocated_amount_usd DECIMAL(18, 4) NOT NULL,
  allocation_method VARCHAR(32) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_landed_cost_allocations_method (allocation_method),
  CONSTRAINT fk_landed_cost_allocations_inventory_lot
    FOREIGN KEY (inventory_lot_id) REFERENCES inventory_lots (id),
  CONSTRAINT fk_landed_cost_allocations_import_expense
    FOREIGN KEY (import_expense_id) REFERENCES import_expenses (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE profitability_snapshots (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sales_order_id BIGINT UNSIGNED NOT NULL,
  sales_order_item_id BIGINT UNSIGNED NULL,
  inventory_lot_id BIGINT UNSIGNED NULL,
  revenue_usd DECIMAL(18, 4) NOT NULL,
  cost_usd DECIMAL(18, 4) NOT NULL,
  gross_margin_usd DECIMAL(18, 4) NOT NULL,
  roi_percent DECIMAL(18, 4) NULL,
  snapshot_date DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_profitability_snapshots_date (snapshot_date),
  CONSTRAINT fk_profitability_snapshots_sales_order
    FOREIGN KEY (sales_order_id) REFERENCES sales_orders (id),
  CONSTRAINT fk_profitability_snapshots_sales_order_item
    FOREIGN KEY (sales_order_item_id) REFERENCES sales_order_items (id),
  CONSTRAINT fk_profitability_snapshots_inventory_lot
    FOREIGN KEY (inventory_lot_id) REFERENCES inventory_lots (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
