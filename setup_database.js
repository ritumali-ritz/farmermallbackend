const mysql = require("mysql2");

// Create connection without database first
const connection = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "",
});

connection.connect((err) => {
    if (err) {
        console.error("❌ Error connecting to MySQL:", err);
        process.exit(1);
    }
    console.log("✅ Connected to MySQL server");

    // Create database
    connection.query("CREATE DATABASE IF NOT EXISTS farmer_mall", (err) => {
        if (err) {
            console.error("❌ Error creating database:", err);
            connection.end();
            process.exit(1);
        }
        console.log("✅ Database 'farmer_mall' created or already exists");

        // Use the database
        connection.query("USE farmer_mall", (err) => {
            if (err) {
                console.error("❌ Error using database:", err);
                connection.end();
                process.exit(1);
            }

            // Create users table
            const createUsersTable = `
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    email VARCHAR(255) NOT NULL UNIQUE,
                    password VARCHAR(255) NOT NULL,
                    role ENUM('farmer', 'buyer') NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            `;

            connection.query(createUsersTable, (err) => {
                if (err) {
                    console.error("❌ Error creating users table:", err);
                    connection.end();
                    process.exit(1);
                }
                console.log("✅ Users table created or already exists");

                // Create products table
                const createProductsTable = `
                    CREATE TABLE IF NOT EXISTS products (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        farmer_id INT NOT NULL,
                        name VARCHAR(255) NOT NULL,
                        price DECIMAL(10, 2) NOT NULL,
                        quantity INT NOT NULL,
                        description TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE
                    )
                `;

                connection.query(createProductsTable, (err) => {
                    if (err) {
                        console.error("❌ Error creating products table:", err);
                        connection.end();
                        process.exit(1);
                    }
                    console.log("✅ Products table created or already exists");

                    // Create orders table
                    const createOrdersTable = `
                        CREATE TABLE IF NOT EXISTS orders (
                            id INT AUTO_INCREMENT PRIMARY KEY,
                            buyer_id INT NOT NULL,
                            product_id INT NOT NULL,
                            farmer_id INT NOT NULL,
                            quantity INT NOT NULL,
                            status ENUM('pending', 'confirmed', 'delivered', 'cancelled') DEFAULT 'pending',
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                            FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
                            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
                            FOREIGN KEY (farmer_id) REFERENCES users(id) ON DELETE CASCADE
                        )
                    `;

                    connection.query(createOrdersTable, (err) => {
                        if (err) {
                            console.error("❌ Error creating orders table:", err);
                            connection.end();
                            process.exit(1);
                        }
                        console.log("✅ Orders table created or already exists");
                        console.log("\n🎉 Database setup complete!");
                        connection.end();
                    });
                });
            });
        });
    });
});

