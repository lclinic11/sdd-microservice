package com.sdd.user.model.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

/**
 * 创建用户 DTO
 * <p>SDD 规范：DTO 字段和校验规则与 OpenAPI 契约中的 CreateUserRequest 严格对应</p>
 */
@Data
public class CreateUserDTO {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度 3-50 个字符")
    private String username;

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式不正确")
    private String email;

    @NotBlank(message = "密码不能为空")
    @Size(min = 8, max = 128, message = "密码长度 8-128 个字符")
    private String password;

    @Size(max = 50, message = "昵称最多 50 个字符")
    private String nickname;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    private String avatar;
}
