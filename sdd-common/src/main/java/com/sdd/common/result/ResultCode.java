package com.sdd.common.result;

import lombok.Getter;

/**
 * 业务状态码枚举
 * <p>SDD 规范：所有业务状态码在此统一定义，禁止在业务代码中硬编码状态码</p>
 */
@Getter
public enum ResultCode {

    // ======================== 通用 2xx ========================
    SUCCESS(200, "success"),
    CREATED(201, "created"),
    NO_CONTENT(204, "no content"),

    // ======================== 客户端错误 4xx ========================
    BAD_REQUEST(400, "Bad Request"),
    UNAUTHORIZED(401, "Unauthorized"),
    FORBIDDEN(403, "Forbidden"),
    NOT_FOUND(404, "Not Found"),
    METHOD_NOT_ALLOWED(405, "Method Not Allowed"),
    CONFLICT(409, "Conflict"),
    UNPROCESSABLE_ENTITY(422, "Unprocessable Entity"),
    TOO_MANY_REQUESTS(429, "Too Many Requests"),

    // ======================== 服务端错误 5xx ========================
    FAILED(500, "Internal Server Error"),
    NOT_IMPLEMENTED(501, "Not Implemented"),
    SERVICE_UNAVAILABLE(503, "Service Unavailable"),

    // ======================== 业务错误 1xxxx ========================
    // 用户模块
    USER_NOT_FOUND(10001, "用户不存在"),
    USER_ALREADY_EXISTS(10002, "用户已存在"),
    USER_PASSWORD_ERROR(10003, "密码错误"),
    USER_ACCOUNT_DISABLED(10004, "账号已禁用"),

    // 认证模块
    TOKEN_INVALID(20001, "Token 无效"),
    TOKEN_EXPIRED(20002, "Token 已过期"),
    TOKEN_MISSING(20003, "Token 缺失"),
    REFRESH_TOKEN_EXPIRED(20004, "Refresh Token 已过期"),

    // 参数校验
    PARAM_INVALID(30001, "参数校验失败"),
    PARAM_MISSING(30002, "必填参数缺失"),
    ;

    private final int code;
    private final String message;

    ResultCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
