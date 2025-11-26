-- Add phone number to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;

-- Add image_url to products table if not exists
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);

-- Create cart table
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (buyer_id, product_id)
);

-- Create subscriptions table for daily services
CREATE TABLE IF NOT EXISTS subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL,
    buyer_id INT NOT NULL,
    service_type ENUM('milk', 'vegetables', 'fruits', 'eggs', 'other') NOT NULL,
    product_id INT,
    quantity INT NOT NULL,
    frequency ENUM('daily', 'weekly', 'monthly') DEFAULT 'daily',
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('active', 'paused', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- Create farm_details table
CREATE TABLE IF NOT EXISTS farm_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    farmer_id INT NOT NULL UNIQUE,
    farm_name VARCHAR(255),
    farm_address TEXT,
    farm_area DECIMAL(10, 2),
    farm_type VARCHAR(100),
    crops_grown TEXT,
    livestock TEXT,
    certification VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Add total_amount to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_amount DECIMAL(10, 2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status ENUM('pending', 'paid', 'failed') DEFAULT 'pending';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;

