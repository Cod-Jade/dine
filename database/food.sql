/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50726
 Source Host           : localhost:3306
 Source Schema         : food

 Target Server Type    : MySQL
 Target Server Version : 50726
 File Encoding         : 65001

 Date: 26/11/2025 10:15:58
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `merchant_id`(`merchant_id`) USING BTREE,
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, 1, '饮料', 1);
INSERT INTO `category` VALUES (2, 1, '面食', 2);
INSERT INTO `category` VALUES (3, 1, '米饭', 3);
INSERT INTO `category` VALUES (4, 1, '菜品', 4);
INSERT INTO `category` VALUES (5, 1, '餐具', 5);


-- ----------------------------
-- Table structure for dining_table
-- ----------------------------
DROP TABLE IF EXISTS `dining_table`;
CREATE TABLE `dining_table`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL,
  `table_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '桌号',
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '二维码内容',
  `status` tinyint(4) NULL DEFAULT 0 COMMENT '状态:0空闲,1使用中',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `unique_table`(`merchant_id`, `table_number`) USING BTREE,
  CONSTRAINT `dining_table_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '桌台表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dining_table
-- ----------------------------
INSERT INTO `dining_table` VALUES (1, 1, 'A01', 'TABLE_A01_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (2, 1, 'A02', 'TABLE_A02_MERCHANT_1', 1);
INSERT INTO `dining_table` VALUES (3, 1, 'A03', 'TABLE_A03_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (4, 1, 'A04', 'TABLE_A04_MERCHANT_1', 2);
INSERT INTO `dining_table` VALUES (5, 1, 'A05', 'TABLE_A05_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (6, 1, 'B01', 'TABLE_B01_MERCHANT_1', 1);
INSERT INTO `dining_table` VALUES (7, 1, 'B02', 'TABLE_B02_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (8, 1, 'B03', 'TABLE_B03_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (9, 1, 'B04', 'TABLE_B04_MERCHANT_1', 2);
INSERT INTO `dining_table` VALUES (10, 1, 'C01', 'TABLE_C01_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (11, 1, 'C02', 'TABLE_C02_MERCHANT_1', 1);
INSERT INTO `dining_table` VALUES (12, 1, 'C03', 'TABLE_C03_MERCHANT_1', 0);
INSERT INTO `dining_table` VALUES (13, 1, 'V01', 'TABLE_V01_MERCHANT_1', 2);
INSERT INTO `dining_table` VALUES (14, 1, 'V02', 'TABLE_V02_MERCHANT_1', 0);

-- ----------------------------
-- Table structure for dish
-- ----------------------------
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜品名称',
  `price` decimal(10, 2) NOT NULL COMMENT '价格',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜品图片',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '菜品描述',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态:1上架,0下架',
  `sales` int(11) NULL DEFAULT 0 COMMENT '销量',
  `create_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `update_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `merchant_id`(`merchant_id`) USING BTREE,
  INDEX `category_id`(`category_id`) USING BTREE,
  CONSTRAINT `dish_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `dish_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dish
-- ----------------------------
INSERT INTO `dish` VALUES (1, 1, 1, '可乐', 5.00, 'https://img2.baidu.com/it/u=2078402918,79376553&fm=253&fmt=auto&app=120&f=JPEG?w=701&h=973', '冰爽可乐', 1, 100, '2025-11-19 10:16:58', '2025-11-19 10:33:10');
INSERT INTO `dish` VALUES (2, 1, 1, '橙汁', 5.00, 'https://img2.baidu.com/it/u=3278644732,470687140&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500', '鲜榨橙汁', 1, 80, '2025-11-19 10:16:58', '2025-11-19 10:33:50');
INSERT INTO `dish` VALUES (3, 1, 1, '雪碧', 5.00, 'https://img0.baidu.com/it/u=1854504507,3325424340&fm=253&fmt=auto&app=138&f=PNG?w=500&h=500', '清爽雪碧', 1, 90, '2025-11-19 10:16:58', '2025-11-19 10:34:28');
INSERT INTO `dish` VALUES (4, 1, 1, '奶茶', 10.00, 'https://img2.baidu.com/it/u=1398275612,3414736605&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=753', '珍珠奶茶', 1, 150, '2025-11-19 10:16:58', '2025-11-19 10:35:17');
INSERT INTO `dish` VALUES (5, 1, 1, '酸梅汤', 6.00, 'https://img2.baidu.com/it/u=3138324122,2258173453&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=666', '自制酸梅汤', 1, 70, '2025-11-19 10:16:58', '2025-11-19 10:41:44');
INSERT INTO `dish` VALUES (6, 1, 2, '牛肉面', 14.00, 'https://img2.baidu.com/it/u=2843515428,3347467&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=1199', '经典牛肉面', 1, 200, '2025-11-19 10:16:58', '2025-11-19 10:42:57');
INSERT INTO `dish` VALUES (7, 1, 2, '担担面', 10.00, 'https://img0.baidu.com/it/u=3068648685,3858825998&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=667', '麻辣担担面', 1, 150, '2025-11-19 10:16:58', '2025-11-19 10:55:43');
INSERT INTO `dish` VALUES (8, 1, 2, '阳春面', 10.00, 'https://img1.baidu.com/it/u=3854564728,3162565744&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=712', '清淡阳春面', 1, 120, '2025-11-19 10:16:58', '2025-11-19 10:58:03');
INSERT INTO `dish` VALUES (9, 1, 2, '炸酱面', 14.00, 'https://img2.baidu.com/it/u=1220408012,2503649053&fm=253&fmt=auto&app=138&f=JPEG?w=697&h=500', '北京炸酱面', 1, 140, '2025-11-19 10:16:58', '2025-11-19 10:58:30');
INSERT INTO `dish` VALUES (10, 1, 2, '馄饨', 14.00, 'https://img2.baidu.com/it/u=1071501535,927374308&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=667', '鲜肉馄饨', 1, 110, '2025-11-19 10:16:58', '2025-11-19 10:58:52');
INSERT INTO `dish` VALUES (11, 1, 3, '扬州炒饭', 20.00, 'https://img2.baidu.com/it/u=2970432166,1850624943&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=1067', '经典扬州炒饭', 1, 180, '2025-11-19 10:16:58', '2025-11-19 10:59:58');
INSERT INTO `dish` VALUES (12, 1, 3, '辣椒炒肉盖浇饭', 22.00, 'https://img1.baidu.com/it/u=970606838,3960782256&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=667', '辣椒炒肉盖浇饭', 1, 160, '2025-11-19 10:16:58', '2025-11-19 11:00:15');
INSERT INTO `dish` VALUES (13, 1, 3, '蛋炒饭', 16.00, 'https://img2.baidu.com/it/u=1841487987,142350148&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=631', '金黄蛋炒饭', 1, 170, '2025-11-19 10:16:58', '2025-11-19 11:01:36');
INSERT INTO `dish` VALUES (14, 1, 3, '卤肉饭', 20.00, 'https://img1.baidu.com/it/u=3485375772,2033760221&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=749', '台湾卤肉饭', 1, 190, '2025-11-19 10:16:58', '2025-11-19 11:02:28');
INSERT INTO `dish` VALUES (15, 1, 3, '咖喱鸡肉饭', 25.00, 'https://img0.baidu.com/it/u=3245060016,2689055663&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=668', '咖喱鸡肉饭', 1, 190, '2025-11-19 10:16:58', '2025-11-19 11:02:28');
INSERT INTO `dish` VALUES (16, 1, 4, '水煮鱼', 48.00, 'https://img1.baidu.com/it/u=3297309940,756093208&fm=253&fmt=auto&app=138&f=JPEG?w=667&h=500', '麻辣水煮鱼', 1, 210, '2025-11-19 10:16:58', '2025-11-19 11:04:34');
INSERT INTO `dish` VALUES (17, 1, 4, '清蒸鲈鱼', 48.00, 'https://img0.baidu.com/it/u=120524872,2779789719&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=667', '鲜嫩清蒸鱼', 1, 160, '2025-11-19 10:16:58', '2025-11-19 11:05:03');
INSERT INTO `dish` VALUES (18, 1, 4, '蒜蓉西兰花', 22.00, 'https://img2.baidu.com/it/u=570088923,3740989632&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=667', '清炒时蔬', 1, 90, '2025-11-19 10:16:58', '2025-11-19 11:05:21');
INSERT INTO `dish` VALUES (19, 1, 3, '米饭', 3.00, 'https://img2.baidu.com/it/u=436320617,1208427743&fm=253&fmt=auto&app=120&f=JPEG?w=1200&h=800', '新鲜米饭', 1, 190, '2025-11-19 10:16:58', '2025-11-19 11:02:28');
INSERT INTO `dish` VALUES (20, 1, 5, '餐具', 1.00, 'https://t15.baidu.com/it/u=2225330948,2801238429&fm=224&app=112&f=JPEG?w=500&h=500', '筷子', 1, 190, '2025-11-19 10:16:58', '2025-11-19 11:02:28');

-- ----------------------------
-- Table structure for merchant
-- ----------------------------
DROP TABLE IF EXISTS `merchant`;
CREATE TABLE `merchant`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商家名称',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家图片',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商家描述',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态:1营业,0休息',
  `create_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `update_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of merchant
-- ----------------------------
INSERT INTO `merchant` VALUES (1, '美味餐厅', 'https://via.placeholder.com/300x200', '提供各类美食', 1, '2025-11-19 10:01:00', '2025-11-19 10:01:00');

-- ----------------------------
-- Table structure for merchant_banner
-- ----------------------------
DROP TABLE IF EXISTS `merchant_banner`;
CREATE TABLE `merchant_banner`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) NOT NULL,
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '轮播图URL',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `merchant_id`(`merchant_id`) USING BTREE,
  CONSTRAINT `merchant_banner_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家轮播图' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_detail
-- ----------------------------
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `dish_id` int(11) NOT NULL,
  `dish_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜品名称',
  `dish_price` decimal(10, 2) NOT NULL COMMENT '菜品价格',
  `quantity` int(11) NOT NULL COMMENT '数量',
  `subtotal` decimal(10, 2) NOT NULL COMMENT '小计',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id`) USING BTREE,
  INDEX `dish_id`(`dish_id`) USING BTREE,
  CONSTRAINT `order_detail_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `order_detail_ibfk_2` FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_detail
-- ----------------------------

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `merchant_id` int(11) NOT NULL,
  `table_id` int(11) NOT NULL,
  `people_count` int(11) NOT NULL COMMENT '就餐人数',
  `order_type` tinyint(4) NOT NULL COMMENT '订单类型:1堂食,2打包',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '总金额',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付方式',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '备注',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态:1待支付,2已支付,3制作中,4已完成,5已取消,6已退款',
  `wait_time` int(11) NULL DEFAULT 0 COMMENT '预计等待时间(分钟)',
  `create_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  `update_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_no`(`order_no`) USING BTREE,
  INDEX `merchant_id`(`merchant_id`) USING BTREE,
  INDEX `table_id`(`table_id`) USING BTREE,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`table_id`) REFERENCES `dining_table` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------

-- ----------------------------
-- Table structure for review
-- ----------------------------
DROP TABLE IF EXISTS `review`;
CREATE TABLE `review`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `dish_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL COMMENT '评分:1差评,5好评',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '评价内容',
  `create_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id`) USING BTREE,
  INDEX `dish_id`(`dish_id`) USING BTREE,
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 61 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of review
-- ----------------------------
INSERT INTO `review` VALUES (41, 1, 1, 5, '很好喝,冰爽解渴', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (42, 1, 3, 5, '牛肉很多,面很劲道', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (43, 1, 7, 4, '味道不错,就是有点辣', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (44, 1, 8, 5, '鱼香肉丝超下饭，配菜很足', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (45, 2, 2, 4, '橙汁很新鲜，就是有点小贵', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (46, 2, 4, 5, '担担面麻辣够味，推荐！', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (47, 2, 5, 3, '扬州炒饭有点油，希望改进', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (48, 2, 6, 4, '盖浇饭分量足，菜品种类多', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (49, 3, 9, 5, '雪碧气泡很足，夏天喝太爽了', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (50, 3, 10, 5, '奶茶甜度刚好，珍珠Q弹', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (51, 3, 11, 4, '酸梅汤解腻神器，搭配火锅绝了', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (52, 3, 12, 4, '炸酱面酱香味浓，面条劲道', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (53, 4, 13, 5, '蛋炒饭粒粒分明，鸡蛋超多', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (54, 4, 14, 4, '卤肉饭肥瘦适中，酱汁浓郁', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (55, 4, 15, 5, '水煮鱼肉质鲜嫩，麻辣入味', '2025-11-19 10:24:40');
INSERT INTO `review` VALUES (56, 4, 16, 3, '蒜蓉西兰花有点老，不够脆', '2025-11-19 10:24:40');

SET FOREIGN_KEY_CHECKS = 1;
