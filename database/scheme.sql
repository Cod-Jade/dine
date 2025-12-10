-- 创建数据库
CREATE DATABASE IF NOT EXISTS food DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE food;

-- 商家表
CREATE TABLE IF NOT EXISTS merchant (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL COMMENT '商家名称',
    image VARCHAR(255) COMMENT '商家图片',
    description TEXT COMMENT '商家描述',
    status TINYINT DEFAULT 1 COMMENT '状态:1营业,0休息',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家表';

-- 商家轮播图表
CREATE TABLE IF NOT EXISTS merchant_banner (
    id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL COMMENT '轮播图URL',
    sort_order INT DEFAULT 0 COMMENT '排序',
    FOREIGN KEY (merchant_id) REFERENCES merchant(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家轮播图';

-- 分类表
CREATE TABLE IF NOT EXISTS category (
    id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_id INT NOT NULL,
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    sort_order INT DEFAULT 0 COMMENT '排序',
    FOREIGN KEY (merchant_id) REFERENCES merchant(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品分类表';

-- 菜品表
CREATE TABLE IF NOT EXISTS dish (
    id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_id INT NOT NULL,
    category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '菜品名称',
    price DECIMAL(10,2) NOT NULL COMMENT '价格',
    image VARCHAR(255) COMMENT '菜品图片',
    description TEXT COMMENT '菜品描述',
    status TINYINT DEFAULT 1 COMMENT '状态:1上架,0下架',
    sales INT DEFAULT 0 COMMENT '销量',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (merchant_id) REFERENCES merchant(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜品表';

-- 桌台表
CREATE TABLE IF NOT EXISTS dining_table (
    id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_id INT NOT NULL,
    table_number VARCHAR(20) NOT NULL COMMENT '桌号',
    qr_code VARCHAR(255) COMMENT '二维码内容',
    status TINYINT DEFAULT 0 COMMENT '状态:0空闲,1使用中',
    FOREIGN KEY (merchant_id) REFERENCES merchant(id) ON DELETE CASCADE,
    UNIQUE KEY unique_table (merchant_id, table_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='桌台表';

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_no VARCHAR(50) UNIQUE NOT NULL COMMENT '订单号',
    merchant_id INT NOT NULL,
    table_id INT NOT NULL,
    people_count INT NOT NULL COMMENT '就餐人数',
    order_type TINYINT NOT NULL COMMENT '订单类型:1堂食,2打包',
    total_amount DECIMAL(10,2) NOT NULL COMMENT '总金额',
    payment_method VARCHAR(20) COMMENT '支付方式',
    remark TEXT COMMENT '备注',
    status TINYINT DEFAULT 1 COMMENT '状态:1待支付,2已支付,3制作中,4已完成,5已取消,6已退款',
    wait_time INT DEFAULT 0 COMMENT '预计等待时间(分钟)',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (merchant_id) REFERENCES merchant(id),
    FOREIGN KEY (table_id) REFERENCES dining_table(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 订单明细表
CREATE TABLE IF NOT EXISTS order_detail (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    dish_id INT NOT NULL,
    dish_name VARCHAR(100) NOT NULL COMMENT '菜品名称',
    dish_price DECIMAL(10,2) NOT NULL COMMENT '菜品价格',
    quantity INT NOT NULL COMMENT '数量',
    subtotal DECIMAL(10,2) NOT NULL COMMENT '小计',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dish(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 评价表
CREATE TABLE IF NOT EXISTS review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    dish_id INT NOT NULL,
    rating TINYINT NOT NULL COMMENT '评分:1差评,5好评',
    content TEXT COMMENT '评价内容',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (dish_id) REFERENCES dish(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';

-- 插入测试数据
INSERT INTO merchant (name, image, description, status) VALUES 
('美味餐厅', 'https://via.placeholder.com/300x200', '提供各类美食', 1);

INSERT INTO merchant_banner (merchant_id, image_url, sort_order) VALUES
(1, 'https://via.placeholder.com/800x300/1E90FF', 1),
(1, 'https://via.placeholder.com/800x300/4169E1', 2),
(1, 'https://via.placeholder.com/800x300/0000CD', 3);

INSERT INTO category (merchant_id, name, sort_order) VALUES
(1, '饮料', 1),
(1, '面食', 2),
(1, '米饭', 3),
(1, '菜品', 4);

INSERT INTO dish (merchant_id, category_id, name, price, image, description, status, sales) VALUES
(1, 1, '可乐', 5.00, 'https://via.placeholder.com/150', '冰爽可乐', 1, 100),
(1, 1, '橙汁', 8.00, 'https://via.placeholder.com/150', '鲜榨橙汁', 1, 80),
(1, 2, '牛肉面', 18.00, 'https://via.placeholder.com/150', '经典牛肉面', 1, 200),
(1, 2, '担担面', 15.00, 'https://via.placeholder.com/150', '麻辣担担面', 1, 150),
(1, 3, '扬州炒饭', 20.00, 'https://via.placeholder.com/150', '经典扬州炒饭', 1, 180),
(1, 3, '盖浇饭', 22.00, 'https://via.placeholder.com/150', '各式盖浇饭', 1, 160),
(1, 4, '宫保鸡丁', 28.00, 'https://via.placeholder.com/150', '经典川菜', 1, 220),
(1, 4, '鱼香肉丝', 26.00, 'https://via.placeholder.com/150', '下饭神器', 1, 190);

INSERT INTO dining_table (merchant_id, table_number, qr_code, status) VALUES
(1, 'A01', 'TABLE_A01_MERCHANT_1', 0),
(1, 'A02', 'TABLE_A02_MERCHANT_1', 0),
(1, 'A03', 'TABLE_A03_MERCHANT_1', 0);

INSERT INTO review (order_id, dish_id, rating, content) VALUES
(1, 1, 5, '很好喝,冰爽解渴'),
(1, 3, 5, '牛肉很多,面很劲道'),
(1, 7, 4, '味道不错,就是有点辣');