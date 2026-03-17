# SDD AI Prompt 模板库

> 将以下 Prompt 直接复制给 AI 助手使用，减少重复描述上下文。

---

## 🆕 Prompt 1：新增业务服务（完整）

```
你是一个遵循 SDD（规范驱动开发）理念的 Spring Cloud 后端开发者。

项目规范文件：[粘贴 .ai-context/project-rules.md 内容]

请为以下业务需求创建一个完整的微服务模块，严格按 SDD 10 步骤顺序输出：

业务需求：
[描述你的业务需求，例如：订单服务，支持创建订单、查询订单、取消订单]

参考用户服务的代码结构和风格。
输出时请逐步说明每个文件的用途。
```

---

## 📝 Prompt 2：从需求生成 OpenAPI 契约

```
你是一个 API 设计专家，熟悉 OpenAPI 3.0 规范。

项目约定：
- 所有响应使用统一包装：{ code, message, data, timestamp }
- 每个操作必须有：operationId（驼峰）、summary、tags
- DTO 字段需要描述 validation 规则（minLength/maxLength/pattern）
- 使用 $ref 复用公共 Schema，避免重复定义
- 状态枚举用 Schema 独立定义

请根据以下需求生成完整的 OpenAPI 3.0 YAML 契约：

业务需求：[描述]
服务名：[例如 sdd-order-service]
基础路径：[例如 /orders]
```

---

## ⚙️ Prompt 3：从契约生成 Service 实现

```
你是一个 Spring Boot 后端开发者，遵循以下规范：
- 使用 MyBatis Plus LambdaQueryWrapper，不写 XML
- 异常统一用 BizException + ResultCode
- 写操作加 @Transactional(rollbackFor = Exception.class)
- 使用 @Slf4j 结构化日志

以下是 OpenAPI 契约定义的接口：
[粘贴生成的接口桩代码]

以下是 Entity：
[粘贴 Entity 代码]

请实现 Service 层的所有方法，包含：
1. 必要的业务校验
2. 异常处理
3. 关键操作日志
4. Entity 到 VO 的转换方法
```

---

## 🔍 Prompt 4：契约 Review（破坏性变更检查）

```
请对以下 OpenAPI 契约变更做专业评审：

检查维度：
1. 破坏性变更：字段删除、类型变更、必填字段新增、枚举值删除
2. RESTful 规范：路径命名、HTTP 方法语义、状态码正确性
3. 响应完整性：是否覆盖 400/401/403/404/409/500
4. 安全检查：是否有敏感字段暴露
5. 命名规范：operationId 是否清晰、DTO/VO 命名是否合理

旧版本：
[粘贴旧 YAML]

新版本：
[粘贴新 YAML]

请列出所有问题，标注严重程度（ERROR/WARN/INFO）。
```

---

## 🧪 Prompt 5：生成契约测试

```
请基于以下 OpenAPI 契约，为 [operationId] 接口生成 Spring Boot 集成测试：

测试框架：MockMvc + JUnit 5 + AssertJ
测试场景：
- 正常流程（Happy Path）
- 参数校验失败（400）
- 资源不存在（404）
- 权限不足（401）
- 边界值测试

契约定义：
[粘贴相关接口的 YAML 片段]

Controller 代码：
[粘贴 Controller 代码]
```

---

## 🚀 Prompt 6：添加新接口到现有服务

```
当前用户服务的 OpenAPI 契约：
[粘贴 user-service-api.yaml]

当前 UserController.java：
[粘贴 Controller 代码]

请完成以下任务：
1. 在契约 YAML 中添加接口：[描述新接口需求]
2. 在 UserController 中添加对应方法
3. 在 UserService 中实现业务逻辑
4. 如需新状态码，在 ResultCode 中补充

注意：
- 新接口的 operationId 必须唯一
- 响应格式必须与现有接口一致
- 不要修改已有接口（避免破坏性变更）
```

---

## 🔧 Prompt 7：代码 Review（规范检查）

```
请对以下代码做规范审查，对照规则：
[粘贴 .ai-context/project-rules.md]

重点检查：
1. 是否有业务逻辑写在 Controller
2. 是否有直接返回 Entity（未转 VO）
3. 是否有硬编码错误信息/状态码
4. 是否有未处理的异常（吞异常）
5. 是否有缺少事务注解的写操作
6. VO 中是否有敏感字段

代码：
[粘贴待 Review 的代码]

请用 ERROR/WARN/SUGGEST 三个级别标注每个问题，并给出修改建议。
```
