package com.sdd.common.config;

import com.sdd.common.exception.GlobalExceptionHandler;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.context.annotation.Bean;

/**
 * SDD Common 自动配置（仅在 WebMVC/Servlet 环境下生效）
 * <p>通过 Spring Boot AutoConfiguration 机制自动生效</p>
 * <p>Gateway（WebFlux）引入 sdd-common 时不会加载此配置，避免 Servlet 类冲突</p>
 */
@AutoConfiguration
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
public class SddCommonAutoConfiguration {

    @Bean
    public GlobalExceptionHandler globalExceptionHandler() {
        return new GlobalExceptionHandler();
    }
}
