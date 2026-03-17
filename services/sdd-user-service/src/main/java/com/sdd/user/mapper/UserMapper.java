package com.sdd.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sdd.user.model.entity.User;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户 Mapper
 * <p>继承 MyBatis Plus BaseMapper，获得 CRUD 能力</p>
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
}
