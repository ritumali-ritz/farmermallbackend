-- Create banners table for offer banners
CREATE TABLE IF NOT EXISTS banners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    image_url VARCHAR(500) NOT NULL,
    link_url VARCHAR(500),
    display_order INT DEFAULT 0,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Add some dummy products with image URLs (using placeholder images)
-- Note: You can replace these with actual image URLs later

INSERT INTO products (farmer_id, name, price, quantity, description, image_url) VALUES
(1, 'Fresh Organic Tomatoes', 50.00, 100, 'Fresh red tomatoes from organic farm', '/uploads/dummy-tomatoes.jpg'),
(1, 'Organic Carrots', 40.00, 150, 'Sweet and crunchy organic carrots', '/uploads/dummy-carrots.jpg'),
(1, 'Fresh Spinach', 30.00, 200, 'Nutritious fresh spinach leaves', '/uploads/dummy-spinach.jpg'),
(1, 'Organic Potatoes', 35.00, 300, 'Fresh organic potatoes', '/uploads/dummy-potatoes.jpg'),
(1, 'Fresh Onions', 45.00, 250, 'Premium quality onions', '/uploads/dummy-onions.jpg'),
(1, 'Organic Bell Peppers', 60.00, 80, 'Colorful bell peppers', '/uploads/dummy-peppers.jpg'),
(1, 'Fresh Cucumbers', 25.00, 120, 'Crisp fresh cucumbers', '/uploads/dummy-cucumbers.jpg'),
(1, 'Organic Cauliflower', 55.00, 90, 'Fresh white cauliflower', '/uploads/dummy-cauliflower.jpg'),
(1, 'Fresh Broccoli', 70.00, 60, 'Nutritious green broccoli', '/uploads/dummy-broccoli.jpg'),
(1, 'Organic Green Beans', 50.00, 100, 'Tender green beans', '/uploads/dummy-beans.jpg'),
(1, 'Fresh Corn', 40.00, 150, 'Sweet corn on the cob', '/uploads/dummy-corn.jpg'),
(1, 'Organic Cabbage', 30.00, 200, 'Fresh green cabbage', '/uploads/dummy-cabbage.jpg'),
(1, 'Fresh Milk (1L)', 60.00, 50, 'Fresh cow milk', '/uploads/dummy-milk.jpg'),
(1, 'Farm Fresh Eggs (Dozen)', 80.00, 40, 'Fresh farm eggs', '/uploads/dummy-eggs.jpg'),
(1, 'Organic Wheat Flour (5kg)', 200.00, 30, 'Premium wheat flour', '/uploads/dummy-flour.jpg'),
(1, 'Fresh Mangoes (1kg)', 100.00, 25, 'Sweet ripe mangoes', '/uploads/dummy-mangoes.jpg'),
(1, 'Fresh Bananas (1kg)', 50.00, 100, 'Ripe yellow bananas', '/uploads/dummy-bananas.jpg'),
(1, 'Fresh Apples (1kg)', 120.00, 40, 'Crisp red apples', '/uploads/dummy-apples.jpg'),
(1, 'Fresh Oranges (1kg)', 80.00, 60, 'Juicy sweet oranges', '/uploads/dummy-oranges.jpg'),
(1, 'Organic Rice (5kg)', 250.00, 20, 'Premium basmati rice', '/uploads/dummy-rice.jpg')
ON DUPLICATE KEY UPDATE name=name;

-- Add some dummy banners (using placeholder image URLs)
INSERT INTO banners (title, image_url, link_url, display_order, status) VALUES
('Summer Sale - 50% Off', 'https://via.placeholder.com/800x300/10B981/FFFFFF?text=Summer+Sale+50%25+Off', '/products', 1, 'active'),
('Fresh Vegetables - Daily Delivery', 'https://via.placeholder.com/800x300/14B8A6/FFFFFF?text=Fresh+Vegetables+Daily+Delivery', '/products?category=vegetables', 2, 'active'),
('Organic Products - Best Quality', 'https://via.placeholder.com/800x300/F59E0B/FFFFFF?text=Organic+Products+Best+Quality', '/products?category=organic', 3, 'active'),
('New Arrivals - Check Now', 'https://via.placeholder.com/800x300/10B981/FFFFFF?text=New+Arrivals+Check+Now', '/products?sort=newest', 4, 'active')
ON DUPLICATE KEY UPDATE title=title;

