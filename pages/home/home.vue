<template>
  <view class="home-container">
    <!-- 商家轮播图 -->
    <swiper class="banner-swiper" indicator-dots circular autoplay>
      <swiper-item v-for="(banner, index) in banners" :key="index">
        <image :src="banner" class="banner-image" mode="aspectFill"></image>
      </swiper-item>
    </swiper>
    
    <!-- 搜索栏 -->
    <view class="search-bar">
      <view class="search-input">
        <image src="/static/search.png" class="search-icon"></image>
        <input 
          v-model="keyword" 
          placeholder="搜索菜品" 
          @confirm="searchDish"
          @input="onSearchInput"
          confirm-type="search"
        />
      </view>
    </view>
    
    <!-- 主体内容 -->
    <view class="main-content">
      <!-- 左侧分类 -->
      <scroll-view class="category-list" scroll-y>
        <view 
          v-for="cat in categories" 
          :key="cat.id"
          class="category-item"
          :class="{ active: currentCategory === cat.id }"
          @click="selectCategory(cat.id)"
        >
          <text>{{ cat.name }}</text>
        </view>
      </scroll-view>
      
      <!-- 右侧菜品列表 -->
      <scroll-view class="dish-list" scroll-y>
        <view v-for="dish in dishes" :key="dish.id" class="dish-item">
          <image 
            :src="dish.image" 
            class="dish-image" 
            mode="aspectFill"
            @click="viewDetail(dish.id)"
          ></image>
          <view class="dish-info">
            <text class="dish-name" @click="viewDetail(dish.id)">{{ dish.name }}</text>
            <text class="dish-desc">{{ dish.description }}</text>
            <view class="dish-footer">
              <text class="dish-price">¥{{ dish.price }}</text>
              <text class="dish-sales">月售{{ dish.sales }}</text>
            </view>
          </view>
          <view class="dish-action">
            <view v-if="getCartCount(dish.id) > 0" class="counter">
              <view class="counter-btn" @click="reduceCart(dish)">-</view>
              <text class="counter-num">{{ getCartCount(dish.id) }}</text>
              <view class="counter-btn add" @click="addCart(dish)">+</view>
            </view>
            <view v-else class="add-btn" @click="addCart(dish)">
              <text>+</text>
            </view>
          </view>
        </view>
        
        <view v-if="dishes.length === 0" class="empty-dish">
          <text>暂无菜品</text>
        </view>
      </scroll-view>
    </view>
    
    <!-- 底部购物车 -->
    <view class="cart-bar">
      <view class="order-list-wrapper" @click="goToOrderList">
        <text class="order-text">查看订单</text>
      </view>
      
      <view class="cart-icon-wrapper" @click="goToCart">
        <image src="/static/cart.png" class="cart-icon"></image>
        <view v-if="totalCount > 0" class="cart-badge">{{ totalCount }}</view>
      </view>
      <view class="cart-info" @click="goToCart">
        <text class="cart-price">¥{{ totalPrice.toFixed(2) }}</text>
      </view>
      <view class="cart-btn" :class="{ active: totalPrice >= 0 }" @click="goToCart">
        去结算
      </view>
    </view>
  </view>
</template>

<script>
import api from '@/utils/api.js';

export default {
  data() {
    return {
      merchantId: 1,
      banners: [
		  '/static/banner1.png',
		  '/static/banner2.png'
	  ],
      categories: [],
      dishes: [],
      currentCategory: null,
      keyword: '',
      cart: {}, // { dishId: { ...dishInfo, quantity } }
      tableInfo: null
    };
  },
  computed: {
    totalCount() {
      return Object.values(this.cart).reduce((sum, item) => sum + item.quantity, 0);
    },
    totalPrice() {
      return Object.values(this.cart).reduce((sum, item) => sum + item.price * item.quantity, 0);
    }
  },
  onLoad() {
    this.tableInfo = uni.getStorageSync('tableInfo');
    if (!this.tableInfo) {
      uni.redirectTo({ url: '/pages/scan/scan' });
      return;
    }
    this.merchantId = this.tableInfo.merchant_id;
    
    // 加载购物车数据
    this.cart = uni.getStorageSync('cart') || {};
    
    this.loadData();
  },
  onShow() {
    // 每次显示时刷新购物车
    this.cart = uni.getStorageSync('cart') || {};
  },
  methods: {
    async loadData() {
      uni.showLoading({ title: '加载中...' });
      try {
        const [merchantInfo, categories] = await Promise.all([
          api.getMerchantInfo(this.merchantId),
          api.getCategoryList(this.merchantId)
        ]);
        
        // 使用默认的两个banner图，不被后端数据覆盖
        // this.banners = merchantInfo.banners || [];
        this.categories = categories;
        
        if (categories.length > 0) {
          this.currentCategory = categories[0].id;
          await this.loadDishes();
        }
      } catch (err) {
        console.error('加载数据失败:', err);
      } finally {
        uni.hideLoading();
      }
    },
    
    async loadDishes() {
      try {
        const params = {};
        // 如果有搜索关键词，不使用分类筛选，搜索全部菜品
        if (this.keyword) {
          params.keyword = this.keyword;
        } else if (this.currentCategory) {
          // 没有搜索关键词时才使用分类筛选
          params.categoryId = this.currentCategory;
        }
        this.dishes = await api.getDishList(this.merchantId, params);
      } catch (err) {
        console.error('加载菜品失败:', err);
        this.dishes = [];
      }
    },
    
    selectCategory(categoryId) {
      this.currentCategory = categoryId;
      this.keyword = ''; // 切换分类时清空搜索关键词
      this.loadDishes();
    },
    
    onSearchInput() {
      // 输入搜索内容时实时搜索
      if (this.keyword) {
        this.loadDishes();
      } else {
        // 清空搜索时恢复分类筛选
        this.loadDishes();
      }
    },
    
    searchDish() {
      // 确认搜索
      this.loadDishes();
    },
    
    viewDetail(dishId) {
      uni.navigateTo({
        url: `/pages/detail/detail?id=${dishId}`
      });
    },
    
    getCartCount(dishId) {
      return this.cart[dishId] ? this.cart[dishId].quantity : 0;
    },
    
    addCart(dish) {
      if (this.cart[dish.id]) {
        this.cart[dish.id].quantity++;
      } else {
        this.$set(this.cart, dish.id, {
          ...dish,
          quantity: 1
        });
      }
      uni.setStorageSync('cart', this.cart);
    },
    
    reduceCart(dish) {
      if (this.cart[dish.id]) {
        this.cart[dish.id].quantity--;
        if (this.cart[dish.id].quantity <= 0) {
          this.$delete(this.cart, dish.id);
        }
      }
      uni.setStorageSync('cart', this.cart);
    },
    
    goToCart() {
      if (this.totalCount === 0) {
        uni.showToast({
          title: '购物车为空',
          icon: 'none'
        });
        return;
      }
      uni.navigateTo({
        url: '/pages/cart/cart'
      });
    },
    
    goToOrderList() {
      uni.switchTab({
        url: '/pages/orderList/orderList'
      });
    }
  }
};
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background: #F5F5F5;
  padding-bottom: 120rpx;
}

.banner-swiper {
  width: 100%;
  height: 300rpx;
}

.banner-image {
  width: 100%;
  height: 100%;
}

.search-bar {
  padding: 20rpx;
  background: white;
}

.search-input {
  display: flex;
  align-items: center;
  background: #F5F5F5;
  border-radius: 50rpx;
  padding: 15rpx 30rpx;
}

.search-icon {
  width: 32rpx;
  height: 32rpx;
  margin-right: 15rpx;
}

.search-input input {
  flex: 1;
  font-size: 28rpx;
}

.main-content {
  display: flex;
  height: calc(100vh - 420rpx);
}

.category-list {
  width: 180rpx;
  background: #F8F8F8;
}

.category-item {
  padding: 30rpx 20rpx;
  text-align: center;
  font-size: 28rpx;
  color: #666;
  border-left: 4rpx solid transparent;
}

.category-item.active {
  background: white;
  color: #1E90FF;
  border-left-color: #1E90FF;
  font-weight: bold;
}

.dish-list {
  flex: 1;
  background: white;
  padding: 20rpx;
}

.dish-item {
  display: flex;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #F0F0F0;
}

.dish-image {
  width: 160rpx;
  height: 160rpx;
  border-radius: 10rpx;
  flex-shrink: 0;
}

.dish-info {
  flex: 1;
  margin-left: 20rpx;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.dish-name {
  font-size: 30rpx;
  color: #333;
  font-weight: bold;
  margin-bottom: 10rpx;
}

.dish-desc {
  font-size: 24rpx;
  color: #999;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.dish-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.dish-price {
  font-size: 32rpx;
  color: #FF6B6B;
  font-weight: bold;
}

.dish-sales {
  font-size: 24rpx;
  color: #999;
}

.dish-action {
  display: flex;
  align-items: flex-end;
  margin-left: 20rpx;
}

.counter {
  display: flex;
  align-items: center;
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
}

.add-btn {
  width: 50rpx;
  height: 50rpx;
  border-radius: 50%;
  background: #1E90FF;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36rpx;
}

.empty-dish {
  text-align: center;
  padding: 80rpx 0;
  color: #999;
  font-size: 28rpx;
}

.cart-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 100rpx;
  background: white;
  display: flex;
  align-items: center;
  padding: 0 30rpx;
  z-index: 999;
}

.order-list-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-right: 30rpx;
  padding: 10rpx;
}

.order-icon {
  width: 50rpx;
  height: 50rpx;
  margin-bottom: 5rpx;
}

.order-text {
  background: #666;
  color: white;
  padding: 20rpx 40rpx;
  border-radius: 50rpx;
  font-size: 28rpx;
}

.cart-icon-wrapper {
  position: relative;
  margin-right: 20rpx;
}

.cart-icon {
  width: 80rpx;
  height: 80rpx;
}

.cart-badge {
  position: absolute;
  top: -10rpx;
  right: -10rpx;
  background: #FF6B6B;
  color: white;
  border-radius: 50%;
  width: 40rpx;
  height: 40rpx;
  line-height: 40rpx;
  text-align: center;
  font-size: 20rpx;
}

.cart-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.cart-price {
  font-size: 36rpx;
  color: black;
  font-weight: bold;
}



.cart-btn {
  background: #666;
  color: white;
  padding: 20rpx 40rpx;
  border-radius: 50rpx;
  font-size: 28rpx;
}

.cart-btn.active {
  background: #1E90FF;
}
</style>