// server.js - Node.js后端服务
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// 中间件
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// 数据库连接池
const pool = mysql.createPool({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'root', // 请修改为实际密码
    database: 'food',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// 生成订单号
function generateOrderNo() {
    return 'ORD' + Date.now() + Math.floor(Math.random() * 1000);
}

// ========== API接口 ==========

// 1. 扫码获取桌台信息
app.get('/api/table/:qrCode', async (req, res) => {
    try {
        const [tables] = await pool.query(
            'SELECT * FROM dining_table WHERE qr_code = ?',
            [req.params.qrCode]
        );
        if (tables.length > 0) {
            res.json({ code: 200, data: tables[0] });
        } else {
            res.json({ code: 404, message: '桌台不存在' });
        }
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 2. 获取商家信息及轮播图
app.get('/api/merchant/:id', async (req, res) => {
    try {
        const [merchant] = await pool.query('SELECT * FROM merchant WHERE id = ?', [req.params.id]);
        const [banners] = await pool.query(
            'SELECT * FROM merchant_banner WHERE merchant_id = ? ORDER BY sort_order',
            [req.params.id]
        );
        res.json({ 
            code: 200, 
            data: { 
                ...merchant[0], 
                banners: banners 
            } 
        });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 3. 获取分类列表
app.get('/api/category/:merchantId', async (req, res) => {
    try {
        const [categories] = await pool.query(
            'SELECT * FROM category WHERE merchant_id = ? ORDER BY sort_order',
            [req.params.merchantId]
        );
        res.json({ code: 200, data: categories });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 4. 获取菜品列表
app.get('/api/dish/:merchantId', async (req, res) => {
    try {
        const { categoryId, keyword } = req.query;
        let sql = 'SELECT d.*, c.name as category_name FROM dish d LEFT JOIN category c ON d.category_id = c.id WHERE d.merchant_id = ? AND d.status = 1';
        const params = [req.params.merchantId];
        
        if (categoryId) {
            sql += ' AND d.category_id = ?';
            params.push(categoryId);
        }
        
        if (keyword) {
            sql += ' AND d.name LIKE ?';
            params.push(`%${keyword}%`);
        }
        
        sql += ' ORDER BY d.sales DESC';
        
        const [dishes] = await pool.query(sql, params);
        res.json({ code: 200, data: dishes });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 5. 获取菜品详情
app.get('/api/dish/detail/:id', async (req, res) => {
    try {
        const [dish] = await pool.query('SELECT * FROM dish WHERE id = ?', [req.params.id]);
        const [reviews] = await pool.query(
            'SELECT * FROM review WHERE dish_id = ? ORDER BY create_time DESC LIMIT 10',
            [req.params.id]
        );
        
        // 计算好评率
        const goodReviews = reviews.filter(r => r.rating >= 4).length;
        const goodRate = reviews.length > 0 ? (goodReviews / reviews.length * 100).toFixed(1) : 100;
        
        res.json({ 
            code: 200, 
            data: { 
                ...dish[0], 
                reviews: reviews,
                goodRate: goodRate
            } 
        });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 6. 创建订单
app.post('/api/order/create', async (req, res) => {
    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();
        
        const { merchantId, tableId, peopleCount, orderType, dishes, totalAmount, remark } = req.body;
        const orderNo = generateOrderNo();
        
        // 插入订单
        const [orderResult] = await conn.query(
            `INSERT INTO orders (order_no, merchant_id, table_id, people_count, order_type, 
             total_amount, remark, status, wait_time) VALUES (?, ?, ?, ?, ?, ?, ?, 1, 15)`,
            [orderNo, merchantId, tableId, peopleCount, orderType, totalAmount, remark]
        );
        
        const orderId = orderResult.insertId;
        
        // 插入订单明细
        for (let dish of dishes) {
            await conn.query(
                `INSERT INTO order_detail (order_id, dish_id, dish_name, dish_price, quantity, subtotal) 
                 VALUES (?, ?, ?, ?, ?, ?)`,
                [orderId, dish.id, dish.name, dish.price, dish.quantity, dish.price * dish.quantity]
            );
        }
        
        // 更新桌台状态
        await conn.query('UPDATE dining_table SET status = 1 WHERE id = ?', [tableId]);
        
        await conn.commit();
        res.json({ code: 200, data: { orderId, orderNo }, message: '订单创建成功' });
    } catch (error) {
        await conn.rollback();
        res.json({ code: 500, message: error.message });
    } finally {
        conn.release();
    }
});

// 7. 支付订单
app.post('/api/order/pay', async (req, res) => {
    try {
        const { orderId, paymentMethod } = req.body;
        await pool.query(
            'UPDATE orders SET status = 2, payment_method = ? WHERE id = ?',
            [paymentMethod, orderId]
        );
        res.json({ code: 200, message: '支付成功' });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 8. 获取订单详情
app.get('/api/order/:orderId', async (req, res) => {
    try {
        const [orders] = await pool.query(
            `SELECT o.*, t.table_number,
             CAST(o.total_amount AS DECIMAL(10,2)) as total_amount
             FROM orders o ...`
        );
        
        const [details] = await pool.query(
            'SELECT * FROM order_detail WHERE order_id = ?',
            [req.params.orderId]
        );
        
        res.json({ 
            code: 200, 
            data: { 
                ...orders[0], 
                details: details 
            } 
        });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 9. 获取用户订单列表
app.get('/api/order/list/:tableId', async (req, res) => {
    try {
        const [orders] = await pool.query(
            `SELECT o.*, t.table_number FROM orders o 
             LEFT JOIN dining_table t ON o.table_id = t.id 
             WHERE o.table_id = ? ORDER BY o.create_time DESC LIMIT 20`,
            [req.params.tableId]
        );
        res.json({ code: 200, data: orders });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 10. 申请退款
app.post('/api/order/refund', async (req, res) => {
    try {
        const { orderId } = req.body;
        await pool.query('UPDATE orders SET status = 6 WHERE id = ?', [orderId]);
        res.json({ code: 200, message: '退款申请已提交' });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 11. 提交评价
app.post('/api/review/submit', async (req, res) => {
    try {
        const { orderId, dishId, rating, content } = req.body;
        await pool.query(
            'INSERT INTO review (order_id, dish_id, rating, content) VALUES (?, ?, ?, ?)',
            [orderId, dishId, rating, content]
        );
        res.json({ code: 200, message: '评价成功' });
    } catch (error) {
        res.json({ code: 500, message: error.message });
    }
});

// 启动服务器
app.listen(PORT, () => {
    console.log(`服务器运行在 http://localhost:${PORT}`);
});