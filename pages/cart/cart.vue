<template>
  <view class="cart-container">
    <scroll-view class="cart-list" scroll-y>
      <view v-for="(item, dishId) in cart" :key="dishId" class="cart-item">
        <image :src="item.image" class="item-image" mode="aspectFill"></image>
        <view class="item-info">
          <text class="item-name">{{ item.name }}</text>
          <text class="item-price">¥{{ item.price }}</text>
        </view>
        <view class="item-counter">
          <view class="counter-btn" @click="reduceCart(dishId)">-</view>
          <text class="counter-num">{{ item.quantity }}</text>
          <view class="counter-btn add" @click="addCart(dishId)">+</view>
        </view>
      </view>
      
      <view v-if="Object.keys(cart).length === 0" class="empty-cart">
        <image src="/static/empty-cart.png" class="empty-icon"></image>
        <text class="empty-text">购物车还是空的</text>
        <button class="go-order-btn" @click="goBack">去点餐</button>
      </view>
    </scroll-view>
    
    <view v-if="Object.keys(cart).length > 0" class="cart-footer">
      <view class="total-info">
        <text class="total-label">合计:</text>
        <text class="total-price">¥{{ totalPrice.toFixed(2) }}</text>
      </view>
      <button class="checkout-btn" @click="goToPayment">去结算</button>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      cart: {}
    };
  },
  computed: {
    totalPrice() {
      return Object.values(this.cart).reduce((sum, item) => sum + item.price * item.quantity, 0);
    }
  },
  onShow() {
    this.loadCart();
  },
  methods: {
    loadCart() {
      this.cart = uni.getStorageSync('cart') || {};
    },
    
    addCart(dishId) {
      this.cart[dishId].quantity++;
      uni.setStorageSync('cart', this.cart);
    },
    
    reduceCart(dishId) {
          // 检查当前数量是否已经为1（即将减到0）
          if (this.cart[dishId].quantity <= 1) {
            uni.showModal({
              title: '提示',
              content: '不能再减了！',
              showCancel: false,
              confirmText: '知道了'
            });
            return; // 直接返回，不执行后续的减操作
          }
          
          // 正常减少数量
          this.cart[dishId].quantity--;
          
          // 检查是否需要从购物车移除（数量为0）
          if (this.cart[dishId].quantity <= 0) {
            this.$delete(this.cart, dishId);
          }
          
          uni.setStorageSync('cart', this.cart);
          
          // 如果购物车变空了，重新加载
          if (Object.keys(this.cart).length === 0) {
            this.loadCart();
          }
        },
    
    goBack() {
      uni.navigateBack();
    },
    
    goToPayment() {
      // 检查购物车是否为空
      if (Object.keys(this.cart).length === 0 || this.totalPrice === 0) {
        uni.showToast({
          title: '购物车为空，无法结算',
          icon: 'none'
        });
        return;
      }
      
      uni.navigateTo({
        url: '/pages/payment/payment'
      });
    }
  }
};
</script>

<style scoped>
.cart-container {
  min-height: 100vh;
  background: #F5F5F5;
  display: flex;
  flex-direction: column;
}

.cart-list {
  flex: 1;
  padding: 20rpx;
}

.cart-item {
  background: white;
  border-radius: 20rpx;
  padding: 20rpx;
  margin-bottom: 20rpx;
  display: flex;
  align-items: center;
}

.item-image {
  width: 120rpx;
  height: 120rpx;
  border-radius: 10rpx;
  flex-shrink: 0;
}

.item-info {
  flex: 1;
  margin-left: 20rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.item-name {
  font-size: 30rpx;
  color: #333;
  font-weight: bold;
  margin-bottom: 20rpx;
}

.item-price {
  font-size: 32rpx;
  color: #FF6B6B;
  font-weight: bold;
}

.item-counter {
  display: flex;
  align-items: center;
  margin-left: 20rpx;
}

.counter-btn {
  width: 50rpx;
  height: 50rpx;
  border-radius: 50%;
  background: #F0F0F0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36rpx;
  color: #666;
}

.counter-btn.add {
  background: #1E90FF;
  color: white;
}

.counter-num {
  margin: 0 20rpx;
  font-size: 28rpx;
  min-width: 40rpx;
  text-align: center;
}

.empty-cart {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100rpx 0;
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
  margin-bottom: 40rpx;
}

.go-order-btn {
  background: #1E90FF;
  color: white;
  padding: 20rpx 60rpx;
  border-radius: 50rpx;
  font-size: 28rpx;
  border: none;
}

.cart-footer {
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

.checkout-btn {
  background: #1E90FF;
  color: white;
  padding: 20rpx 60rpx;
  border-radius: 50rpx;
  font-size: 32rpx;
  font-weight: bold;
  border: none;
}
</style>