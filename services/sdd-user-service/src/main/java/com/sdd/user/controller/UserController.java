package com.sdd.user.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.sdd.common.result.Result;
import com.sdd.user.model.dto.CreateUserDTO;
import com.sdd.user.model.dto.UpdateUserDTO;
import com.sdd.user.model.vo.UserVO;
import com.sdd.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 用户控制器
 * <p>
 * SDD 规范：
 * 1. 此控制器实现 OpenAPI 契约中定义的所有接口
 * 2. 接口方法签名必须与契约对应的 operationId 语义一致
 * 3. 如启用代码生成模式，可直接 implements 生成的接口
 * </p>
 */
@Tag(name = "users", description = "用户管理")
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(operationId = "listUsers", summary = "分页查询用户列表")
    @GetMapping
    public Result<Page<UserVO>> listUsers(
            @Parameter(description = "页码") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "每页数量") @RequestParam(defaultValue = "20") int size,
            @Parameter(description = "搜索关键词") @RequestParam(required = false) String keyword,
            @Parameter(description = "状态过滤") @RequestParam(required = false) String status) {
        return Result.success(userService.listUsers(page, size, keyword, status));
    }

    @Operation(operationId = "createUser", summary = "创建用户")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Result<UserVO> createUser(@Valid @RequestBody CreateUserDTO dto) {
        return Result.success(userService.createUser(dto));
    }

    @Operation(operationId = "getUserById", summary = "根据 ID 查询用户")
    @GetMapping("/{userId}")
    public Result<UserVO> getUserById(
            @Parameter(description = "用户 ID") @PathVariable Long userId) {
        return Result.success(userService.getUserById(userId));
    }

    @Operation(operationId = "getCurrentUser", summary = "获取当前登录用户")
    @GetMapping("/me")
    public Result<UserVO> getCurrentUser(
            @RequestHeader("X-User-Id") String userId) {
        return Result.success(userService.getUserById(Long.parseLong(userId)));
    }

    @Operation(operationId = "updateUser", summary = "更新用户信息")
    @PutMapping("/{userId}")
    public Result<UserVO> updateUser(
            @PathVariable Long userId,
            @Valid @RequestBody UpdateUserDTO dto) {
        return Result.success(userService.updateUser(userId, dto));
    }

    @Operation(operationId = "deleteUser", summary = "删除用户")
    @DeleteMapping("/{userId}")
    public Result<Void> deleteUser(@PathVariable Long userId) {
        userService.deleteUser(userId);
        return Result.success();
    }

    @Operation(operationId = "updateUserStatus", summary = "修改用户状态")
    @PatchMapping("/{userId}/status")
    public Result<Void> updateUserStatus(
            @PathVariable Long userId,
            @RequestBody Map<String, String> body) {
        userService.updateUserStatus(userId, body.get("status"));
        return Result.success();
    }
}
