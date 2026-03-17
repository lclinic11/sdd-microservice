package com.sdd.common.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 工具类
 */
public class JwtUtils {

    private JwtUtils() {}

    /**
     * 生成 Token
     *
     * @param claims   自定义 Claims
     * @param subject  主题（通常为用户 ID）
     * @param secret   密钥
     * @param expireMs 过期时间（毫秒）
     */
    public static String generateToken(Map<String, Object> claims, String subject,
                                       String secret, long expireMs) {
        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + expireMs))
                .signWith(getSigningKey(secret))
                .compact();
    }

    /**
     * 解析 Token Claims
     */
    public static Claims parseClaims(String token, String secret) {
        return Jwts.parser()
                .verifyWith(getSigningKey(secret))
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * 从 Token 中获取 Subject
     */
    public static String getSubject(String token, String secret) {
        return parseClaims(token, secret).getSubject();
    }

    /**
     * 判断 Token 是否过期
     */
    public static boolean isTokenExpired(String token, String secret) {
        Date expiration = parseClaims(token, secret).getExpiration();
        return expiration.before(new Date());
    }

    /**
     * 构建用户信息 Claims
     */
    public static Map<String, Object> buildUserClaims(Long userId, String username, String[] roles) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("roles", roles);
        return claims;
    }

    private static SecretKey getSigningKey(String secret) {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
