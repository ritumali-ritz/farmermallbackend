const mysql = require('mysql2');
const fs = require('fs');
const path = require('path');

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', // Add your MySQL password here if needed
    multipleStatements: true
});

connection.connect((err) => {
    if (err) {
        console.error('❌ Error connecting to MySQL:', err);
        process.exit(1);
    }
    console.log('✅ Connected to MySQL');

    // Read and execute all SQL files
    const sqlFiles = [
        'setup_database.sql',
        'database_updates.sql',
        'database_updates_banners.sql'
    ];

    let sqlContent = '';

    sqlFiles.forEach(file => {
        const filePath = path.join(__dirname, file);
        if (fs.existsSync(filePath)) {
            sqlContent += fs.readFileSync(filePath, 'utf8') + '\n';
            console.log(`✅ Read ${file}`);
        }
    });

    // Execute all SQL
    connection.query(sqlContent, (err, results) => {
        if (err) {
            console.error('❌ Error executing SQL:', err);
            connection.end();
            process.exit(1);
        }
        console.log('✅ All tables created/updated successfully!');
        connection.end();
        process.exit(0);
    });
});

