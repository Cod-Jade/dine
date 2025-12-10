<template>
  <view class="detail-container">
    <scroll-view class="detail-scroll" scroll-y>
      <image :src="dish.image" class="dish-banner" mode="aspectFill"></image>
      
      <view class="dish-header">
        <view class="dish-title">
          <text class="dish-name">{{ dish.name }}</text>
          <text class="dish-sales">月售{{ dish.sales }}</text>
        </view>
        <text class="dish-price">¥{{ dish.price }}</text>
        <text class="dish-desc">{{ dish.description }}</text>
        <view class="dish-rating">
          <text class="good-rate">好评率 {{ dish.goodRate }}%</text>
        </view>
      </view>
      
      <view class="review-section">
        <view class="section-header">
          <text class="section-title">用户评价</text>
          <view class="rating-filter">
            <text 
              :class="{ active: ratingFilter === 0 }" 
              @click="ratingFilter = 0"
            >全部</text>
            <text 
              :class="{ active: ratingFilter === 5 }" 
              @click="ratingFilter = 5"
            >好评</text>
            <text 
              :class="{ active: ratingFilter === 1 }" 
              @click="ratingFilter = 1"
            >差评</text>
          </view>
        </view>
        
        <view class="review-list">
          <view 
            v-for="review in filteredReviews" 
            :key="review.id"
            class="review-item"
          >
            <view class="review-header">
              <image src="/static/avatar.png" class="avatar"></image>
              <view class="review-info">
                <text class="username">用户{{ review.id }}</text>
                <view class="stars">
                  <text v-for="i in 5" :key="i" class="star" :class="{ filled: i <= review.rating }">★</text>
                </view>
              </view>
              <text class="review-time">{{ formatTime(review.create_time) }}</text>
            </view>
            <text class="review-content">{{ review.content }}</text>
          </view>
          
          <view v-if="filteredReviews.length === 0" class="empty-review">
            <text>暂无评价</text>
          </view>
        </view>
      </view>
      
      <!-- 底部占位，确保内容不被按钮遮挡 -->
      <view class="bottom-placeholder"></view>
    </scroll-view>
    
    <view class="bottom-bar">
      <button class="add-cart-btn" @click="addToCart">加入购物车</button>
    </view>
  </view>
</template>

<script>
import api from '@/utils/api.js';

export default {
  data() {
    return {
      dishId: 0,
      dish: {
        name: '',
        price: 0,
        sales: 0,
        description: '',
        image: '',
        goodRate: 100,
        reviews: []
      },
      ratingFilter: 0 // 0:全部 5:好评 1:差评
    };
  },
  computed: {
    filteredReviews() {
      if (this.ratingFilter === 0) {
        return this.dish.reviews;
      } else if (this.ratingFilter === 5) {
        return this.dish.reviews.filter(r => r.rating >= 4);
      } else {
        return this.dish.reviews.filter(r => r.rating < 4);
      }
    }
  },
  onLoad(options) {
    this.dishId = options.id;
    this.loadDetail();
  },
  methods: {
    async loadDetail() {
      uni.showLoading({ title: '加载中...' });
      try {
        const data = await api.getDishDetail(this.dishId);
        this.dish = {
          ...data,
          reviews: data.reviews || []
        };
      } catch (err) {
        console.error('加载菜品详情失败:', err);
        // 可以选择返回上一页
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
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${month}月${day}日`;
    },
    
    addToCart() {
      let cart = uni.getStorageSync('cart') || {};
      if (cart[this.dishId]) {
        cart[this.dishId].quantity++;
      } else {
        cart[this.dishId] = {
          id: this.dish.id,
          name: this.dish.name,
          price: this.dish.price,
          image: this.dish.image,
          quantity: 1
        };
      }
      uni.setStorageSync('cart', cart);
      
      uni.showToast({
        title: '已加入购物车',
        icon: 'success'
      });
      
      setTimeout(() => {
        uni.navigateBack();
      }, 1000);
    }
  }
};
</script>

<style scoped>
.detail-container {
  height: 100vh;
  background: #F5F5F5;
  position: relative;
  display: flex;
  flex-direction: column;
}

.detail-scroll {
  flex: 1;
  height: 100%;
}

.dish-banner {
  width: 100%;
  height: 500rpx;
}

.dish-header {
  background: white;
  padding: 30rpx;
  margin-bottom: 20rpx;
}

.dish-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}

.dish-name {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
}

.dish-sales {
  font-size: 24rpx;
  color: #999;
}

.dish-price {
  font-size: 40rpx;
  color: #FF6B6B;
  font-weight: bold;
  display: block;
  margin-bottom: 20rpx;
}

.dish-desc {
  font-size: 28rpx;
  color: #666;
  line-height: 1.6;
  display: block;
  margin-bottom: 20rpx;
}

.dish-rating {
  display: flex;
  align-items: center;
}

.good-rate {
  font-size: 28rpx;
  color: #1E90FF;
}

.review-section {
  background: white;
  padding: 30rpx;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
}

.rating-filter {
  display: flex;
}

.rating-filter text {
  margin-left: 30rpx;
  font-size: 26rpx;
  color: #999;
  padding: 10rpx 20rpx;
  border-radius: 20rpx;
}

.rating-filter text.active {
  background: #1E90FF;
  color: white;
}

.review-list {
  /* 移除固定高度，让内容自然展开 */
}

.review-item {
  padding: 30rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
}

.review-header {
  display: flex;
  align-items: center;
  margin-bottom: 20rpx;
}

.avatar {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  margin-right: 20rpx;
}

.review-info {
  flex: 1;
}

.username {
  font-size: 28rpx;
  color: #333;
  display: block;
  margin-bottom: 10rpx;
}

.stars {
  display: flex;
}

.star {
  font-size: 24rpx;
  color: #E0E0E0;
  margin-right: 5rpx;
}

.star.filled {
  color: #FFD700;
}

.review-time {
  font-size: 24rpx;
  color: #999;
}

.review-content {
  font-size: 28rpx;
  color: #666;
  line-height: 1.6;
}

.empty-review {
  text-align: center;
  padding: 80rpx 0;
  color: #999;
  font-size: 28rpx;
}

.bottom-placeholder {
  height: 140rpx;
}

.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx;
  background: white;
  box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.1);
  z-index: 999;
}

.add-cart-btn {
  width: 100%;
  height: 80rpx;
  background: #1E90FF;
  color: white;
  border-radius: 50rpx;
  font-size: 32rpx;
  font-weight: bold;
  border: none;
}
</style>