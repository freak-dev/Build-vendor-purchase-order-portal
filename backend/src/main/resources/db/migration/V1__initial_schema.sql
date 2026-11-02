CREATE TABLE app_users (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, username VARCHAR(80) NOT NULL UNIQUE,
 password_hash VARCHAR(100) NOT NULL, role VARCHAR(32) NOT NULL, enabled BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE vendors (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(160) NOT NULL, email VARCHAR(254) NOT NULL UNIQUE,
 phone VARCHAR(32), address VARCHAR(500), active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE products (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, sku VARCHAR(64) NOT NULL UNIQUE, name VARCHAR(160) NOT NULL,
 description VARCHAR(1000), category VARCHAR(100) NOT NULL, unit_price DECIMAL(12,2) NOT NULL,
 stock_quantity INT NOT NULL DEFAULT 0, reorder_threshold INT NOT NULL DEFAULT 10, active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT chk_product_price CHECK(unit_price >= 0),
 CONSTRAINT chk_product_stock CHECK(stock_quantity >= 0), CONSTRAINT chk_product_reorder CHECK(reorder_threshold >= 0)
);
CREATE TABLE purchase_orders (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, po_number VARCHAR(32) NOT NULL UNIQUE, vendor_id BIGINT NOT NULL,
 status VARCHAR(24) NOT NULL, notes VARCHAR(2000), subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
 created_by BIGINT NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CONSTRAINT fk_po_vendor FOREIGN KEY(vendor_id) REFERENCES vendors(id),
 CONSTRAINT fk_po_user FOREIGN KEY(created_by) REFERENCES app_users(id), INDEX idx_po_status_created(status, created_at), INDEX idx_po_vendor(vendor_id)
);
CREATE TABLE purchase_order_items (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, purchase_order_id BIGINT NOT NULL, product_id BIGINT NOT NULL,
 quantity INT NOT NULL, unit_price DECIMAL(12,2) NOT NULL,
 CONSTRAINT fk_item_po FOREIGN KEY(purchase_order_id) REFERENCES purchase_orders(id),
 CONSTRAINT fk_item_product FOREIGN KEY(product_id) REFERENCES products(id),
 CONSTRAINT chk_item_quantity CHECK(quantity > 0), INDEX idx_poi_po(purchase_order_id)
);
CREATE TABLE inventory_transactions (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, product_id BIGINT NOT NULL, user_id BIGINT NOT NULL,
 transaction_type VARCHAR(32) NOT NULL, quantity_change INT NOT NULL, reference VARCHAR(64), note VARCHAR(500),
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_inv_product FOREIGN KEY(product_id) REFERENCES products(id),
 CONSTRAINT fk_inv_user FOREIGN KEY(user_id) REFERENCES app_users(id), INDEX idx_inv_product_date(product_id, created_at)
);
CREATE TABLE audit_logs (
 id BIGINT PRIMARY KEY AUTO_INCREMENT, user_id BIGINT, action VARCHAR(100) NOT NULL, entity_type VARCHAR(50) NOT NULL,
 entity_id BIGINT, detail VARCHAR(1000), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_audit_user FOREIGN KEY(user_id) REFERENCES app_users(id), INDEX idx_audit_date(created_at)
);
