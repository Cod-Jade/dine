<template>
  <view class="order-container">
    <scroll-view class="order-content" scroll-y>
      <!-- 订单状态 -->
      <view class="status-section">
        <image :src="statusInfo.icon" class="status-icon"></image>
        <text class="status-text">{{ statusInfo.text }}</text>
        <text v-if="order.wait_time > 0" class="wait-time">
          预计等待 {{ order.wait_time }} 分钟
        </text>
      </view>
      
      <!-- 测试按钮区域 -->
      <view v-if="order.status === 2 || order.status === 3" class="test-section">
        <button 
          v-if="order.status === 2"
          class="test-btn serve"
          @click="testServe"
        >
          🍳 测试出餐
        </button>
        <button 
          v-if="order.status === 3"
          class="test-btn complete"
          @click="testComplete"
        >
          ✅ 测试完成
        </button>
      </view>
      
      <!-- 订单信息 -->
      <view class="info-section">
        <view class="section-title">订单信息</view>
        <view class="info-row">
          <text class="info-label">订单号:</text>
          <text class="info-value">{{ order.order_no }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">桌号:</text>
          <text class="info-value">{{ order.table_number }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">就餐人数:</text>
          <text class="info-value">{{ order.people_count }}人</text>
        </view>
        <view class="info-row">
          <text class="info-label">订单类型:</text>
          <text class="info-value">{{ order.order_type === 1 ? '堂食' : '打包' }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">下单时间:</text>
          <text class="info-value">{{ formatTime(order.create_time) }}</text>
        </view>
        <view v-if="order.remark" class="info-row">
          <text class="info-label">备注:</text>
          <text class="info-value">{{ order.remark }}</text>
        </view>
      </view>
      
      <!-- 菜品列表 -->
      <view class="dish-section">
        <view class="section-title">菜品清单</view>
        <view v-for="item in order.details" :key="item.id" class="dish-row">
          <text class="dish-name">{{ item.dish_name }}</text>
          <text class="dish-quantity">x{{ item.quantity }}</text>
          <text class="dish-price">¥{{ item.subtotal.toFixed(2) }}</text>
        </view>
        <view class="total-row">
          <text class="total-label">总金额</text>
          <text class="total-price">¥{{ parseFloat(order.total_amount).toFixed(2) }}</text>
        </view>
      </view>
      
      <!-- 支付信息 -->
      <view class="payment-section">
        <view class="section-title">支付信息</view>
        <view class="info-row">
          <text class="info-label">支付方式:</text>
          <text class="info-value">{{ getPaymentMethodName(order.payment_method) }}</text>
        </view>
        <view class="info-row">
          <text class="info-label">实付金额:</text>
          <text class="info-value price">¥{{ parseFloat(order.total_amount).toFixed(2) }}</text>
        </view>
      </view>
    </scroll-view>
    
    <!-- 底部操作按钮 -->
    <view class="bottom-bar">
      <button 
        class="action-btn secondary"
        @click="goToOrderList"
      >
        查看订单
      </button>
      <button 
        v-if="order.status === 2 || order.status === 3"
        class="action-btn secondary"
        @click="showRefundDialog"
      >
        申请退款
      </button>
      <button 
        v-if="order.status === 2 || order.status === 3"
        class="action-btn primary"
        @click="continueOrder"
      >
        继续点餐
      </button>
      <button 
        v-if="order.status === 4"
        class="action-btn primary full"
        @click="goToReview"
      >
        评价订单
      </button>
    </view>
    
    <!-- 退款确认弹窗 -->
    <view v-if="showRefund" class="modal-mask" @click="showRefund = false">
      <view class="modal-content" @click.stop>
        <text class="modal-title">确认申请退款?</text>
        <text class="modal-desc">退款申请提交后将由商家审核</text>
        <view class="modal-btns">
          <button class="modal-btn cancel" @click="showRefund = false">取消</button>
          <button class="modal-btn confirm" @click="confirmRefund">确认</button>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
import api from '@/utils/api.js';

export default {
  data() {
    return {
      orderId: 0,
      order: {
        order_no: '',
        table_number: '',
        people_count: 0,
        order_type: 1,
        create_time: '',
        remark: '',
        wait_time: 0,
        status: 1,
        payment_method: '',
        total_amount: 0,
        details: []
      },
      showRefund: false,
      statusMap: {
        1: { text: '待支付', icon: '/static/status-wait.png' },
        2: { text: '已支付', icon: '/static/paid.png' },
        3: { text: '已出餐', icon: '/static/cooked.png' },
        4: { text: '已完成', icon: '/static/status-done.png' },
        5: { text: '已取消', icon: '/static/status-cancel.png' },
        6: { text: '已退款', icon: '/static/status-refund.png' }
      },
      paymentMethodMap: {
        'wechat': '微信支付',
        'alipay': '支付宝',
        'cash': '现金支付'
      }
    };
  },
  computed: {
    statusInfo() {
      return this.statusMap[this.order.status] || { text: '未知状态', icon: '' };
    }
  },
  onLoad(options) {
    this.orderId = parseInt(options.id);
    this.loadOrder();
  },
  methods: {
    async loadOrder() {
      uni.showLoading({ title: '加载中...' });
      try {
        const data = await api.getOrderDetail(this.orderId);
        
        // 确保数据完整性
        this.order = {
          order_no: data.order_no || '',
          table_number: data.table_number || '1号桌',
          people_count: data.people_count || data.peopleCount || 2,
          order_type: data.order_type || data.orderType || 1,
          create_time: data.create_time || new Date().toISOString(),
          remark: data.remark || '',
          wait_time: data.wait_time || 15,
          status: data.status || 2,
          payment_method: data.payment_method || 'wechat',
          total_amount: data.total_amount || data.totalAmount || 0,
          details: data.details || []
        };
        
        console.log('订单详情:', this.order);
      } catch (err) {
        console.error('加载订单详情失败:', err);
        uni.showToast({
          title: '加载失败',
          icon: 'none'
        });
        setTimeout(() => {
          uni.navigateBack();
        }, 1500);
      } finally {
        uni.hideLoading();
      }
    },
    
    formatTime(time) {
      if (!time) return '';
      const date = new Date(time);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hour = String(date.getHours()).padStart(2, '0');
      const minute = String(date.getMinutes()).padStart(2, '0');
      return `${year}-${month}-${day} ${hour}:${minute}`;
    },
    
    getPaymentMethodName(method) {
      return this.paymentMethodMap[method] || method || '未支付';
    },
    
    showRefundDialog() {
      this.showRefund = true;
    },
    
    async confirmRefund() {
      this.showRefund = false;
      
      uni.showLoading({ title: '提交中...' });
      try {
        await api.refundOrder(this.orderId);
        
        uni.showToast({
          title: '退款申请已提交',
          icon: 'success',
          duration: 1500
        });
        
        setTimeout(() => {
          this.loadOrder();
        }, 1500);
      } catch (err) {
        console.error('退款申请失败:', err);
        uni.showToast({
          title: '退款申请失败',
          icon: 'none'
        });
      } finally {
        uni.hideLoading();
      }
    },
    
    continueOrder() {
      uni.switchTab({
        url: '/pages/home/home'
      });
    },
    
    goToReview() {
      uni.showToast({
        title: '评价功能开发中',
        icon: 'none'
      });
    },
    
    goToOrderList() {
      uni.reLaunch({
        url: '/pages/orderList/orderList'
      });
    },
    
    testServe() {
      // 更新订单状态为已出餐(3)
      const orders = uni.getStorageSync('localOrders') || [];
      const order = orders.find(o => o.id === this.orderId);
      if (order) {
        order.status = 3;
        uni.setStorageSync('localOrders', orders);
        this.order.status = 3;
        uni.showToast({
          title: '已标记为出餐',
          icon: 'success'
        });
      }
    },
    
    testComplete() {
      // 更新订单状态为已完成(4)
      const orders = uni.getStorageSync('localOrders') || [];
      const order = orders.find(o => o.id === this.orderId);
      if (order) {
        order.status = 4;
        uni.setStorageSync('localOrders', orders);
        this.order.status = 4;
        uni.showToast({
          title: '订单已完成',
          icon: 'success'
        });
      }
    }
  }
};
</script>

<style scoped>
.order-container {
  min-height: 100vh;
  background: #F5F5F5;
  display: flex;
  flex-direction: column;
}

.order-content {
  flex: 1;
  padding: 20rpx;
  padding-bottom: 140rpx;
}

.status-section {
  background: linear-gradient(135deg, #1E90FF 0%, #4169E1 100%);
  border-radius: 20rpx;
  padding: 60rpx;
  text-align: center;
  color: white;
  margin-bottom: 20rpx;
}

.status-icon {
  width: 120rpx;
  height: 120rpx;
  margin-bottom: 30rpx;
}

.status-text {
  font-size: 40rpx;
  font-weight: bold;
  display: block;
  margin-bottom: 20rpx;
}

.wait-time {
  font-size: 28rpx;
  opacity: 0.9;
}

.test-section {
  background: white;
  border-radius: 20rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  display: flex;
  justify-content: center;
}

.test-btn {
  width: 100%;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 50rpx;
  font-size: 32rpx;
  font-weight: bold;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.test-btn.serve {
  background: linear-gradient(135deg, #FFA726 0%, #FF9800 100%);
  color: white;
  box-shadow: 0 4rpx 12rpx rgba(255, 167, 38, 0.3);
}

.test-btn.complete {
  background: linear-gradient(135deg, #4CAF50 0%, #66BB6A 100%);
  color: white;
  box-shadow: 0 4rpx 12rpx rgba(76, 175, 80, 0.3);
}

.info-section,
.dish-section,
.payment-section {
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
  padding-bottom: 20rpx;
  border-bottom: 1rpx solid #F0F0F0;
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
  max-width: 60%;
  text-align: right;
  word-break: break-all;
}

.info-value.price {
  color: #FF6B6B;
  font-weight: bold;
  font-size: 32rpx;
}

.dish-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
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
}

.total-row {
  display: flex;
  justify-content: space-between;
  padding-top: 30rpx;
  margin-top: 20rpx;
  border-top: 2rpx solid #F0F0F0;
}

.total-label {
  font-size: 32rpx;
  color: #333;
  font-weight: bold;
}

.total-price {
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
  box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.1);
  flex-wrap: wrap;
  gap: 10rpx;
}

.action-btn {
  flex: 1;
  min-width: 150rpx;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 50rpx;
  font-size: 28rpx;
  border: none;
}

.action-btn.secondary {
  background: #F5F5F5;
  color: #666;
}

.action-btn.primary {
  background: #1E90FF;
  color: white;
  font-weight: bold;
}

.action-btn.full {
  flex: 1 1 100%;
  margin-top: 10rpx;
}

.modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal-content {
  width: 600rpx;
  background: white;
  border-radius: 20rpx;
  padding: 60rpx 40rpx 40rpx;
  text-align: center;
}

.modal-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
  display: block;
  margin-bottom: 20rpx;
}

.modal-desc {
  font-size: 28rpx;
  color: #666;
  display: block;
  margin-bottom: 40rpx;
}

.modal-btns {
  display: flex;
}

.modal-btn {
  flex: 1;
  height: 80rpx;
  line-height: 80rpx;
  border-radius: 50rpx;
  font-size: 30rpx;
  border: none;
}

.modal-btn.cancel {
  background: #F5F5F5;
  color: #666;
  margin-right: 20rpx;
}

.modal-btn.confirm {
  background: #1E90FF;
  color: white;
  font-weight: bold;
}
</style>