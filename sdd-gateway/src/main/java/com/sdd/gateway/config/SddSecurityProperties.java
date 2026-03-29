package com.sdd.gateway.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * SDD 安全相关配置
 * <p>通过 @ConfigurationProperties 正确绑定 YAML 中的 List 类型配置</p>
 */
@Data
@Component
@ConfigurationProperties(prefix = "sdd.security")
public class SddSecurityProperties {

    /**
     * JWT 密钥（从 application.yml sdd.security.jwt.secret 读取）
     */
    private Jwt jwt = new Jwt();

    /**
     * 白名单路径（无需 JWT 鉴权）
     */
    private List<String> whiteList = new ArrayList<>();

    @Data
    public static class Jwt {
        private String secret = "sdd-microservice-jwt-secret-key-minimum-32-chars";
    }
}
