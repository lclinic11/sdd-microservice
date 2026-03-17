# SDD 项目 AI 编程规范

> 此文件供 AI 编程助手（Cursor/GitHub Copilot/WorkBuddy 等）读取，
> 所有 AI 生成的代码必须遵守以下规范。

---

## 项目技术栈

- **框架**：Spring Boot 3.2 + Spring Cloud 2023 + Spring Cloud Alibaba
- **ORM**：MyBatis Plus 3.5（使用 LambdaQueryWrapper，禁止写 XML SQL）
- **数据库**：MySQL 8.0，实体类对应表名前缀 `t_`
- **缓存**：Redis（使用 StringRedisTemplate）
- **认证**：JWT，网关统一鉴权，用户信息通过 `X-User-Id` / `X-Username` Header 透传

---

## SDD 核心规范

### 1. 响应格式（强制）
所有 Controller 返回类型必须是 `Result<T>`，禁止直接返回实体或 DTO。

```java
// ✅ 正确
public Result<UserVO> getUser(@PathVariable Long id) {
    return Result.success(userService.getUserById(id));
}

// ❌ 错误
public UserVO getUser(@PathVariable Long id) {
    return userService.getUserById(id);
}
```

### 2. 异常处理（强制）
业务异常必须继承 `BizException`，使用 `ResultCode` 枚举，禁止硬编码错误信息。

```java
// ✅ 正确
throw new BizException(ResultCode.USER_NOT_FOUND);

// ❌ 错误
throw new RuntimeException("用户不存在");
throw new BizException(404, "用户不存在"); // 禁止硬编码
```

### 3. 分层规范（强制）
- **Entity**：仅包含数据库字段，加 `@TableName`、`@TableId`、`@TableLogic`
- **DTO**：请求参数，加 Bean Validation 注解（@NotBlank/@Size/@Pattern）
- **VO**：响应数据，敏感字段必须脱敏（手机号、邮箱等）
- **Service**：业务逻辑，不直接操作 HTTP 相关对象
- **Controller**：只负责参数接收和 Result 包装，不写业务逻辑

### 4. MyBatis Plus 规范
```java
// ✅ 推荐：LambdaQueryWrapper
userMapper.selectOne(new LambdaQueryWrapper<User>()
    .eq(User::getUsername, username)
    .eq(User::getDeleted, 0));

// ✅ 推荐：逻辑删除自动处理（不需要手动加 deleted=0 条件）
userMapper.deleteById(id); // 自动设置 deleted=1

// ❌ 避免：字符串字段名（类型不安全）
new QueryWrapper<User>().eq("username", username)
```

### 5. 日志规范
```java
// ✅ 使用 @Slf4j + 结构化日志
@Slf4j
public class UserService {
    public UserVO createUser(CreateUserDTO dto) {
        // ...
        log.info("创建用户成功: id={}, username={}", user.getId(), user.getUsername());
    }
}

// ❌ 禁止使用 System.out.println
```

### 6. 事务规范
```java
// ✅ 写操作加事务
@Transactional(rollbackFor = Exception.class)
public UserVO createUser(CreateUserDTO dto) { ... }

// 查询不加事务（减少连接占用）
public UserVO getUserById(Long id) { ... }
```

---

## 新增业务服务的 SDD 标准步骤

当 AI 被要求新增一个业务服务时，必须按以下顺序生成：

```
Step 1: 生成 OpenAPI 契约文件
  └─ services/{service-name}/src/main/resources/specs/{service-name}-api.yaml

Step 2: 配置 pom.xml（引用 openapi-generator-maven-plugin）

Step 3: 生成 Entity / DTO / VO（对应契约 Schema）

Step 4: 生成 Mapper（extends BaseMapper<Entity>）

Step 5: 生成 Service（业务逻辑）

Step 6: 生成 Controller（实现契约接口）

Step 7: 生成 application.yml

Step 8: 补充 ResultCode 新业务状态码

Step 9: 补充 init-db.sql 建表语句

Step 10: 更新 sdd-gateway/application.yml 路由配置
```

---

## 禁止事项（AI 生成代码时严格遵守）

- ❌ 禁止在 Controller 写业务逻辑
- ❌ 禁止直接返回 Entity（必须转成 VO）
- ❌ 禁止硬编码状态码数字（使用 ResultCode 枚举）
- ❌ 禁止吞异常（catch 后 return null 或 return 默认值）
- ❌ 禁止在 Service 注入 HttpServletRequest（破坏层次）
- ❌ 禁止修改 `target/generated-sources/` 下的生成代码
- ❌ 禁止在 VO 中返回密码、Token 等敏感字段

---

## 参考代码风格

以下文件作为 AI 生成代码的风格参考：

- Controller 参考：`services/sdd-user-service/src/main/java/com/sdd/user/controller/UserController.java`
- Service 参考：`services/sdd-user-service/src/main/java/com/sdd/user/service/UserService.java`
- 契约参考：`services/sdd-user-service/src/main/resources/specs/user-service-api.yaml`
