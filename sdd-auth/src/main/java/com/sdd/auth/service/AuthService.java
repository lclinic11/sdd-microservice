package com.sdd.auth.service;

import com.sdd.auth.model.LoginRequest;
import com.sdd.auth.model.LoginResponse;
import com.sdd.common.exception.BizException;
import com.sdd.common.result.ResultCode;
import com.sdd.common.utils.JwtUtils;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 认证服务
 * <p>TODO: 实际项目中需对接用户服务做账号验证，此处为脚手架演示</p>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String REFRESH_TOKEN_KEY = "sdd:auth:refresh_token:";

    private final StringRedisTemplate redisTemplate;

    @Value("${sdd.security.jwt.secret}")
    private String jwtSecret;

    @Value("${sdd.security.jwt.access-token-expire-ms:7200000}")
    private long accessTokenExpireMs;

    @Value("${sdd.security.jwt.refresh-token-expire-ms:604800000}")
    private long refreshTokenExpireMs;

    /**
     * 登录
     */
    public LoginResponse login(LoginRequest request) {
        // TODO: 接入实际用户服务验证账号密码
        // 脚手架演示：固定账号
        if (!"admin".equals(request.getUsername()) || !"admin123".equals(request.getPassword())) {
            throw new BizException(ResultCode.USER_PASSWORD_ERROR);
        }

        Long userId = 1L;
        String username = request.getUsername();
        String[] roles = {"ROLE_ADMIN"};

        Map<String, Object> claims = JwtUtils.buildUserClaims(userId, username, roles);

        String accessToken = JwtUtils.generateToken(claims, userId.toString(), jwtSecret, accessTokenExpireMs);
        String refreshToken = JwtUtils.generateToken(claims, userId.toString(), jwtSecret, refreshTokenExpireMs);

        // 存储 Refresh Token 到 Redis
        redisTemplate.opsForValue().set(
                REFRESH_TOKEN_KEY + userId,
                refreshToken,
                refreshTokenExpireMs,
                TimeUnit.MILLISECONDS
        );

        log.info("用户登录成功: userId={}, username={}", userId, username);

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(accessTokenExpireMs / 1000)
                .build();
    }

    /**
     * 刷新 Token
     */
    public LoginResponse refreshToken(String refreshToken) {
        try {
            Claims claims = JwtUtils.parseClaims(refreshToken, jwtSecret);
            String userId = claims.getSubject();

            // 验证 Redis 中的 Refresh Token
            String storedToken = redisTemplate.opsForValue().get(REFRESH_TOKEN_KEY + userId);
            if (!refreshToken.equals(storedToken)) {
                throw new BizException(ResultCode.REFRESH_TOKEN_EXPIRED);
            }

            // 从原 Token 中取出真实的用户名和角色，避免硬编码
            String username = claims.get("username", String.class);
            @SuppressWarnings("unchecked")
            List<String> roleList = claims.get("roles", List.class);
            String[] roles = roleList != null ? roleList.toArray(new String[0]) : new String[]{"ROLE_USER"};

            // 重新生成 Access Token
            Map<String, Object> newClaims = JwtUtils.buildUserClaims(Long.parseLong(userId), username, roles);
            String newAccessToken = JwtUtils.generateToken(newClaims, userId, jwtSecret, accessTokenExpireMs);

            return LoginResponse.builder()
                    .accessToken(newAccessToken)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .expiresIn(accessTokenExpireMs / 1000)
                    .build();
        } catch (BizException e) {
            throw e;
        } catch (Exception e) {
            throw new BizException(ResultCode.REFRESH_TOKEN_EXPIRED);
        }
    }

    /**
     * 登出
     */
    public void logout(String userId) {
        redisTemplate.delete(REFRESH_TOKEN_KEY + userId);
        log.info("用户登出: userId={}", userId);
    }
}
