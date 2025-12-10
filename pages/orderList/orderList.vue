<template>
  <view class="order-list-container">
    <scroll-view class="order-list" scroll-y @scrolltolower="loadMore">
      <view 
        v-for="order in orders" 
        :key="order.id"
        class="order-card"
        @click="viewOrder(order.id)"
      >
        <view class="order-header">
          <view class="order-info">
            <text class="order-no">订单号: {{ order.order_no }}</text>
            <text class="order-time">{{ formatTime(order.create_time) }}</text>
          </view>
          <text class="order-status" :class="'status-' + order.status">
            {{ getStatusText(order.status) }}
          </text>
        </view>
        
        <view class="order-body">
          <view class="table-info">
            <text class="table-label">桌号:</text>
            <text class="table-value">{{ order.table_number }}</text>
          </view>
          <view class="order-type">
            <text>{{ order.order_type === 1 ? '堂食' : '打包' }}</text>
          </view>
        </view>
        
        <view class="order-footer">
          <text class="order-amount">
            合计: 
			<text class="amount">¥{{ formatAmount(order.total_amount) }}</text>
          </text>
          <view class="order-actions">
            <button 
              v-if="order.status === 3 || order.status === 4"
              class="action-btn small"
              @click.stop="goToReview(order.id)"
            >
              评价
            </button>
            <button 
              class="action-btn small primary"
              @click.stop="viewOrder(order.id)"
            >
              查看详情
            </button>
          </view>
        </view>
      </view>
      
      <view v-if="orders.length === 0" class="empty-list">
        <image src="/static/empty-order.png" class="empty-icon"></image>
        <text class="empty-text">暂无订单</text>
      </view>
      
      <view v-if="loading" class="loading-more">
        <text>加载中...</text>
      </view>
    </scroll-view>
  </view>
</template>

<script>
import api from '@/utils/api.js';

export default {
  data() {
    return {
      orders: [],
      loading: false,
      tableInfo: null,
      statusMap: {
        1: '待支付',
        2: '已支付',
        3: '已出餐',
        4: '已完成',
        5: '已取消',
        6: '已退款'
      }
    };
  },
  onShow() {
    this.loadOrders();
  },
  methods: {
    async loadOrders() {
      this.tableInfo = uni.getStorageSync('tableInfo');
      if (!this.tableInfo) {
        uni.showToast({
          title: '请先扫码进入',
          icon: 'none'
        });
        setTimeout(() => {
          uni.redirectTo({ url: '/pages/scan/scan' });
        }, 1500);
        return;
      }
      
      this.loading = true;
      try {
        this.orders = await api.getOrderList(this.tableInfo.id);
      } catch (err) {
        console.error(err);
      } finally {
        this.loading = false;
      }
    },
	
	
    
    loadMore() {
      // 加载更多订单
      console.log('加载更多');
    },
    
    formatTime(time) {
      const date = new Date(time);
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hour = String(date.getHours()).padStart(2, '0');
      const minute = String(date.getMinutes()).padStart(2, '0');
      return `${month}-${day} ${hour}:${minute}`;
    },
    
    // 格式化金额，确保正确显示
    formatAmount(amount) {
      if (amount === null || amount === undefined || amount === '') {
        return '0.00';
      }
      const num = parseFloat(amount);
      if (isNaN(num)) {
        return '0.00';
      }
      return num.toFixed(2);
    },
    
    getStatusText(status) {
      return this.statusMap[status] || '未知';
    },
    
    viewOrder(orderId) {
      uni.navigateTo({
        url: `/pages/order/order?id=${orderId}`
      });
    },
    
    goToReview(orderId) {
      uni.showToast({
        title: '评价功能开发中',
        icon: 'none'
      });
    }
  }
};
</script>

<style scoped>
.order-list-container {
  min-height: 100vh;
  background: #F5F5F5;
}

.order-list {
  height: 100vh;
  padding: 20rpx;
}

.order-card {
  background: white;
  border-radius: 20rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 10rpx rgba(0,0,0,0.05);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20rpx;
  padding-bottom: 20rpx;
  border-bottom: 1rpx solid #F0F0F0;
}

.order-info {
  flex: 1;
}

.order-no {
  font-size: 28rpx;
  color: #333;
  display: block;
  margin-bottom: 10rpx;
}

.order-time {
  font-size: 24rpx;
  color: #999;
}

.order-status {
  font-size: 26rpx;
  padding: 8rpx 20rpx;
  border-radius: 20rpx;
}

.status-1 {
  background: #FFF3E0;
  color: #FF9800;
}

.status-2 {
  background: #E3F2FD;
  color: #1E90FF;
}

.status-3 {
  background: #FFF9C4;
  color: #FBC02D;
}

.status-4 {
  background: #E8F5E9;
  color: #4CAF50;
}

.status-5,
.status-6 {
  background: #FFEBEE;
  color: #F44336;
}

.order-body {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.table-info {
  display: flex;
  align-items: center;
}

.table-label {
  font-size: 28rpx;
  color: #666;
  margin-right: 10rpx;
}

.table-value {
  font-size: 28rpx;
  color: #333;
  font-weight: bold;
}

.order-type {
  font-size: 24rpx;
  color: #666;
  background: #F5F5F5;
  padding: 8rpx 20rpx;
  border-radius: 20rpx;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.order-amount {
  font-size: 28rpx;
  color: #666;
}

.amount {
  font-size: 36rpx;
  color: #FF6B6B;
  font-weight: bold;
}

.order-actions {
  display: flex;
}

.action-btn {
  height: 60rpx;
  line-height: 60rpx;
  padding: 0 30rpx;
  border-radius: 30rpx;
  font-size: 26rpx;
  border: none;
  margin-left: 20rpx;
}

.action-btn.small {
  background: #F5F5F5;
  color: #666;
}

.action-btn.primary {
  background: #1E90FF;
  color: white;
}

.empty-list {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 150rpx 0;
}

.empty-icon {
  width: 300rpx;
  height: 300rpx;
  margin-bottom: 40rpx;
  opacity: 0.5;
}

.empty-text {
  font-size: 32rpx;
  color: #999;
}

.loading-more {
  text-align: center;
  padding: 30rpx 0;
  color: #999;
  font-size: 26rpx;
}
</style>