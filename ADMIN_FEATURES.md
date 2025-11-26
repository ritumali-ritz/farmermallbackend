# Admin Dashboard Features

## 🎯 What's Been Added

### 1. **Admin Web Dashboard** (`admin_dashboard/index.html`)
A complete admin panel with:
- **Dashboard Overview**: Statistics (users, farmers, buyers, products, orders)
- **User Management**: View and delete users
- **Farmer Management**: View all farmers with product counts
- **Product Management**: View and delete products
- **Banner Management**: Add, edit, delete offer banners

### 2. **Banner System**
- Banner carousel on home screen (like Flipkart)
- Auto-scrolling banners
- Admin can upload banner images
- Admin can set banner order and status
- Banners can link to products or pages

### 3. **Dummy Products**
- 20 dummy products with real images (from Unsplash)
- Products include vegetables, fruits, dairy, grains
- All products have images, prices, descriptions

### 4. **Backend Routes**
- `/admin/users` - Get all users
- `/admin/farmers` - Get all farmers
- `/admin/products` - Get all products
- `/admin/banners` - Manage banners
- `/admin/stats` - Get statistics
- `/banner/active` - Get active banners for app

## 🚀 How to Use

### 1. **Set Up Database**
```bash
# Run the database updates
mysql -u root -p farmer_mall < database_updates_banners.sql

# Add dummy data
node add_dummy_data.js
```

### 2. **Access Admin Dashboard**
1. Open `admin_dashboard/index.html` in your browser
2. Or serve it: `python -m http.server 8000` (in admin_dashboard folder)
3. Access at: `http://localhost:8000`

### 3. **Add Banners**
1. Go to "Banners" section in admin dashboard
2. Click "Add New Banner"
3. Enter:
   - Title (optional)
   - Image URL (upload image first using `/upload/banner` endpoint)
   - Link URL (where banner should navigate)
   - Display Order (1, 2, 3...)
   - Status (active/inactive)
4. Click "Save Banner"

### 4. **Upload Banner Images**
You can upload banner images using:
- Admin dashboard (if you add file upload)
- Or use Postman/curl to POST to `/upload/banner`

## 📱 App Features

### Banner Carousel
- Auto-scrolling banners at top of product list
- Swipeable carousel
- Dot indicators
- Tap banners to navigate (if link set)

### Products
- 20+ dummy products with images
- All products visible in app
- Real product images from Unsplash

## 🎨 Admin Dashboard Features

### Dashboard Tab
- Total Users count
- Total Farmers count
- Total Buyers count
- Total Products count
- Total Orders count

### Users Tab
- View all users
- See user details (name, email, phone, role)
- Delete users

### Farmers Tab
- View all farmers
- See product count per farmer
- Delete farmers

### Products Tab
- View all products
- See product images
- See farmer info
- Delete products

### Banners Tab
- View all banners
- Add new banners
- Edit existing banners
- Delete banners
- Set display order
- Activate/deactivate banners

## 🔧 Technical Details

### Banner Model
```dart
class Banner {
  int id;
  String? title;
  String imageUrl;
  String? linkUrl;
  int displayOrder;
  String status;
}
```

### Banner API Endpoints
- `GET /banner/active` - Get active banners for app
- `GET /admin/banners/all` - Get all banners (admin)
- `POST /admin/banners` - Create banner
- `PUT /admin/banners/:id` - Update banner
- `DELETE /admin/banners/:id` - Delete banner

### Upload Endpoints
- `POST /upload/product` - Upload product image
- `POST /upload/banner` - Upload banner image

## 📝 Notes

- Banner images can be:
  - External URLs (https://example.com/image.jpg)
  - Local uploads (/uploads/banner-xxx.jpg)
- Products use Unsplash images (free, no API key needed)
- Admin dashboard is a single HTML file (no build needed)
- All admin operations are available via API

## 🎯 Next Steps

1. Run `node add_dummy_data.js` to add products and banners
2. Open admin dashboard
3. Customize banners as needed
4. Test banner carousel in app

