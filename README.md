# farmermallbackend
A full-stack mobile–backend system designed to help farmers manage and sell their products, built using Flutter (frontend) and Node.js + MySQL (backend).
The project focuses on simplicity, offline-friendly workflows, clean UI, and fast performance.

🚀 Features
✅ Farmer Features

Register/Login using phone/email

Add products with details:

Product name

Price

Quantity

Description

View all products added

Edit product details

Delete products

Instant feedback for success or errors

Very fast backend because no JWT / no Express — simple HTTP routing

🔐 Authentication (No JWT)

Simple and secure login system

Passwords encrypted using SHA-256 hashing

Sessionless backend (mobile app handles user logic)

🗄️ Backend Tech Stack

Node.js – using native http module

MySQL (mysql2) – fast and reliable

dotenv for environment config

crypto for SHA-256 password hashing

MVC pattern for clean structure

📁 Backend Folder Structure
farmer_mall_backend/
│── server.js
│── db.js
│── controllers/
│   └── authController.js
│   └── productController.js
│── routes/
│   └── auth.js
│   └── products.js
│── models/
│   └── userModel.js
│   └── productModel.js
│── utils/
│   └── helper.js
│── .env
│── package.json

📱 Flutter App Features

Clean UI

Add / View / Update / Delete products

API integration using http package

Loading indicators

Error + success toast messages

Fully responsive

Works both on Android & iOS

🔗 API Endpoints
Auth
Method	Endpoint	Description
POST	/auth/register	Register a new farmer
POST	/auth/login	Login farmer
Products
Method	Endpoint	Description
POST	/products/add	Add new product
GET	/products/list?farmer_id=ID	Get farmer’s products
PUT	/products/update/:id	Update product
DELETE	/products/delete/:id	Delete product
🛠️ Setup Instructions
Backend
git clone <repo>
cd farmer_mall_backend
npm install
npm start

Flutter App
cd farmer_mall_app
flutter pub get
flutter run

📚 Database Tables
Users
id (int)
name
email
phone
password (hashed)
created_at

Products
id (int)
farmer_id (int)
name
price
quantity
description
created_at

⭐ Why This Project?

This app is built to:

help farmers digitize their product management

learn a complete Flutter + Node.js + MySQL stack

demonstrate clean architecture for portfolio/GitHub

prepare for real startup-style product development
