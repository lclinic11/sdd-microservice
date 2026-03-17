package com.sdd.common.config;

import com.sdd.common.exception.GlobalExceptionHandler;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;

/**
 * SDD Common 自动配置
 * <p>通过 Spring Boot AutoConfiguration 机制自动生效</p>
 */
@AutoConfiguration
@Import(GlobalExceptionHandler.class)
public class SddCommonAutoConfiguration {

    @Bean
    public GlobalExceptionHandler globalExceptionHandler() {
        return new GlobalExceptionHandler();
    }
}
