const express = require("express");
const router = express.Router();
const { getDocs, addDoc, updateDoc, queryDocs } = require("../db");
const db = require("../db");

// Get farm details
router.get("/:farmer_id", async (req, res) => {
    try {
        const farmDetails = await queryDocs("farm_details", "farmer_id", "==", req.params.farmer_id);
        
        if (farmDetails.length === 0) {
            return res.json(null);
        }
        
        res.json(farmDetails[0]);
    } catch (error) {
        console.error("Farm details fetch error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

// Create or update farm details
router.post("/", async (req, res) => {
    try {
        const { farmer_id, farm_name, farm_address, farm_area, farm_type, crops_grown, livestock, certification, description } = req.body;

        if (!farmer_id) {
            return res.status(400).json({ message: "Farmer ID is required" });
        }

        // Check if farm details exist
        const existingFarms = await queryDocs("farm_details", "farmer_id", "==", farmer_id);

        if (existingFarms.length > 0) {
            // Update existing
            await updateDoc("farm_details", existingFarms[0].id, {
                farm_name,
                farm_address,
                farm_area: farm_area ? parseFloat(farm_area) : null,
                farm_type,
                crops_grown,
                livestock,
                certification,
                description
            });
            res.json({ message: "Farm details updated" });
        } else {
            // Insert new
            const farmData = {
                farmer_id,
                farm_name,
                farm_address,
                farm_area: farm_area ? parseFloat(farm_area) : null,
                farm_type,
                crops_grown,
                livestock,
                certification,
                description
            };
            const farmId = await addDoc("farm_details", farmData);
            res.status(201).json({ message: "Farm details created", id: farmId });
        }
    } catch (error) {
        console.error("Farm details create/update error:", error);
        res.status(500).json({ message: "Database error" });
    }
});

module.exports = router;

