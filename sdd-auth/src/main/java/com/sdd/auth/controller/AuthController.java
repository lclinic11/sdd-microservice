package com.sdd.auth.controller;

import com.sdd.auth.model.LoginRequest;
import com.sdd.auth.model.LoginResponse;
import com.sdd.auth.service.AuthService;
import com.sdd.common.result.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 */
@Tag(name = "Authentication", description = "认证相关接口")
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "用户登录", description = "获取 Access Token 和 Refresh Token")
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return Result.success(authService.login(request));
    }

    @Operation(summary = "刷新 Token")
    @PostMapping("/refresh")
    public Result<LoginResponse> refresh(
            @Parameter(description = "Refresh Token") @RequestParam String refreshToken) {
        return Result.success(authService.refreshToken(refreshToken));
    }

    @Operation(summary = "用户登出")
    @PostMapping("/logout")
    public Result<Void> logout(
            @Parameter(description = "用户 ID（从网关 Header 透传）")
            @RequestHeader("X-User-Id") String userId) {
        authService.logout(userId);
        return Result.success();
    }
}
