package com.sdd.common.exception;

import com.sdd.common.result.ResultCode;
import lombok.Getter;

/**
 * 业务异常基类
 * <p>SDD 规范：所有业务异常统一继承此类，禁止直接抛出 RuntimeException</p>
 */
@Getter
public class BizException extends RuntimeException {

    private final int code;
    private final String message;

    public BizException(ResultCode resultCode) {
        super(resultCode.getMessage());
        this.code = resultCode.getCode();
        this.message = resultCode.getMessage();
    }

    public BizException(int code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }

    public BizException(ResultCode resultCode, Throwable cause) {
        super(resultCode.getMessage(), cause);
        this.code = resultCode.getCode();
        this.message = resultCode.getMessage();
    }

    public BizException(String message) {
        super(message);
        this.code = ResultCode.FAILED.getCode();
        this.message = message;
    }
}
