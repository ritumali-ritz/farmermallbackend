const mysql = require('mysql2');
const db = require('./db');

// Dummy products with placeholder images
const dummyProducts = [
    { name: 'Fresh Organic Tomatoes', price: 50.00, quantity: 100, description: 'Fresh red tomatoes from organic farm', image: 'https://images.unsplash.com/photo-1546470427-e26264be0d4b?w=400' },
    { name: 'Organic Carrots', price: 40.00, quantity: 150, description: 'Sweet and crunchy organic carrots', image: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400' },
    { name: 'Fresh Spinach', price: 30.00, quantity: 200, description: 'Nutritious fresh spinach leaves', image: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400' },
    { name: 'Organic Potatoes', price: 35.00, quantity: 300, description: 'Fresh organic potatoes', image: 'https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=400' },
    { name: 'Fresh Onions', price: 45.00, quantity: 250, description: 'Premium quality onions', image: 'https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=400' },
    { name: 'Organic Bell Peppers', price: 60.00, quantity: 80, description: 'Colorful bell peppers', image: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400' },
    { name: 'Fresh Cucumbers', price: 25.00, quantity: 120, description: 'Crisp fresh cucumbers', image: 'https://images.unsplash.com/photo-1604977049386-4b1a0df48d5a?w=400' },
    { name: 'Organic Cauliflower', price: 55.00, quantity: 90, description: 'Fresh white cauliflower', image: 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=400' },
    { name: 'Fresh Broccoli', price: 70.00, quantity: 60, description: 'Nutritious green broccoli', image: 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=400' },
    { name: 'Organic Green Beans', price: 50.00, quantity: 100, description: 'Tender green beans', image: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400' },
    { name: 'Fresh Corn', price: 40.00, quantity: 150, description: 'Sweet corn on the cob', image: 'https://images.unsplash.com/photo-1464454709131-ffd692591ee5?w=400' },
    { name: 'Organic Cabbage', price: 30.00, quantity: 200, description: 'Fresh green cabbage', image: 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400' },
    { name: 'Fresh Milk (1L)', price: 60.00, quantity: 50, description: 'Fresh cow milk', image: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400' },
    { name: 'Farm Fresh Eggs (Dozen)', price: 80.00, quantity: 40, description: 'Fresh farm eggs', image: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400' },
    { name: 'Organic Wheat Flour (5kg)', price: 200.00, quantity: 30, description: 'Premium wheat flour', image: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400' },
    { name: 'Fresh Mangoes (1kg)', price: 100.00, quantity: 25, description: 'Sweet ripe mangoes', image: 'https://images.unsplash.com/photo-1605027990121-c0a80a83b4e0?w=400' },
    { name: 'Fresh Bananas (1kg)', price: 50.00, quantity: 100, description: 'Ripe yellow bananas', image: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400' },
    { name: 'Fresh Apples (1kg)', price: 120.00, quantity: 40, description: 'Crisp red apples', image: 'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?w=400' },
    { name: 'Fresh Oranges (1kg)', price: 80.00, quantity: 60, description: 'Juicy sweet oranges', image: 'https://images.unsplash.com/photo-1580052614034-c55d20bfee3b?w=400' },
    { name: 'Organic Rice (5kg)', price: 250.00, quantity: 20, description: 'Premium basmati rice', image: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400' },
];

// Dummy banners
const dummyBanners = [
    { title: 'Summer Sale - 50% Off', image: 'https://via.placeholder.com/800x300/10B981/FFFFFF?text=Summer+Sale+50%25+Off', link: '/products', order: 1 },
    { title: 'Fresh Vegetables - Daily Delivery', image: 'https://via.placeholder.com/800x300/14B8A6/FFFFFF?text=Fresh+Vegetables+Daily+Delivery', link: '/products?category=vegetables', order: 2 },
    { title: 'Organic Products - Best Quality', image: 'https://via.placeholder.com/800x300/F59E0B/FFFFFF?text=Organic+Products+Best+Quality', link: '/products?category=organic', order: 3 },
    { title: 'New Arrivals - Check Now', image: 'https://via.placeholder.com/800x300/10B981/FFFFFF?text=New+Arrivals+Check+Now', link: '/products?sort=newest', order: 4 },
];

async function addDummyData() {
    try {
        // Get first farmer (or create one if doesn't exist)
        const [users] = await db.promise().query("SELECT id FROM users WHERE role = 'farmer' LIMIT 1");
        let farmerId;
        
        if (users.length === 0) {
            // Create a dummy farmer
            const [result] = await db.promise().query(
                "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)",
                ['Demo Farmer', 'farmer@demo.com', '$2a$10$dummy', 'farmer']
            );
            farmerId = result.insertId;
            console.log('Created demo farmer with ID:', farmerId);
        } else {
            farmerId = users[0].id;
            console.log('Using existing farmer with ID:', farmerId);
        }

        // Add dummy products
        console.log('\nAdding dummy products...');
        for (const product of dummyProducts) {
            try {
                await db.promise().query(
                    "INSERT INTO products (farmer_id, name, price, quantity, description, image_url) VALUES (?, ?, ?, ?, ?, ?)",
                    [farmerId, product.name, product.price, product.quantity, product.description, product.image]
                );
                console.log(`✓ Added: ${product.name}`);
            } catch (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    console.log(`- Skipped (exists): ${product.name}`);
                } else {
                    console.error(`✗ Error adding ${product.name}:`, err.message);
                }
            }
        }

        // Add dummy banners
        console.log('\nAdding dummy banners...');
        for (const banner of dummyBanners) {
            try {
                await db.promise().query(
                    "INSERT INTO banners (title, image_url, link_url, display_order, status) VALUES (?, ?, ?, ?, ?)",
                    [banner.title, banner.image, banner.link, banner.order, 'active']
                );
                console.log(`✓ Added banner: ${banner.title}`);
            } catch (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    console.log(`- Skipped (exists): ${banner.title}`);
                } else {
                    console.error(`✗ Error adding banner ${banner.title}:`, err.message);
                }
            }
        }

        console.log('\n✅ Dummy data added successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
}

addDummyData();

