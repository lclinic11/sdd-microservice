-- ============================================================
-- SDD Microservice - 业务库初始化 SQL
-- 执行顺序：MySQL 启动时自动执行（docker-entrypoint-initdb.d/01）
-- ============================================================

-- ============================
-- 用户服务库
-- ============================
CREATE DATABASE IF NOT EXISTS `sdd_user`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- ============================
-- 认证服务库（与用户库分离，支持独立扩展）
-- ============================
CREATE DATABASE IF NOT EXISTS `sdd_auth`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- 用户服务：t_user 表
-- ============================================================
USE `sdd_user`;

CREATE TABLE IF NOT EXISTS `t_user` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT   COMMENT '用户 ID（Snowflake）',
    `username`   VARCHAR(50)  NOT NULL                  COMMENT '用户名（唯一，3-50字符）',
    `email`      VARCHAR(100) NOT NULL                  COMMENT '邮箱（唯一）',
    `password`   VARCHAR(255) NOT NULL                  COMMENT '密码（BCrypt 加密，禁止明文）',
    `nickname`   VARCHAR(50)  DEFAULT NULL              COMMENT '昵称',
    `phone`      VARCHAR(20)  DEFAULT NULL              COMMENT '手机号（脱敏后展示）',
    `avatar`     VARCHAR(500) DEFAULT NULL              COMMENT '头像 URL',
    `status`     VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/DISABLED/PENDING',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP               COMMENT '创建时间',
    `updated_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
    `deleted`    TINYINT      NOT NULL DEFAULT 0        COMMENT '逻辑删除：0-正常，1-已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username`    (`username`),
    UNIQUE KEY `uk_email`       (`email`),
    INDEX        `idx_status`   (`status`, `deleted`),
    INDEX        `idx_phone`    (`phone`),
    INDEX        `idx_created`  (`created_at`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='用户表';

-- 初始管理员账号（密码: admin123，BCrypt 加密）
INSERT INTO `t_user` (`username`, `email`, `password`, `nickname`, `status`)
VALUES ('admin', 'admin@sdd.com',
        '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6gH9W',
        'Admin', 'ACTIVE')
ON DUPLICATE KEY UPDATE `updated_at` = NOW();

-- 测试用户账号（密码: test123，BCrypt 加密）
INSERT INTO `t_user` (`username`, `email`, `password`, `nickname`, `status`)
VALUES ('test_user', 'test@sdd.com',
        '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        '测试用户', 'ACTIVE')
ON DUPLICATE KEY UPDATE `updated_at` = NOW();

-- ============================================================
-- 认证服务：refresh_token 表（存储 Refresh Token）
-- ============================================================
USE `sdd_auth`;

CREATE TABLE IF NOT EXISTS `t_refresh_token` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id`     BIGINT       NOT NULL               COMMENT '用户 ID',
    `token`       VARCHAR(512) NOT NULL               COMMENT 'Refresh Token（已哈希）',
    `device_info` VARCHAR(200) DEFAULT NULL           COMMENT '设备信息（User-Agent 截取）',
    `ip_address`  VARCHAR(50)  DEFAULT NULL           COMMENT '登录 IP',
    `expired_at`  DATETIME     NOT NULL               COMMENT '过期时间',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `revoked`     TINYINT      NOT NULL DEFAULT 0     COMMENT '是否已吊销：0-有效，1-已吊销',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_token`       (`token`(255)),
    INDEX        `idx_user_id`  (`user_id`, `revoked`),
    INDEX        `idx_expired`  (`expired_at`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Refresh Token 表（支持多设备登录）';
