package com.sdd.user.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户视图对象（响应 VO）
 * <p>SDD 规范：VO 与 OpenAPI 契约中的 UserVO Schema 严格对应</p>
 */
@Data
public class UserVO {

    private Long id;

    private String username;

    private String email;

    private String nickname;

    /**
     * 手机号（脱敏）
     */
    private String phone;

    private String avatar;

    private String status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
