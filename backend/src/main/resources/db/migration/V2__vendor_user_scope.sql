ALTER TABLE app_users ADD COLUMN vendor_id BIGINT NULL;
ALTER TABLE app_users ADD CONSTRAINT fk_user_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(id);
CREATE INDEX idx_user_vendor ON app_users(vendor_id);
