<template>
  <view class="login-container">
    <!-- 背景装饰 -->
    <view class="bg-decoration">
      <view class="circle circle-1"></view>
      <view class="circle circle-2"></view>
      <view class="circle circle-3"></view>
    </view>
    
    <!-- Logo和欢迎文字 -->
    <view class="login-header">
      <image src="/static/logoo.png" class="logo" mode="aspectFit"></image>
      <text class="app-name">美食点餐系统</text>
      <text class="welcome-text">欢迎使用</text>
    </view>
    
    <!-- 扫码区域 -->
    <view class="qr-section">
      <view class="qr-card" :class="{ scanning: isScanning }">
        <image src="/static/qr-code-sample.png" class="qr-code" mode="aspectFit"></image>
        <view class="scan-line" v-if="isScanning"></view>
        <view class="qr-corners">
          <view class="corner top-left"></view>
          <view class="corner top-right"></view>
          <view class="corner bottom-left"></view>
          <view class="corner bottom-right"></view>
        </view>
      </view>
      
      <text class="scan-tip">{{ scanTip }}</text>
      
      <!-- 扫码状态提示 -->
      <view v-if="scanStatus" class="scan-status" :class="scanStatus">
        <image 
          :src="scanStatus === 'success' ? '/static/check-circle.png' : '/static/loading.png'" 
          class="status-icon"
          :class="{ rotating: scanStatus === 'loading' }"
        ></image>
        <text class="status-text">{{ statusText }}</text>
      </view>
    </view>
    
    <!-- 操作按钮 -->
    <view class="action-section">
      <button class="scan-btn" @click="startScan" :disabled="isScanning">
        <image src="/static/scan-icon.png" class="btn-icon"></image>
        <text>{{ isScanning ? '扫描中...' : '开始扫码' }}</text>
      </button>
      
      <view class="divider">
        <view class="line"></view>
        <text class="divider-text">或</text>
        <view class="line"></view>
      </view>
      
      <button class="quick-login-btn" @click="quickLogin">
        <image src="/static/quick-login.png" class="btn-icon"></image>
        <text>快速体验</text>
      </button>
    </view>
    
    <!-- 底部说明 -->
    <view class="footer">
      <text class="footer-text">扫描餐桌二维码登录</text>
      <text class="footer-text">或使用快速体验功能</text>
    </view>
    
    <!-- 模拟扫码成功动画遮罩 -->
    <view v-if="showSuccessModal" class="success-modal">
      <view class="success-content">
        <image src="/static/success-animation.png" class="success-animation"></image>
        <text class="success-text">登录成功</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      isScanning: false,
      scanTip: '使用微信扫一扫，扫描餐桌二维码',
      scanStatus: '', // loading, success, error
      statusText: '',
      showSuccessModal: false
    };
  },
  onLoad() {
    // 检查是否已登录（已有桌台信息）
    const tableInfo = uni.getStorageSync('tableInfo');
    if (tableInfo) {
      // 已登录，直接跳转到首页
      uni.switchTab({
        url: '/pages/home/home'
      });
    }
  },
  methods: {
    // 开始扫码
    startScan() {
      if (this.isScanning) return;
      
      this.isScanning = true;
      this.scanTip = '请对准餐桌二维码';
      this.scanStatus = 'loading';
      this.statusText = '扫描中...';
      
      // 模拟扫码过程
      setTimeout(() => {
        this.simulateScanSuccess();
      }, 2000);
      
      // 实际项目中可以使用真实的扫码功能
      /*
      uni.scanCode({
        success: (res) => {
          this.handleScanResult(res.result);
        },
        fail: (err) => {
          this.handleScanError();
        }
      });
      */
    },
    
    // 模拟扫码成功
    simulateScanSuccess() {
      this.scanStatus = 'success';
      this.statusText = '扫码成功';
      
      // 生成模拟的桌台信息
      const tableNum = Math.floor(Math.random() * 20) + 1;
      const tableInfo = {
        id: tableNum,
        table_number: `${tableNum}号桌`,
        merchant_id: 1,
        qr_code: `TABLE_${tableNum}_MERCHANT_1`,
        status: 0
      };
      
      // 保存桌台信息
      uni.setStorageSync('tableInfo', tableInfo);
      
      // 显示成功动画
      this.showSuccessModal = true;
      
      // 延迟跳转
      setTimeout(() => {
        this.navigateToScan();
      }, 1500);
    },
    
    // 处理扫码错误
    handleScanError() {
      this.isScanning = false;
      this.scanStatus = 'error';
      this.statusText = '扫码失败，请重试';
      this.scanTip = '使用微信扫一扫，扫描餐桌二维码';
      
      uni.showToast({
        title: '扫码失败',
        icon: 'none'
      });
      
      // 3秒后重置状态
      setTimeout(() => {
        this.scanStatus = '';
        this.statusText = '';
      }, 3000);
    },
    
    // 处理真实扫码结果
    handleScanResult(qrCode) {
      const match = qrCode.match(/TABLE_(\d+)_MERCHANT_(\d+)/);
      if (match) {
        const tableNum = match[1];
        const merchantId = match[2];
        const tableInfo = {
          id: parseInt(tableNum),
          table_number: `${tableNum}号桌`,
          merchant_id: parseInt(merchantId),
          qr_code: qrCode,
          status: 0
        };
        
        uni.setStorageSync('tableInfo', tableInfo);
        this.simulateScanSuccess();
      } else {
        this.handleScanError();
      }
    },
    
    // 快速体验（跳过登录）
    quickLogin() {
      uni.showLoading({ title: '进入中...' });
      
      // 生成随机桌号
      const tableNum = Math.floor(Math.random() * 20) + 1;
      const tableInfo = {
        id: tableNum,
        table_number: `${tableNum}号桌`,
        merchant_id: 1,
        qr_code: `TABLE_${tableNum}_MERCHANT_1`,
        status: 0
      };
      
      uni.setStorageSync('tableInfo', tableInfo);
      
      setTimeout(() => {
        uni.hideLoading();
        this.navigateToScan();
      }, 800);
    },
    
    // 跳转到扫码页面
    navigateToScan() {
      uni.reLaunch({
        url: '/pages/scan/scan'
      });
    }
  }
};
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60rpx 40rpx;
}

/* 背景装饰圆圈 */
.bg-decoration {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
}

.circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
}

.circle-1 {
  width: 400rpx;
  height: 400rpx;
  top: -100rpx;
  right: -100rpx;
}

.circle-2 {
  width: 300rpx;
  height: 300rpx;
  bottom: 100rpx;
  left: -50rpx;
}

.circle-3 {
  width: 200rpx;
  height: 200rpx;
  top: 50%;
  right: 50rpx;
}

/* 头部Logo区域 */
.login-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 80rpx;
  z-index: 1;
}

.logo {
  width: 160rpx;
  height: 160rpx;
  margin-bottom: 30rpx;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20rpx);
  }
}

.app-name {
  font-size: 48rpx;
  font-weight: bold;
  color: white;
  margin-bottom: 10rpx;
  text-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.2);
}

.welcome-text {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
}

/* 二维码区域 */
.qr-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 80rpx;
  z-index: 1;
}

.qr-card {
  width: 500rpx;
  height: 500rpx;
  background: white;
  border-radius: 30rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  box-shadow: 0 20rpx 60rpx rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.qr-card.scanning {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    box-shadow: 0 20rpx 60rpx rgba(0, 0, 0, 0.3);
  }
  50% {
    box-shadow: 0 20rpx 60rpx rgba(102, 126, 234, 0.6);
  }
}

.qr-code {
  width: 400rpx;
  height: 400rpx;
}

/* 扫描线动画 */
.scan-line {
  position: absolute;
  width: 100%;
  height: 4rpx;
  background: linear-gradient(90deg, transparent, #667eea, transparent);
  animation: scan 2s linear infinite;
}

@keyframes scan {
  0% {
    top: 0;
  }
  100% {
    top: 100%;
  }
}

/* 四角装饰 */
.qr-corners {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

.corner {
  position: absolute;
  width: 60rpx;
  height: 60rpx;
  border: 6rpx solid #667eea;
}

.corner.top-left {
  top: 20rpx;
  left: 20rpx;
  border-right: none;
  border-bottom: none;
  border-radius: 20rpx 0 0 0;
}

.corner.top-right {
  top: 20rpx;
  right: 20rpx;
  border-left: none;
  border-bottom: none;
  border-radius: 0 20rpx 0 0;
}

.corner.bottom-left {
  bottom: 20rpx;
  left: 20rpx;
  border-right: none;
  border-top: none;
  border-radius: 0 0 0 20rpx;
}

.corner.bottom-right {
  bottom: 20rpx;
  right: 20rpx;
  border-left: none;
  border-top: none;
  border-radius: 0 0 20rpx 0;
}

.scan-tip {
  margin-top: 40rpx;
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
  text-align: center;
}

/* 扫码状态 */
.scan-status {
  margin-top: 30rpx;
  display: flex;
  align-items: center;
  padding: 20rpx 40rpx;
  border-radius: 50rpx;
  background: rgba(255, 255, 255, 0.2);
}

.status-icon {
  width: 40rpx;
  height: 40rpx;
  margin-right: 15rpx;
}

.status-icon.rotating {
  animation: rotate 1s linear infinite;
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.status-text {
  font-size: 28rpx;
  color: white;
}

/* 操作按钮区域 */
.action-section {
  width: 100%;
  z-index: 1;
}

.scan-btn,
.quick-login-btn {
  width: 100%;
  height: 100rpx;
  border-radius: 50rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  font-weight: bold;
  border: none;
  box-shadow: 0 10rpx 30rpx rgba(0, 0, 0, 0.2);
  transition: all 0.3s;
}

.scan-btn {
  background: white;
  color: #667eea;
  margin-bottom: 40rpx;
}

.scan-btn:disabled {
  opacity: 0.6;
}

.scan-btn:active:not(:disabled),
.quick-login-btn:active {
  transform: scale(0.95);
}

.quick-login-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2rpx solid rgba(255, 255, 255, 0.5);
}

.btn-icon {
  width: 40rpx;
  height: 40rpx;
  margin-right: 15rpx;
}

/* 分隔线 */
.divider {
  display: flex;
  align-items: center;
  margin: 40rpx 0;
}

.line {
  flex: 1;
  height: 2rpx;
  background: rgba(255, 255, 255, 0.3);
}

.divider-text {
  margin: 0 20rpx;
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.7);
}

/* 底部说明 */
.footer {
  margin-top: auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  z-index: 1;
}

.footer-text {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.7);
  line-height: 1.8;
}

/* 成功动画遮罩 */
.success-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  animation: fadeIn 0.3s;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.success-content {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.success-animation {
  width: 200rpx;
  height: 200rpx;
  animation: scaleIn 0.5s ease-out;
}

@keyframes scaleIn {
  from {
    transform: scale(0);
  }
  to {
    transform: scale(1);
  }
}

.success-text {
  margin-top: 30rpx;
  font-size: 36rpx;
  font-weight: bold;
  color: white;
}
</style>