<script>
export default {
  onLaunch: function() {
    console.log('App Launch');
    
    // 检查是否已登录（是否有桌台信息）
    const tableInfo = uni.getStorageSync('tableInfo');
    
    if (!tableInfo) {
      // 未登录，跳转到登录页
      uni.reLaunch({
        url: '/pages/login/login'
      });
    } else {
      // 已登录，检查当前页面
      console.log('已有桌台信息，桌号:', tableInfo.table_number);
    }
  },
  onShow: function() {
    console.log('App Show');
  },
  onHide: function() {
    console.log('App Hide');
  }
};
</script>

<style>
/* 全局样式 */
@import './common/common.css';

page {
  background-color: #F5F5F5;
  font-size: 28rpx;
  color: #333;
}

/* 通用按钮样式 */
button {
  border: none;
  outline: none;
}

button::after {
  border: none;
}

/* 输入框样式 */
input {
  outline: none;
}

/* 滚动条样式 */
::-webkit-scrollbar {
  width: 0;
  height: 0;
  background: transparent;
}
</style>