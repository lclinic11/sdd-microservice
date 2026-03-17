-- SDD User Service 初始化 SQL
-- 执行顺序：先建库，再建表，最后插入初始数据

CREATE DATABASE IF NOT EXISTS `sdd_user`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `sdd_user`;

-- 用户表
CREATE TABLE IF NOT EXISTS `t_user` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户 ID',
    `username`   VARCHAR(50)  NOT NULL COMMENT '用户名（唯一）',
    `email`      VARCHAR(100) NOT NULL COMMENT '邮箱（唯一）',
    `password`   VARCHAR(255) NOT NULL COMMENT '密码（BCrypt 加密）',
    `nickname`   VARCHAR(50)  DEFAULT NULL COMMENT '昵称',
    `phone`      VARCHAR(20)  DEFAULT NULL COMMENT '手机号',
    `avatar`     VARCHAR(500) DEFAULT NULL COMMENT '头像 URL',
    `status`     VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE/DISABLED/PENDING',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`    TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`),
    INDEX `idx_status` (`status`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 初始管理员账号（密码: admin123，BCrypt 加密）
INSERT INTO `t_user` (`username`, `email`, `password`, `nickname`, `status`)
VALUES ('admin', 'admin@sdd.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6gH9W', 'Admin', 'ACTIVE')
ON DUPLICATE KEY UPDATE `updated_at` = NOW();
