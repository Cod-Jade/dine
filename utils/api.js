// utils/api.js - API接口配置(修复版本)
const BASE_URL = 'http://localhost:3000/api';

// 模拟数据
const mockData = {
  merchant: {
    id: 1,
    name: '美食餐厅',
    banners: [
      { id: 1, image_url: '/static/banner1.jpg' },
      { id: 2, image_url: '/static/banner2.jpg' }
    ]
  },
  categories: [
    { id: 1, name: '热销推荐', sort_order: 1, merchant_id: 1 },
    { id: 2, name: '特色菜', sort_order: 2, merchant_id: 1 },
    { id: 3, name: '凉菜', sort_order: 3, merchant_id: 1 },
    { id: 4, name: '主食', sort_order: 4, merchant_id: 1 },
    { id: 5, name: '饮品', sort_order: 5, merchant_id: 1 }
  ],
  dishes: [
    { id: 1, name: '宫保鸡丁', price: 38, sales: 999, description: '经典川菜,鸡丁鲜嫩', image: '/static/dish1.jpg', category_id: 1, status: 1 },
    { id: 2, name: '鱼香肉丝', price: 32, sales: 888, description: '酸甜可口,下饭佳品', image: '/static/dish2.jpg', category_id: 1, status: 1 },
    { id: 3, name: '麻婆豆腐', price: 28, sales: 777, description: '麻辣鲜香,豆腐嫩滑', image: '/static/dish3.jpg', category_id: 1, status: 1 },
    { id: 4, name: '红烧肉', price: 48, sales: 666, description: '肥而不腻,入口即化', image: '/static/dish4.jpg', category_id: 2, status: 1 },
    { id: 5, name: '糖醋排骨', price: 42, sales: 555, description: '酸甜适中,外酥里嫩', image: '/static/dish5.jpg', category_id: 2, status: 1 },
    { id: 6, name: '凉拌黄瓜', price: 12, sales: 444, description: '清爽开胃', image: '/static/dish6.jpg', category_id: 3, status: 1 },
    { id: 7, name: '米饭', price: 3, sales: 9999, description: '东北大米', image: '/static/dish7.jpg', category_id: 4, status: 1 },
    { id: 8, name: '可乐', price: 8, sales: 333, description: '冰镇可乐', image: '/static/dish8.jpg', category_id: 5, status: 1 }
  ]
};

// 请求封装
const request = (url, method = 'GET', data = {}) => {
  return new Promise((resolve, reject) => {
    uni.request({
      url: BASE_URL + url,
      method: method,
      data: data,
      header: {
        'Content-Type': 'application/json'
      },
      timeout: 5000,
      success: (res) => {
        if (res.statusCode !== 200) {
          reject({ code: res.statusCode, message: `服务器错误 (${res.statusCode})` });
          return;
        }
        
        if (res.data && res.data.code === 200) {
          resolve(res.data.data);
        } else {
          reject(res.data || { code: 500, message: '请求失败' });
        }
      },
      fail: (err) => {
        console.log('API请求失败,使用离线模式:', url);
        reject({ code: -1, message: '网络错误', offline: true });
      }
    });
  });
};

// 生成订单号
function generateOrderNo() {
  return 'ORD' + Date.now() + Math.floor(Math.random() * 1000);
}

// API接口
export default {
  // 扫码获取桌台信息
  getTableByQrCode: async (qrCode) => {
    try {
      return await request(`/table/${qrCode}`);
    } catch (err) {
      const match = qrCode.match(/TABLE_(\d+)_MERCHANT_(\d+)/);
      if (match) {
        const tableNum = match[1];
        const merchantId = match[2];
        return {
          id: parseInt(tableNum),
          table_number: `${tableNum}号桌`,
          merchant_id: parseInt(merchantId),
          qr_code: qrCode,
          status: 0
        };
      }
      throw err;
    }
  },
  
  // 获取商家信息
  getMerchantInfo: async (merchantId) => {
    try {
      return await request(`/merchant/${merchantId}`);
    } catch (err) {
      console.log('使用模拟商家数据');
      return mockData.merchant;
    }
  },
  
  // 获取分类列表
  getCategoryList: async (merchantId) => {
    try {
      return await request(`/category/${merchantId}`);
    } catch (err) {
      console.log('使用模拟分类数据');
      return mockData.categories;
    }
  },
  
  // 获取菜品列表
  getDishList: async (merchantId, params = {}) => {
    try {
      let query = '';
      if (params.categoryId) query += `?categoryId=${params.categoryId}`;
      if (params.keyword) query += query ? `&keyword=${params.keyword}` : `?keyword=${params.keyword}`;
      return await request(`/dish/${merchantId}${query}`);
    } catch (err) {
      console.log('使用模拟菜品数据');
      let dishes = mockData.dishes;
      
      if (params.categoryId) {
        dishes = dishes.filter(d => d.category_id === parseInt(params.categoryId));
      }
      
      if (params.keyword) {
        dishes = dishes.filter(d => d.name.includes(params.keyword));
      }
      
      return dishes;
    }
  },
  
  // 获取菜品详情
  getDishDetail: async (dishId) => {
    try {
      return await request(`/dish/detail/${dishId}`);
    } catch (err) {
      console.log('使用模拟菜品详情');
      const dish = mockData.dishes.find(d => d.id === parseInt(dishId));
      if (dish) {
        return {
          ...dish,
          goodRate: 98,
          reviews: [
            { id: 1, rating: 5, content: '非常好吃,下次还来!', create_time: new Date() },
            { id: 2, rating: 4, content: '味道不错,分量足', create_time: new Date() }
          ]
        };
      }
      throw new Error('菜品不存在');
    }
  },
  
  // 创建订单 - 修复金额保存问题
  createOrder: async (data) => {
    try {
      return await request('/order/create', 'POST', data);
    } catch (err) {
      console.log('使用模拟订单创建');
      const orderId = Date.now();
      const orderNo = generateOrderNo();
      
      // 确保金额以数字形式保存
      const totalAmount = parseFloat(data.totalAmount) || 0;
      
      const orders = uni.getStorageSync('localOrders') || [];
      orders.push({
        id: orderId,
        order_no: orderNo,
        merchant_id: data.merchantId,
        table_id: data.tableId,
        table_number: data.tableId ? `${data.tableId}号桌` : '1号桌',
        people_count: data.peopleCount,
        order_type: data.orderType,
        // 关键修复:确保总金额以数字形式存储
        total_amount: totalAmount,
        remark: data.remark,
        status: 1,
        payment_method: null,
        create_time: new Date().toISOString(),
        // 保存菜品明细
        dishes: data.dishes.map(d => ({
          id: d.id,
          dish_id: d.id,
          dish_name: d.name,
          dish_price: parseFloat(d.price) || 0,
          quantity: parseInt(d.quantity) || 0,
          subtotal: (parseFloat(d.price) || 0) * (parseInt(d.quantity) || 0)
        }))
      });
      uni.setStorageSync('localOrders', orders);
      
      return { orderId, orderNo };
    }
  },
  
  // 支付订单 - 修复金额更新问题
  payOrder: async (data) => {
    try {
      return await request('/order/pay', 'POST', data);
    } catch (err) {
      console.log('使用模拟支付');
      const orders = uni.getStorageSync('localOrders') || [];
      const orderId = parseInt(data.orderId);
      const order = orders.find(o => o.id === orderId);
      if (order) {
        order.status = 2;
        order.payment_method = data.paymentMethod;
        // 确保金额不被覆盖
        if (!order.total_amount || order.total_amount === 0) {
          console.error('订单金额异常:', order);
        }
        uni.setStorageSync('localOrders', orders);
      } else {
        console.error('支付时找不到订单:', orderId);
      }
      return { success: true };
    }
  },
  
  // 获取订单详情 - 修复金额显示问题
  getOrderDetail: async (orderId) => {
    try {
      return await request(`/order/${orderId}`);
    } catch (err) {
      console.log('使用本地订单数据');
      const orders = uni.getStorageSync('localOrders') || [];
      // 确保orderId是数字类型
      const orderIdNum = parseInt(orderId);
      console.log('查找订单:', orderIdNum, orders.length);
      const order = orders.find(o => o.id === orderIdNum);
      if (order) {
        // 关键修复:确保返回的金额是数字类型
        return {
          id: order.id,
          order_no: order.order_no,
          merchant_id: order.merchant_id,
          table_id: order.table_id,
          table_number: order.table_number || `${order.table_id || 1}号桌`,
          people_count: order.people_count,
          order_type: order.order_type,
          // 确保金额是数字类型
          total_amount: parseFloat(order.total_amount) || 0,
          remark: order.remark,
          status: order.status,
          payment_method: order.payment_method,
          create_time: order.create_time,
          wait_time: 15,
          // 确保明细中的金额也是数字类型
          details: (order.dishes || []).map(d => ({
            id: d.id,
            dish_id: d.dish_id || d.id,
            dish_name: d.dish_name || d.name,
            dish_price: parseFloat(d.dish_price || d.price) || 0,
            quantity: parseInt(d.quantity) || 0,
            subtotal: parseFloat(d.subtotal) || ((parseFloat(d.dish_price || d.price) || 0) * (parseInt(d.quantity) || 0))
          }))
        };
      }
      console.error('订单不存在:', orderIdNum, orders);
      throw new Error('订单不存在');
    }
  },
  
  // 获取订单列表 - 修复金额显示问题
  getOrderList: async (tableId) => {
    try {
      return await request(`/order/list/${tableId}`);
    } catch (err) {
      console.log('使用本地订单列表');
      const orders = uni.getStorageSync('localOrders') || [];
      // 关键修复:确保返回的订单列表中金额是数字类型
      return orders.map(o => ({
        ...o,
        table_number: o.table_number || `${o.table_id || 1}号桌`,
        // 确保金额是数字类型
        total_amount: parseFloat(o.total_amount) || 0
      }));
    }
  },
  
  // 申请退款
  refundOrder: async (orderId) => {
    try {
      return await request('/order/refund', 'POST', { orderId });
    } catch (err) {
      console.log('使用模拟退款');
      const orders = uni.getStorageSync('localOrders') || [];
      const order = orders.find(o => o.id === orderId);
      if (order) {
        order.status = 6;
        uni.setStorageSync('localOrders', orders);
      }
      return { success: true };
    }
  },
  
  // 提交评价
  submitReview: async (data) => {
    try {
      return await request('/review/submit', 'POST', data);
    } catch (err) {
      console.log('评价提交成功(离线模式)');
      return { success: true };
    }
  }
};