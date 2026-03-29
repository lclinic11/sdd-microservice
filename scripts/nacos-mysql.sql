-- ============================================================
-- Nacos 2.3 MySQL 持久化建表脚本
-- 来源：https://github.com/alibaba/nacos/blob/develop/distribution/conf/mysql-schema.sql
-- 执行时机：MySQL 容器启动时自动执行（docker-entrypoint-initdb.d/02）
-- ============================================================

CREATE DATABASE IF NOT EXISTS `nacos_config`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `nacos_config`;

CREATE TABLE IF NOT EXISTS `config_info` (
    `id`                 BIGINT(20)    NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            VARCHAR(255)  NOT NULL COMMENT 'data_id',
    `group_id`           VARCHAR(128)  DEFAULT NULL COMMENT 'group_id',
    `content`            LONGTEXT      NOT NULL COMMENT 'content',
    `md5`                VARCHAR(32)   DEFAULT NULL COMMENT 'md5',
    `gmt_create`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           TEXT          DEFAULT NULL COMMENT 'source user',
    `src_ip`             VARCHAR(50)   DEFAULT NULL COMMENT 'source ip',
    `app_name`           VARCHAR(128)  DEFAULT NULL COMMENT 'app_name',
    `tenant_id`          VARCHAR(128)  DEFAULT '' COMMENT '租户字段',
    `c_desc`             VARCHAR(256)  DEFAULT NULL COMMENT 'configuration description',
    `c_use`              VARCHAR(64)   DEFAULT NULL COMMENT 'configuration usage',
    `effect`             VARCHAR(64)   DEFAULT NULL COMMENT '配置生效的描述',
    `type`               VARCHAR(64)   DEFAULT NULL COMMENT '配置的类型',
    `c_schema`           TEXT          DEFAULT NULL COMMENT '配置对应的schema',
    `encrypted_data_key` TEXT          NOT NULL COMMENT '加密使用的key',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfo_datagrouptenant` (`data_id`, `group_id`, `tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_info';

CREATE TABLE IF NOT EXISTS `config_info_aggr` (
    `id`          BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`     VARCHAR(255) NOT NULL COMMENT 'data_id',
    `group_id`    VARCHAR(128) NOT NULL COMMENT 'group_id',
    `datum_id`    VARCHAR(255) NOT NULL COMMENT 'datum_id',
    `content`     LONGTEXT     NOT NULL COMMENT '内容',
    `gmt_modified` DATETIME    NOT NULL COMMENT '修改时间',
    `app_name`    VARCHAR(128) DEFAULT NULL,
    `tenant_id`   VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfoaggr_datagrouptenantdatum` (`data_id`, `group_id`, `tenant_id`, `datum_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='增量发布, 一个DataId能够被多个用户使用';

CREATE TABLE IF NOT EXISTS `config_info_beta` (
    `id`                 BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`            VARCHAR(255) NOT NULL COMMENT 'data_id',
    `group_id`           VARCHAR(128) NOT NULL COMMENT 'group_id',
    `app_name`           VARCHAR(128) DEFAULT NULL COMMENT 'app_name',
    `content`            LONGTEXT     NOT NULL COMMENT 'content',
    `beta_ips`           VARCHAR(1024) DEFAULT NULL COMMENT 'betaIps',
    `md5`                VARCHAR(32)  DEFAULT NULL COMMENT 'md5',
    `gmt_create`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           TEXT         DEFAULT NULL COMMENT 'source user',
    `src_ip`             VARCHAR(50)  DEFAULT NULL COMMENT 'source ip',
    `tenant_id`          VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` TEXT         NOT NULL COMMENT '加密使用的key',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfobeta_datagrouptenant` (`data_id`, `group_id`, `tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_info_beta';

CREATE TABLE IF NOT EXISTS `config_info_tag` (
    `id`           BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT 'id',
    `data_id`      VARCHAR(255) NOT NULL COMMENT 'data_id',
    `group_id`     VARCHAR(128) NOT NULL COMMENT 'group_id',
    `tenant_id`    VARCHAR(128) DEFAULT '' COMMENT '租户字段',
    `tag_id`       VARCHAR(128) NOT NULL COMMENT 'tag_id',
    `app_name`     VARCHAR(128) DEFAULT NULL COMMENT 'app_name',
    `content`      LONGTEXT     NOT NULL COMMENT 'content',
    `md5`          VARCHAR(32)  DEFAULT NULL COMMENT 'md5',
    `gmt_create`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`     TEXT         DEFAULT NULL COMMENT 'source user',
    `src_ip`       VARCHAR(50)  DEFAULT NULL COMMENT 'source ip',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_configinfotag_datagrouptenanttag` (`data_id`, `group_id`, `tenant_id`, `tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_info_tag';

CREATE TABLE IF NOT EXISTS `config_tags_relation` (
    `id`        BIGINT(20)   NOT NULL COMMENT 'id',
    `tag_name`  VARCHAR(128) NOT NULL COMMENT 'tag_name',
    `tag_type`  VARCHAR(64)  DEFAULT NULL COMMENT 'tag_type',
    `data_id`   VARCHAR(255) NOT NULL COMMENT 'data_id',
    `group_id`  VARCHAR(128) NOT NULL COMMENT 'group_id',
    `tenant_id` VARCHAR(128) DEFAULT '' COMMENT 'tenant_id',
    `nid`       BIGINT(20)   NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (`nid`),
    UNIQUE KEY `uk_configtagrelation_configidtag` (`id`, `tag_name`, `tag_type`),
    KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='config_tag_relation';

CREATE TABLE IF NOT EXISTS `group_capacity` (
    `id`                BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `group_id`          VARCHAR(128)        NOT NULL DEFAULT '' COMMENT 'Group ID，空字符表示整个集群',
    `quota`             INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数，，0表示使用默认值',
    `max_aggr_size`     INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='集群、各Group容量信息表';

CREATE TABLE IF NOT EXISTS `his_config_info` (
    `id`                 BIGINT(64) UNSIGNED NOT NULL COMMENT 'id',
    `nid`                BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `data_id`            VARCHAR(255)        NOT NULL COMMENT 'data_id',
    `group_id`           VARCHAR(128)        NOT NULL COMMENT 'group_id',
    `app_name`           VARCHAR(128)        DEFAULT NULL COMMENT 'app_name',
    `content`            LONGTEXT            NOT NULL COMMENT 'content',
    `md5`                VARCHAR(32)         DEFAULT NULL COMMENT 'md5',
    `gmt_create`         DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`       DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    `src_user`           TEXT                DEFAULT NULL COMMENT 'src_user',
    `src_ip`             VARCHAR(50)         DEFAULT NULL COMMENT 'src_ip',
    `op_type`            CHAR(10)            DEFAULT NULL,
    `tenant_id`          VARCHAR(128)        DEFAULT '' COMMENT '租户字段',
    `encrypted_data_key` TEXT                NOT NULL COMMENT '加密使用的key',
    `publish_type`       VARCHAR(50)         DEFAULT 'formal' COMMENT 'publish type gray or formal',
    `gray_name`          VARCHAR(50)         DEFAULT NULL COMMENT 'gray name',
    PRIMARY KEY (`nid`),
    KEY `idx_gmt_create`   (`gmt_create`),
    KEY `idx_gmt_modified` (`gmt_modified`),
    KEY `idx_did`          (`data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='多租户改造';

CREATE TABLE IF NOT EXISTS `tenant_capacity` (
    `id`                BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `tenant_id`         VARCHAR(128)        NOT NULL DEFAULT '' COMMENT 'Tenant ID',
    `quota`             INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '配额，0表示使用默认值',
    `usage`             INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '使用量',
    `max_size`          INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '单个配置大小上限，单位为字节，0表示使用默认值',
    `max_aggr_count`    INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '聚合子配置最大个数',
    `max_aggr_size`     INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '单个聚合数据的子配置大小上限，单位为字节，0表示使用默认值',
    `max_history_count` INT(10) UNSIGNED    NOT NULL DEFAULT '0' COMMENT '最大变更历史数量',
    `gmt_create`        DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified`      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='租户容量信息表';

CREATE TABLE IF NOT EXISTS `tenant_info` (
    `id`           BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
    `kp`           VARCHAR(128) NOT NULL COMMENT 'kp',
    `tenant_id`    VARCHAR(128) DEFAULT '' COMMENT 'tenant_id',
    `tenant_name`  VARCHAR(128) DEFAULT '' COMMENT 'tenant_name',
    `tenant_desc`  VARCHAR(256) DEFAULT NULL COMMENT 'tenant_desc',
    `create_source` VARCHAR(32) DEFAULT NULL COMMENT 'create_source',
    `gmt_create`   BIGINT(20)   NOT NULL COMMENT '创建时间',
    `gmt_modified` BIGINT(20)   NOT NULL COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tenant_info_kptenantid` (`kp`, `tenant_id`),
    KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='tenant_info';

CREATE TABLE IF NOT EXISTS `users` (
    `username` VARCHAR(50)  NOT NULL PRIMARY KEY COMMENT 'username',
    `password` VARCHAR(500) NOT NULL COMMENT 'password',
    `enabled`  BOOLEAN      NOT NULL COMMENT 'enabled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `roles` (
    `username` VARCHAR(50) NOT NULL COMMENT 'username',
    `role`     VARCHAR(50) NOT NULL COMMENT 'role',
    UNIQUE INDEX `idx_user_role` (`username`, `role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `permissions` (
    `role`     VARCHAR(50)  NOT NULL COMMENT 'role',
    `resource` VARCHAR(255) NOT NULL COMMENT 'resource',
    `action`   VARCHAR(8)   NOT NULL COMMENT 'action',
    UNIQUE INDEX `uk_role_permission` (`role`, `resource`, `action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 初始化 Nacos 管理账号（密码：nacos）
INSERT IGNORE INTO `users` (`username`, `password`, `enabled`)
VALUES ('nacos', '$2a$10$EuWPZHzz32dJN7jexM34MOeYirDdFAZm2kuWj7VEOJhhZkDrxfvUu', TRUE);

INSERT IGNORE INTO `roles` (`username`, `role`)
VALUES ('nacos', 'ROLE_ADMIN');
