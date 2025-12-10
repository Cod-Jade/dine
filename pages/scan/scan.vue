<template>
  <view class="scan-container">
    <!-- 顶部标题 -->
    <view class="header">
      <text class="header-title">扫码点餐系统</text>
      <text class="header-subtitle">请扫描桌面二维码开始点餐</text>
    </view>
    
    <!-- 扫码区域 -->
    <view class="scan-section">
      <view class="qr-frame">
        <view class="corner corner-tl"></view>
        <view class="corner corner-tr"></view>
        <view class="corner corner-bl"></view>
        <view class="corner corner-br"></view>
        <image src="/static/qr-placeholder.png" class="qr-placeholder" mode="aspectFit"></image>
        <view v-if="isScanning" class="scan-line"></view>
      </view>
      
      <!-- 扫码提示 -->
      <text class="scan-tip">{{ scanTip }}</text>
      
      <!-- 扫码按钮 -->
      <button class="scan-btn" @click="startScan" :disabled="isScanning">
        <image src="/static/scan-icon.png" class="btn-icon"></image>
        <text>{{ isScanning ? '扫描中...' : '扫码点餐' }}</text>
      </button>
      
      <!-- 手动输入桌号按钮 -->
      <button class="manual-input-btn" @click="showManualInput">
        <image src="/static/keyboard-icon.png" class="btn-icon"></image>
        <text>手动输入桌号</text>
      </button>
    </view>
    
    <!-- 手动输入桌号弹窗 -->
    <view v-if="showInputModal" class="input-modal">
      <view class="modal-content">
        <view class="modal-header">
          <text class="modal-title">输入桌号</text>
          <image src="/static/close.png" class="close-icon" @click="closeInputModal"></image>
        </view>
        
        <view class="input-section">
          <text class="input-label">桌号</text>
          <input 
            v-model="tableNumber" 
            type="number" 
            placeholder="请输入桌号(如: 1, 2, 3...)" 
            class="table-input"
            @input="validateTableNumber"
          />
        </view>
        
        <!-- 就餐人数选择 -->
        <view class="select-section">
          <text class="section-title">就餐人数</text>
          <view class="people-options">
            <view 
              v-for="num in [1, 2, 3, 4, 5, 6, 8, 10]" 
              :key="num"
              class="people-item"
              :class="{ active: peopleCount === num }"
              @click="selectPeople(num)"
            >
              <text>{{ num }}人</text>
            </view>
          </view>
        </view>
        
        <!-- 用餐类型选择 -->
        <view class="select-section">
          <text class="section-title">用餐类型</text>
          <view class="type-options">
            <view 
              class="type-item"
              :class="{ active: orderType === 1 }"
              @click="selectOrderType(1)"
            >
              <image src="/static/dinein.png" class="type-icon"></image>
              <text>堂食</text>
            </view>
            <view 
              class="type-item"
              :class="{ active: orderType === 2 }"
              @click="selectOrderType(2)"
            >
              <image src="/static/takeout.png" class="type-icon"></image>
              <text>打包</text>
            </view>
          </view>
        </view>
        
        <!-- 确认按钮 -->
        <button class="confirm-input-btn" @click="confirmManualInput">
          确认开始点餐
        </button>
      </view>
    </view>
    
    <!-- 扫码成功后的信息确认 -->
    <view v-if="showConfirm" class="confirm-modal">
      <view class="modal-content">
        <view class="modal-header">
          <image src="/static/success.png" class="success-icon"></image>
          <text class="modal-title">扫码成功</text>
        </view>
        
        <view class="table-info">
          <view class="info-item highlight">
            <text class="label">当前桌号为:</text>
            <text class="value">{{ tableInfo.table_number }}</text>
          </view>
        </view>
        
        <!-- 就餐人数选择 -->
        <view class="select-section">
          <text class="section-title">就餐人数</text>
          <view class="people-options">
            <view 
              v-for="num in [1, 2, 3, 4, 5, 6, 8, 10]" 
              :key="num"
              class="people-item"
              :class="{ active: peopleCount === num }"
              @click="selectPeople(num)"
            >
              <text>{{ num }}人</text>
            </view>
          </view>
        </view>
        
        <!-- 用餐类型选择 -->
        <view class="select-section">
          <text class="section-title">用餐类型</text>
          <view class="type-options">
            <view 
              class="type-item"
              :class="{ active: orderType === 1 }"
              @click="selectOrderType(1)"
            >
              <image src="/static/dinein.png" class="type-icon"></image>
              <text>堂食</text>
            </view>
            <view 
              class="type-item"
              :class="{ active: orderType === 2 }"
              @click="selectOrderType(2)"
            >
              <image src="/static/takeout.png" class="type-icon"></image>
              <text>打包</text>
            </view>
          </view>
        </view>
        
        <!-- 确认按钮 -->
        <view class="modal-actions">
          <button class="cancel-btn" @click="cancelConfirm">重新扫码</button>
          <button class="confirm-btn" @click="confirmAndStart">开始点餐</button>
        </view>
      </view>
    </view>
    
    <!-- 底部说明 -->
    <view class="footer">
      <text class="footer-text">扫描桌面二维码,或手动输入桌号</text>
      <text class="footer-text">系统将自动识别桌号并开始点餐</text>
    </view>
  </view>
</template>

<script>
import api from '@/utils/api.js';

export default {
  data() {
    return {
      isScanning: false,
      scanTip: '点击按钮扫描桌面二维码',
      showConfirm: false,
      showInputModal: false,
      tableInfo: null,
      tableNumber: '',
      peopleCount: 2,
      orderType: 1,
    };
  },
  onLoad() {
    // 检查是否已有桌台信息
    const existingTable = uni.getStorageSync('tableInfo');
    if (existingTable) {
      uni.showModal({
        title: '提示',
        content: `检测到您之前在${existingTable.table_number},是否继续使用?`,
        confirmText: '继续使用',
        cancelText: '重新扫码',
        success: (res) => {
          if (res.confirm) {
            uni.switchTab({
              url: '/pages/home/home'
            });
          } else {
            uni.removeStorageSync('tableInfo');
            uni.removeStorageSync('peopleCount');
            uni.removeStorageSync('orderType');
          }
        }
      });
    }
  },
  methods: {
    // 开始扫码
    startScan() {
      if (this.isScanning) return;
      
      this.isScanning = true;
      this.scanTip = '请对准桌面二维码';
      
      uni.scanCode({
        success: (res) => {
          console.log('扫码结果:', res.result);
          this.handleScanResult(res.result);
        },
        fail: (err) => {
          console.error('扫码失败:', err);
          this.isScanning = false;
          this.scanTip = '扫码失败,请重试';
          
          if (process.env.NODE_ENV === 'development') {
            setTimeout(() => {
              this.simulateScan();
            }, 500);
          } else {
            uni.showToast({
              title: '扫码失败,请重试',
              icon: 'none'
            });
          }
        },
        complete: () => {
          this.isScanning = false;
        }
      });
      
      setTimeout(() => {
        if (this.isScanning) {
          this.simulateScan();
        }
      }, 2000);
    },
    
    // 模拟扫码(开发用)
    simulateScan() {
      const tableNum = Math.floor(Math.random() * 20) + 1;
      const qrCode = `TABLE_${String(tableNum).padStart(2, '0')}_MERCHANT_1`;
      this.handleScanResult(qrCode);
    },
    
    // 处理扫码结果
    async handleScanResult(qrCode) {
      uni.showLoading({ title: '识别中...' });
      
      try {
        const tableData = await api.getTableByQrCode(qrCode);
        
        if (tableData.status === 1) {
          uni.hideLoading();
          uni.showModal({
            title: '提示',
            content: `${tableData.table_number}正在使用中,是否继续使用此桌?`,
            confirmText: '继续使用',
            cancelText: '重新扫码',
            success: (res) => {
              if (res.confirm) {
                this.tableInfo = tableData;
                this.showConfirm = true;
                this.scanTip = '扫码成功';
              } else {
                this.scanTip = '请扫描其他桌面二维码';
              }
            }
          });
        } else {
          uni.hideLoading();
          this.tableInfo = tableData;
          this.showConfirm = true;
          this.scanTip = '扫码成功';
          
          uni.showToast({
            title: '扫码成功',
            icon: 'success',
            duration: 1500
          });
        }
      } catch (err) {
        uni.hideLoading();
        console.error('获取桌台信息失败:', err);
        
        if (err.offline) {
          this.tableInfo = err.data || this.parseQRCode(qrCode);
          this.showConfirm = true;
          this.scanTip = '扫码成功(离线模式)';
        } else {
          uni.showToast({
            title: '识别失败,请重试',
            icon: 'none'
          });
          this.scanTip = '识别失败,请重新扫码';
        }
      }
    },
    
    // 解析二维码
    parseQRCode(qrCode) {
      const match = qrCode.match(/TABLE_(\d+)_MERCHANT_(\d+)/);
      if (match) {
        const tableNum = match[1];
        const merchantId = match[2];
        return {
          id: parseInt(tableNum),
          table_number: `${parseInt(tableNum)}号桌`,
          merchant_id: parseInt(merchantId),
          qr_code: qrCode,
          status: 0
        };
      }
      throw new Error('无效的二维码');
    },
    
    // 显示手动输入弹窗
    showManualInput() {
      this.showInputModal = true;
      this.tableNumber = '';
      this.peopleCount = 2;
      this.orderType = 1;
    },
    
    // 关闭手动输入弹窗
    closeInputModal() {
      this.showInputModal = false;
      this.tableNumber = '';
    },
    
    // 验证桌号
    validateTableNumber(e) {
      const value = e.detail.value;
      // 只允许输入数字
      this.tableNumber = value.replace(/[^\d]/g, '');
    },
    
    // 确认手动输入
    confirmManualInput() {
      if (!this.tableNumber || this.tableNumber === '0') {
        uni.showToast({
          title: '请输入有效的桌号',
          icon: 'none'
        });
        return;
      }
      
      // 构造桌台信息
      const tableNum = parseInt(this.tableNumber);
      this.tableInfo = {
        id: tableNum,
        table_number: `${tableNum}号桌`,
        merchant_id: 1,
        qr_code: `TABLE_${String(tableNum).padStart(2, '0')}_MERCHANT_1`,
        status: 0
      };
      
      // 关闭输入弹窗
      this.showInputModal = false;
      
      // 直接确认并开始点餐
      this.confirmAndStart();
    },
    
    // 选择就餐人数
    selectPeople(num) {
      this.peopleCount = num;
    },
    
    // 选择用餐类型
    selectOrderType(type) {
      this.orderType = type;
    },
    
    // 取消确认,重新扫码
    cancelConfirm() {
      this.showConfirm = false;
      this.tableInfo = null;
      this.peopleCount = 2;
      this.orderType = 1;
      this.scanTip = '点击按钮扫描桌面二维码';
    },
    
    // 确认并开始点餐
    confirmAndStart() {
      if (!this.tableInfo) {
        uni.showToast({
          title: '请先扫码或输入桌号',
          icon: 'none'
        });
        return;
      }
      
      // 保存信息到本地存储
      uni.setStorageSync('tableInfo', this.tableInfo);
      uni.setStorageSync('peopleCount', this.peopleCount);
      uni.setStorageSync('orderType', this.orderType);
      
      // 清空购物车
      uni.removeStorageSync('cart');
      
      uni.showLoading({ title: '进入中...' });
      
      setTimeout(() => {
        uni.hideLoading();
        uni.switchTab({
          url: '/pages/home/home'
        });
      }, 500);
    }
  }
};
</script>

<style scoped>
.scan-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  flex-direction: column;
  padding: 40rpx;
}

.header {
  text-align: center;
  margin-top: 60rpx;
  margin-bottom: 80rpx;
}

.header-title {
  display: block;
  font-size: 48rpx;
  font-weight: bold;
  color: white;
  margin-bottom: 20rpx;
  text-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.2);
}

.header-subtitle {
  display: block;
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
}

.scan-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.qr-frame {
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
  margin-bottom: 60rpx;
}

.qr-placeholder {
  width: 400rpx;
  height: 400rpx;
  opacity: 0.3;
}

.corner {
  position: absolute;
  width: 60rpx;
  height: 60rpx;
  border: 6rpx solid #667eea;
}

.corner-tl {
  top: 20rpx;
  left: 20rpx;
  border-right: none;
  border-bottom: none;
  border-radius: 20rpx 0 0 0;
}

.corner-tr {
  top: 20rpx;
  right: 20rpx;
  border-left: none;
  border-bottom: none;
  border-radius: 0 20rpx 0 0;
}

.corner-bl {
  bottom: 20rpx;
  left: 20rpx;
  border-right: none;
  border-top: none;
  border-radius: 0 0 0 20rpx;
}

.corner-br {
  bottom: 20rpx;
  right: 20rpx;
  border-left: none;
  border-top: none;
  border-radius: 0 0 20rpx 0;
}

.scan-line {
  position: absolute;
  width: 100%;
  height: 4rpx;
  background: linear-gradient(90deg, transparent, #667eea, transparent);
  animation: scanning 2s linear infinite;
}

@keyframes scanning {
  0% { top: 0; }
  100% { top: 100%; }
}

.scan-tip {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 40rpx;
  text-align: center;
}

.scan-btn,
.manual-input-btn {
  width: 500rpx;
  height: 100rpx;
  border-radius: 50rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  font-weight: bold;
  border: none;
  box-shadow: 0 10rpx 30rpx rgba(0, 0, 0, 0.2);
  margin-bottom: 20rpx;
}

.scan-btn {
  background: white;
  color: #667eea;
}

.scan-btn:disabled {
  opacity: 0.6;
}

.manual-input-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2rpx solid rgba(255, 255, 255, 0.5);
}

.btn-icon {
  width: 40rpx;
  height: 40rpx;
  margin-right: 15rpx;
}

.footer {
  margin-top: auto;
  padding-top: 60rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.footer-text {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.7);
  line-height: 1.8;
}

/* 手动输入弹窗 */
.input-modal {
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
  padding: 40rpx;
}

.modal-content {
  width: 100%;
  max-width: 600rpx;
  background: white;
  border-radius: 30rpx;
  padding: 50rpx 40rpx;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    transform: translateY(100rpx);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 40rpx;
}

.modal-title {
  font-size: 36rpx;
  font-weight: bold;
  color: #333;
}

.close-icon {
  width: 40rpx;
  height: 40rpx;
  opacity: 0.6;
}

.input-section {
  margin-bottom: 40rpx;
}

.input-label {
  display: block;
  font-size: 28rpx;
  color: #666;
  margin-bottom: 20rpx;
}

.table-input {
  width: 100%;
  height: 80rpx;
  background: #F5F5F5;
  border-radius: 15rpx;
  padding: 0 30rpx;
  font-size: 32rpx;
  color: #333;
}

.select-section {
  margin-bottom: 40rpx;
}

.section-title {
  display: block;
  font-size: 28rpx;
  color: #666;
  margin-bottom: 20rpx;
}

.people-options {
  display: flex;
  flex-wrap: wrap;
  gap: 15rpx;
}

.people-item {
  width: calc(25% - 12rpx);
  height: 80rpx;
  background: #F5F5F5;
  border-radius: 15rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  color: #666;
  border: 2rpx solid transparent;
}

.people-item.active {
  background: #E3F2FD;
  color: #1E90FF;
  border-color: #1E90FF;
  font-weight: bold;
}

.type-options {
  display: flex;
  gap: 20rpx;
}

.type-item {
  flex: 1;
  height: 120rpx;
  background: #F5F5F5;
  border-radius: 15rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  color: #666;
  border: 2rpx solid transparent;
}

.type-item.active {
  background: #E3F2FD;
  color: #1E90FF;
  border-color: #1E90FF;
  font-weight: bold;
}

.type-icon {
  width: 50rpx;
  height: 50rpx;
  margin-bottom: 10rpx;
}

.confirm-input-btn {
  width: 100%;
  height: 80rpx;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50rpx;
  font-size: 30rpx;
  font-weight: bold;
  border: none;
}

/* 确认弹窗 */
.confirm-modal {
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
  padding: 40rpx;
}

.success-icon {
  width: 100rpx;
  height: 100rpx;
  margin-bottom: 20rpx;
}

.table-info {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20rpx;
  padding: 30rpx;
  margin-bottom: 40rpx;
}

.info-item {
  display: flex;
  align-items: center;
  justify-content: center;
}

.info-item.highlight .label {
  font-size: 32rpx;
  color: white;
  font-weight: bold;
}

.info-item.highlight .value {
  font-size: 48rpx;
  color: #FFD700;
  font-weight: bold;
  margin-left: 10rpx;
}

.modal-actions {
  display: flex;
  gap: 20rpx;
}

.cancel-btn,
.confirm-btn {
  flex: 1;
  height: 80rpx;
  border-radius: 50rpx;
  font-size: 30rpx;
  border: none;
}

.cancel-btn {
  background: #F5F5F5;
  color: #666;
}

.confirm-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: bold;
}
</style>