package com.sdd.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * 全局请求日志过滤器
 * <p>记录请求链路并注入 TraceId，便于分布式追踪</p>
 */
@Slf4j
@Component
public class RequestLogFilter implements GlobalFilter, Ordered {

    private static final String TRACE_ID_HEADER = "X-Trace-Id";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        long startTime = System.currentTimeMillis();
        String traceId = UUID.randomUUID().toString().replace("-", "");

        // 注入 TraceId 到请求头
        ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                .header(TRACE_ID_HEADER, traceId)
                .build();

        ServerWebExchange mutatedExchange = exchange.mutate()
                .request(mutatedRequest)
                .build();

        // 响应头中也带上 TraceId
        mutatedExchange.getResponse().getHeaders().add(TRACE_ID_HEADER, traceId);

        log.info("[GATEWAY] --> {} {} traceId={}",
                exchange.getRequest().getMethod(),
                exchange.getRequest().getPath(),
                traceId);

        return chain.filter(mutatedExchange).then(Mono.fromRunnable(() -> {
            long duration = System.currentTimeMillis() - startTime;
            log.info("[GATEWAY] <-- {} {} status={} duration={}ms traceId={}",
                    exchange.getRequest().getMethod(),
                    exchange.getRequest().getPath(),
                    mutatedExchange.getResponse().getStatusCode(),
                    duration,
                    traceId);
        }));
    }

    @Override
    public int getOrder() {
        return -200; // 比 JWT 过滤器更优先
    }
}
