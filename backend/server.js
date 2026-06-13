const express = require('express');
const cors = require('cors');
const app = express();

// Securely restrict port binding to an unprivileged container port
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Main health-check endpoint for GKE Load Balancer monitoring
app.get('/health', (req, res) => {
    res.status(200).json({ status: "healthy", timestamp: new Date() });
});

// Secure API endpoint mock for order processing
app.post('/api/orders', (req, res) => {
    const { item } = req.body;
    if (!item) {
        return res.status(400).json({ error: "Invalid transaction request data." });
    }
    
    console.log(`[SECURE TRANSACTION]: Order placed successfully for item: ${item}`);
    res.status(201).json({
        success: true,
        message: `Order for ${item} securely processed by backend service!`,
        transactionId: `TXN-${Math.floor(100000 + Math.random() * 900000)}`
    });
});

app.listen(PORT, () => {
    console.log(`🛡️ Secure Backend API service running on cluster port ${PORT}`);
});