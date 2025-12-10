<template>
  <view class="payment-container">
    <scroll-view class="payment-content" scroll-y>
      <!-- 桌号信息 -->
      <view class="info-section">
        <view class="info-row">
          <text class="info-label">桌号:</text>
          <text class="info-value">{{ tableInfo.table_number }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">人数:</text>
          <text class="info-value">{{ peopleCount }}人</text>
        </view>
        <view class="info-row">
          <text class="info-label">类型:</text>
          <text class="info-value">{{ orderType === 1 ? '堂食' : '打包' }}</text>
        </view>
      </view>
      
      <!-- 菜品列表 -->
      <view class="dish-section">
        <view class="section-title">菜品清单</view>
        <view v-for="(item, dishId) in cart" :key="dishId" class="dish-row">
          <text class="dish-name">{{ item.name }}</text>
          <text class="dish-quantity">x{{ item.quantity }}</text>
          <text class="dish-price">¥{{ (item.price * item.quantity).toFixed(2) }}</text>
        </view>
      </view>
      
      <!-- 备注 -->
      <view class="remark-section">
        <view class="section-title">备注</view>
        <textarea 
          v-model="remark" 
          class="remark-input" 
          placeholder="请输入备注信息(选填)"
          maxlength="200"
        ></textarea>
      </view>
      
      <!-- 支付方式 -->
      <view class="payment-method-section">
        <view class="section-title">支付方式</view>
        <view 
          v-for="method in paymentMethods" 
          :key="method.value"
          class="method-item"
          :class="{ active: paymentMethod === method.value }"
          @click="selectPaymentMethod(method.value)"
        >
          <image :src="method.icon" class="method-icon"></image>
          <text class="method-name">{{ method.name }}</text>
          <image 
            v-if="paymentMethod === method.value"
            src="/static/check.png" 
            class="check-icon"
          ></image>
        </view>
      </view>
      
      <!-- 费用明细 -->
      <view class="cost-section">
        <view class="cost-row">
          <text class="cost-label">菜品费用</text>
          <text class="cost-value">¥{{ totalPrice.toFixed(2) }}</text>
        </view>
        <view class="cost-row">
          <text class="cost-label">包装费</text>
          <text class="cost-value">¥0.00</text>
        </view>
        <view class="cost-row total">
          <text class="cost-label">合计</text>
          <text class="cost-value">¥{{ totalPrice.toFixed(2) }}</text>
        </view>
      </view>
    </scroll-view>
    
    <!-- 底部按钮 -->
    <view class="bottom-bar">
      <view class="total-info">
        <text class="total-label">需支付:</text>
        <text class="total-price">¥{{ totalPrice.toFixed(2) }}</text>
      </view>
      <button class="pay-btn" @click="submitOrder">确认下单</button>
    </view>
  </view>
</template>

<script>
import api from '@/utils/api.js';

export default {
  data() {
    return {
      tableInfo: null,
      peopleCount: 2,
      orderType: 1,
      cart: {},
      remark: '',
      paymentMethod: 'wechat',
      paymentMethods: [
        { name: '微信支付', value: 'wechat', icon: '/static/wxpay.png' },
        { name: '支付宝', value: 'alipay', icon: '/static/alpay.png' },
        { name: '现金支付', value: 'cash', icon: '/static/cashpay.png' }
      ]
    };
  },
  computed: {
    totalPrice() {
      return Object.values(this.cart).reduce((sum, item) => sum + item.price * item.quantity, 0);
    }
  },
  onLoad() {
    this.tableInfo = uni.getStorageSync('tableInfo');
    this.peopleCount = uni.getStorageSync('peopleCount') || 2;
    this.orderType = uni.getStorageSync('orderType') || 1;
    this.cart = uni.getStorageSync('cart') || {};
    
    if (Object.keys(this.cart).length === 0) {
      uni.showToast({
        title: '购物车为空',
        icon: 'none'
      });
      setTimeout(() => {
        uni.navigateBack();
      }, 1500);
    }
  },
  methods: {
    selectPaymentMethod(method) {
      this.paymentMethod = method;
    },
    
    async submitOrder() {
      // 检查购物车是否为空
      if (Object.keys(this.cart).length === 0 || this.totalPrice === 0) {
        uni.showToast({
          title: '购物车为空，无法下单',
          icon: 'none'
        });
        return;
      }
      
      if (!this.paymentMethod) {
        uni.showToast({
          title: '请选择支付方式',
          icon: 'none'
        });
        return;
      }
      
      uni.showLoading({ title: '提交中...' });
      
      try {
        // 构造订单数据
        const dishes = Object.values(this.cart).map(item => ({
          id: item.id,
          name: item.name,
          price: item.price,
          quantity: item.quantity
        }));
        
        const orderData = {
          merchantId: this.tableInfo.merchant_id,
          tableId: this.tableInfo.id,
          peopleCount: this.peopleCount,
          orderType: this.orderType,
          dishes: dishes,
          totalAmount: this.totalPrice,
          remark: this.remark
        };
        
        // 创建订单
        const result = await api.createOrder(orderData);
        
        // 支付订单
        await api.payOrder({
          orderId: result.orderId,
          paymentMethod: this.paymentMethod
        });
        
        // 清空购物车
        uni.removeStorageSync('cart');
        
        uni.hideLoading();
        uni.showToast({
          title: '下单成功',
          icon: 'success'
        });
        
        // 跳转到订单详情页
        setTimeout(() => {
          uni.redirectTo({
            url: `/pages/order/order?id=${result.orderId}`
          });
        }, 1500);
        
      } catch (err) {
        uni.hideLoading();
        uni.showToast({
          title: '下单失败',
          icon: 'none'
        });
      }
    }
  }
};
</script>

<style scoped>
.payment-container {
  min-height: 100vh;
  background: #F5F5F5;
  display: flex;
  flex-direction: column;
}

.payment-content {
  flex: 1;
  padding: 20rpx;
  padding-bottom: 140rpx;
}

.info-section,
.dish-section,
.remark-section,
.payment-method-section,
.cost-section {
  background: white;
  border-radius: 20rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 30rpx;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 28rpx;
  color: #666;
}

.info-value {
  font-size: 28rpx;
  color: #333;
  font-weight: bold;
}

.dish-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
}

.dish-row:last-child {
  border-bottom: none;
}

.dish-name {
  flex: 1;
  font-size: 28rpx;
  color: #333;
}

.dish-quantity {
  font-size: 28rpx;
  color: #666;
  margin: 0 30rpx;
}

.dish-price {
  font-size: 28rpx;
  color: #FF6B6B;
  font-weight: bold;
}

.remark-input {
  width: 100%;
  min-height: 150rpx;
  background: #F5F5F5;
  border-radius: 10rpx;
  padding: 20rpx;
  font-size: 28rpx;
  line-height: 1.6;
}

.method-item {
  display: flex;
  align-items: center;
  padding: 30rpx;
  border: 2rpx solid #E0E0E0;
  border-radius: 15rpx;
  margin-bottom: 20rpx;
  position: relative;
}

.method-item:last-child {
  margin-bottom: 0;
}

.method-item.active {
  border-color: #1E90FF;
  background: #E3F2FD;
}

.method-icon {
  width: 60rpx;
  height: 60rpx;
  margin-right: 20rpx;
}

.method-name {
  flex: 1;
  font-size: 30rpx;
  color: #333;
}

.check-icon {
  width: 40rpx;
  height: 40rpx;
}

.cost-row {
  display: flex;
  justify-content: space-between;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
}

.cost-row:last-child {
  border-bottom: none;
}

.cost-row.total {
  padding-top: 30rpx;
}

.cost-label {
  font-size: 28rpx;
  color: #666;
}

.cost-row.total .cost-label {
  font-size: 32rpx;
  color: #333;
  font-weight: bold;
}

.cost-value {
  font-size: 28rpx;
  color: #333;
}

.cost-row.total .cost-value {
  font-size: 36rpx;
  color: #FF6B6B;
  font-weight: bold;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 20rpx 30rpx;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.1);
}

.total-info {
  display: flex;
  align-items: baseline;
}

.total-label {
  font-size: 28rpx;
  color: #666;
  margin-right: 10rpx;
}

.total-price {
  font-size: 40rpx;
  color: #FF6B6B;
  font-weight: bold;
}

.pay-btn {
  background: #1E90FF;
  color: white;
  padding: 20rpx 60rpx;
  border-radius: 50rpx;
  font-size: 32rpx;
  font-weight: bold;
  border: none;
}
</style>