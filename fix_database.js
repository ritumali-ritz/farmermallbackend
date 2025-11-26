const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', // Add your MySQL password here if needed
    database: 'farmer_mall',
    multipleStatements: true
});

connection.connect((err) => {
    if (err) {
        console.error('❌ Error connecting to MySQL:', err);
        process.exit(1);
    }
    console.log('✅ Connected to MySQL');

    const sql = `
        -- Create cart table if not exists
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

        -- Create subscriptions table if not exists
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

        -- Create banners table if not exists
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

        -- Add phone column to users if not exists
        ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
        -- Add address column to users if not exists
        ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT;

        -- Add image_url to products if not exists
        ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);
        
        -- Add description column if not exists (it should already exist, but just in case)
        ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT;

        -- Add total_amount and payment_status to orders if not exists
        ALTER TABLE orders ADD COLUMN IF NOT EXISTS total_amount DECIMAL(10, 2);
        ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status ENUM('pending', 'paid', 'failed') DEFAULT 'pending';
        ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
    `;

    connection.query(sql, (err, results) => {
        if (err) {
            console.error('❌ Error creating tables:', err);
            connection.end();
            process.exit(1);
        }
        console.log('✅ All tables created/updated successfully!');
        console.log('✅ Cart table: Ready');
        console.log('✅ Subscriptions table: Ready');
        console.log('✅ Banners table: Ready');
        connection.end();
        process.exit(0);
    });
});

