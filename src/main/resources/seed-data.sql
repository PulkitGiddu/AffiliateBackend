-- SnatchMart seed data – run manually in PostgreSQL after schema is created.
-- Requires: CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users
INSERT INTO user_login (id, email_id, username, first_name, last_name, password_hash, is_active, referral_code, created_at, updated_at)
VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'demo@snatchmart.com', 'demouser', 'Demo', 'User', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', true, 'DEMO001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 2. Merchants
INSERT INTO merchants (id, name, logo_url, created_at, updated_at)
VALUES
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Amazon', 'https://via.placeholder.com/100', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a23', 'Flipkart', 'https://via.placeholder.com/100', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 3. Categories
INSERT INTO categories (id, name, slug, parent_id, created_at, updated_at)
VALUES
('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'Electronics', 'electronics', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a32', 'Fashion', 'fashion', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'Home & Kitchen', 'home-kitchen', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('c4eebc99-9c0b-4ef8-bb6d-6bb9bd380a34', 'Books', 'books', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 4. Products
INSERT INTO products (id, product_name, description, product_unique_id, original_price, sale_price, review_score, review_count, affiliate_url, image_url, merchant_id, category_id, is_active, deals_expires_at, created_at, updated_at)
VALUES
('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 'Wireless Bluetooth Earbuds', 'Noise cancelling, 24hr battery', 'PROD-001', 2999.00, 1999.00, 4.5, 120, 'https://example.com/earbuds', 'https://picsum.photos/seed/1/400/400', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', true, CURRENT_TIMESTAMP + INTERVAL '7 days', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d2eebc99-9c0b-4ef8-bb6d-6bb9bd380a42', 'Smart Watch Pro', 'Heart rate, GPS, 50m water resistant', 'PROD-002', 8999.00, 5999.00, 4.2, 89, 'https://example.com/watch', 'https://picsum.photos/seed/2/400/400', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', true, CURRENT_TIMESTAMP + INTERVAL '3 days', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a43', 'Running Shoes', 'Lightweight, breathable mesh', 'PROD-003', 4999.00, 3499.00, 4.7, 256, 'https://example.com/shoes', 'https://picsum.photos/seed/3/400/400', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a23', 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a32', true, CURRENT_TIMESTAMP + INTERVAL '14 days', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d4eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'Stainless Steel Water Bottle', '1L, insulated, BPA free', 'PROD-004', 999.00, 599.00, 4.0, 45, 'https://example.com/bottle', 'https://picsum.photos/seed/4/400/400', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a23', 'c3eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', true, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('d5eebc99-9c0b-4ef8-bb6d-6bb9bd380a45', 'Best Seller Novel - Paperback', 'Top fiction pick of the month', 'PROD-005', 599.00, 399.00, 4.8, 1200, 'https://example.com/book', 'https://picsum.photos/seed/5/400/400', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'c4eebc99-9c0b-4ef8-bb6d-6bb9bd380a34', true, CURRENT_TIMESTAMP + INTERVAL '1 day', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 5. Coupons
INSERT INTO coupons (id, code, description, discount_type, discount_value, expiry_at, merchant_id, is_active, created_at, updated_at)
VALUES
(uuid_generate_v4(), 'SAVE10', '10% off on first order', 'PERCENT', 10.00, CURRENT_TIMESTAMP + INTERVAL '30 days', 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(uuid_generate_v4(), 'FLAT500', 'Rs 500 off on orders above Rs 2999', 'FLAT', 500.00, CURRENT_TIMESTAMP + INTERVAL '14 days', 'b2eebc99-9c0b-4ef8-bb6d-6bb9bd380a23', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 6. Notifications (for demo user)
INSERT INTO notifications (id, user_id, message, is_read, created_at)
VALUES
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Welcome to SnatchMart! Check out today''s top deals.', false, CURRENT_TIMESTAMP),
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Price drop alert: Wireless Earbuds now at Rs 1999.', false, CURRENT_TIMESTAMP);

-- 7. Price history for first product
INSERT INTO product_price_history (id, product_id, price, recorded_at)
VALUES
(uuid_generate_v4(), 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 2999.00, CURRENT_TIMESTAMP - INTERVAL '2 days'),
(uuid_generate_v4(), 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 2499.00, CURRENT_TIMESTAMP - INTERVAL '1 day'),
(uuid_generate_v4(), 'd1eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 1999.00, CURRENT_TIMESTAMP);
