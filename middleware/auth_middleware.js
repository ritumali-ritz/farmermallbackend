const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
    const authHeader = req.headers["authorization"];

    if (!authHeader) {
        return res.status(401).json({ message: "No token provided" });
    }

    const token = authHeader.startsWith("Bearer ")
        ? authHeader.substring(7)
        : authHeader;

    jwt.verify(token, "FARMER_MALL_SECRET_KEY", (err, decoded) => {
        if (err) return res.status(401).json({ message: "Invalid token" });

        req.user = decoded; // attach user to request
        next();
    });
};
