const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const appVersion = process.env.APP_VERSION || 'blue'; // 'blue' or 'green'

app.use(cors());
app.use(express.json());

// Basic logging middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Health check endpoint (for Kubernetes Readiness and Liveness probes)
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UP', version: appVersion });
});

// System Info
app.get('/api/info', (req, res) => {
    res.status(200).json({
        message: 'Food Delivery API System',
        version: appVersion,
        timestamp: new Date().toISOString()
    });
});

// Mock Endpoints for Food Delivery features
app.get('/api/restaurants', (req, res) => {
    res.json([
        { id: 1, name: 'Spicy Delight', rating: 4.8, type: 'Indian' },
        { id: 2, name: 'Burger Joint', rating: 4.5, type: 'American' },
        { id: 3, name: 'Tokyo Sushi', rating: 4.9, type: 'Japanese' },
        { id: 4, name: 'La Piazza', rating: 4.7, type: 'Italian' }
    ]);
});

app.get('/api/restaurants/:id/menu', (req, res) => {
    res.json([
        { id: 101, name: 'Spicy Chicken Wings', price: 12.99 },
        { id: 102, name: 'Cheese Burger', price: 9.99 }
    ]);
});

app.post('/api/orders', (req, res) => {
    const { userId, restaurantId, items } = req.body;
    // Mock saving order to database
    res.status(201).json({
        orderId: Math.floor(Math.random() * 10000),
        status: 'Order Placed',
        versionProcessedBy: appVersion
    });
});

const mysql = require('mysql2/promise');

let dbPool;

async function startServer() {
    let dbPassword = process.env.DB_PASSWORD;
    let dbHost = process.env.DB_HOST || 'localhost';
    let dbUser = process.env.DB_USER || 'admin';
    let dbName = process.env.DB_NAME || 'fooddelivery';

    // Fetch DB password from AWS SSM if not provided in env and if running in AWS (where region is available or metadata works)
    try {
        if (!dbPassword) {
            console.log('Fetching DB password from AWS SSM Parameter Store...');
            // Assumes region is provided via env or EC2/EKS metadata
            const client = new SSMClient({ region: process.env.AWS_REGION || 'us-east-1' });
            const command = new GetParameterCommand({
                Name: '/food-delivery/prod/db-password',
                WithDecryption: true
            });
            const response = await client.send(command);
            dbPassword = response.Parameter.Value;
            console.log('Successfully fetched DB password from SSM.');
        }
    } catch (err) {
        console.warn('Failed to fetch DB password from SSM. Continuing with mock data. Error:', err.message);
    }

    if (dbPassword) {
        try {
            dbPool = mysql.createPool({
                host: dbHost,
                user: dbUser,
                password: dbPassword,
                database: dbName,
                waitForConnections: true,
                connectionLimit: 10,
                queueLimit: 0
            });
            // Test connection
            await dbPool.query('SELECT 1');
            console.log('Successfully connected to the database.');
        } catch (err) {
            console.error('Failed to connect to the database. Continuing with mock data. Error:', err.message);
            dbPool = null;
        }
    } else {
        console.log('No DB Password available. Running in Mock Data mode.');
    }
    
    app.listen(port, () => {
        console.log(`Server running on port ${port} | Version: ${appVersion}`);
    });
}

startServer();
