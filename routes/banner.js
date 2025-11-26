const express = require("express");
const router = express.Router();
const { getDocs, queryDocs } = require("../db");
const fs = require("fs");
const path = require("path");

// Helper function to normalize banner image URL
const normalizeBannerImageUrl = (imageUrl) => {
    if (!imageUrl) return null;
    
    // If already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return imageUrl;
    }
    
    // If already starts with /banner-files, return as is
    if (imageUrl.startsWith('/banner-files/')) {
        return imageUrl;
    }
    
    // Remove leading slash if present
    let normalized = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    
    // Ensure it points to banner-files
    if (!normalized.startsWith('banner-files/')) {
        normalized = `banner-files/${normalized}`;
    }
    
    return `/${normalized}`;
};

// Get banner files from banner folder
const getBannerFiles = () => {
    const bannerDir = path.join(__dirname, '..', 'banner');
    try {
        if (!fs.existsSync(bannerDir)) {
            return [];
        }
        const files = fs.readdirSync(bannerDir);
        return files.filter(file => {
            const ext = path.extname(file).toLowerCase();
            return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext);
        }).map(file => ({
            filename: file,
            path: `/banner-files/${file}`
        }));
    } catch (error) {
        console.error("Error reading banner folder:", error);
        return [];
    }
};

// Fallback banners from banner folder
const getFallbackBanners = () => {
    const bannerFiles = getBannerFiles();
    if (bannerFiles.length === 0) {
        // Return default banners if no files found
        return [
            {
                id: -1,
                title: "Organic Products - Best Quality",
                image_url: "/banner-files/Organic Products - Best Quality.jpg",
                link_url: "/products",
                display_order: 1,
                status: "active",
            },
            {
                id: -2,
                title: "Fresh Vegetables - Daily Delivery",
                image_url: "/banner-files/Fresh Vegetables - Daily Delivery.jpg",
                link_url: "/products?category=vegetables",
                display_order: 2,
                status: "active",
            },
            {
                id: -3,
                title: "New Arrivals - Check Now",
                image_url: "/banner-files/New Arrivals - Check Now.jpg",
                link_url: "/products?category=new",
                display_order: 3,
                status: "active",
            },
        ];
    }
    
    // Create banners from files in banner folder
    return bannerFiles.map((file, index) => ({
        id: -(index + 1),
        title: file.filename.replace(/\.[^/.]+$/, "").replace(/-/g, " "),
        image_url: file.path,
        link_url: "/products",
        display_order: index + 1,
        status: "active",
    }));
};

// Get active banners for app
router.get("/active", async (req, res) => {
    try {
        const banners = await queryDocs("banners", "status", "==", "active");
        
        if (!banners || banners.length === 0) {
            // Return fallback banners from banner folder
            const fallbackBanners = getFallbackBanners();
            return res.json(fallbackBanners);
        }
        
        // Sort by display_order
        banners.sort((a, b) => (a.display_order || 0) - (b.display_order || 0));
        
        // Normalize image URLs for all banners
        const normalizedBanners = banners.map(banner => ({
            ...banner,
            image_url: normalizeBannerImageUrl(banner.image_url || banner.imageUrl)
        }));
        
        res.json(normalizedBanners);
    } catch (error) {
        console.error("Banner fetch error:", error);
        // Return fallback banners from banner folder on error
        const fallbackBanners = getFallbackBanners();
        return res.json(fallbackBanners);
    }
});

module.exports = router;
