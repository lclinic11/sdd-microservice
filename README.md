# SDD Microservice 脚手架

> **SDD（Specification-Driven Development）规范驱动开发** ×  **Spring Cloud 微服务架构**

---

## 📐 什么是 SDD？

SDD 的核心理念：**API 契约是唯一真实来源（Single Source of Truth）**。

```
传统开发：需求 → 代码 → 文档（文档总落后）
SDD 开发：需求 → 契约（YAML） → 生成代码 → 实现逻辑
```

| 阶段 | 传统方式 | SDD 方式 |
|------|----------|----------|
| 接口定义 | 开完会口头约定 | OpenAPI YAML 文件（版本化管理） |
| 接口文档 | 写完代码再补文档 | 契约即文档，实时准确 |
| 前后端并行 | 等待后端完成 | 基于契约 Mock 并行开发 |
| 接口变更 | 口头通知，容易遗漏 | 改契约触发 CI 破坏性变更检查 |
| 服务集成 | 集成时才发现不一致 | 契约测试提前发现问题 |

---

## 🏗️ 项目架构

```
sdd-microservice/
├── 📄 pom.xml                        # 父工程，统一依赖版本
│
├── 📦 sdd-common/                    # 公共模块（自动配置 Starter）
│   └── src/main/java/com/sdd/common/
│       ├── result/Result.java        # 统一响应体
│       ├── result/ResultCode.java    # 统一状态码
│       ├── exception/BizException.java         # 业务异常基类
│       ├── exception/GlobalExceptionHandler.java # 全局异常处理
│       └── utils/JwtUtils.java       # JWT 工具
│
├── 🌐 sdd-gateway/                   # API 网关（Spring Cloud Gateway）
│   ├── filter/JwtAuthFilter.java     # JWT 鉴权（白名单放行）
│   ├── filter/RequestLogFilter.java  # 请求日志 + TraceId 注入
│   └── resources/application.yml    # 路由配置
│
├── 🔐 sdd-auth/                      # 认证服务（JWT 双 Token）
│   ├── controller/AuthController.java
│   ├── service/AuthService.java
│   └── resources/application.yml
│
├── 🗂️ services/
│   └── sdd-user-service/             # 用户服务（SDD 完整示例）
│       ├── 📝 src/main/resources/specs/
│       │   └── user-service-api.yaml  # ⭐ SDD 契约文件（先写这个！）
│       ├── src/main/java/com/sdd/user/
│       │   ├── controller/UserController.java  # 实现契约接口
│       │   ├── service/UserService.java
│       │   ├── mapper/UserMapper.java
│       │   └── model/{entity,dto,vo}/
│       └── pom.xml                   # openapi-generator 配置
│
├── 📂 docs/specs/                    # 全局共享契约目录（见下方设计决策说明）
├── 🐳 docker-compose.yml             # 本地开发环境（MySQL/Redis/Nacos/Mock）
├── 📋 scripts/
│   ├── init-db.sql                   # 数据库初始化
│   ├── sdd-generate.sh               # 从契约生成代码
│   └── sdd-validate-spec.sh          # 校验契约规范
├── 🤖 .ai-context/
│   ├── project-rules.md              # AI 编程规范（Cursor/Copilot 等自动读取）
│   └── prompt-templates.md           # 7 个场景的 AI Prompt 模板
├── 📐 .cursorrules                   # Cursor IDE 专用规范，AI 补全自动遵循
└── 📁 .github/workflows/ci.yml       # CI 流水线（含契约校验 + 破坏性变更检测）
```

---

## 🚀 快速开始

### 1. 启动基础设施

```bash
cd sdd-microservice
docker compose up -d mysql redis nacos
```

等待服务就绪（约 30 秒）：
- MySQL：localhost:3306
- Redis：localhost:6379
- Nacos：http://localhost:8848/nacos（账号 nacos/nacos）

### 2. 配置环境变量

```bash
cp .env.example .env
# 按需修改 .env 中的配置
```

### 3. 启动服务（本地开发）

```bash
# 方式一：IDEA/IntelliJ 直接运行各模块的 Application 类
# 方式二：Maven 命令
cd sdd-microservice
mvn spring-boot:run -pl sdd-auth
mvn spring-boot:run -pl services/sdd-user-service
mvn spring-boot:run -pl sdd-gateway
```

---

## 📝 SDD 开发工作流

### 添加新接口（标准流程）

```
Step 1：修改契约文件
```

打开对应服务的 `src/main/resources/specs/xxx-api.yaml`，按 OpenAPI 3.0 规范添加新接口定义。

```yaml
# 示例：添加批量导入用户接口
/users/batch-import:
  post:
    tags: [users]
    operationId: batchImportUsers  # ⚠️ operationId 必填，SDD 强制要求
    summary: 批量导入用户
    requestBody:
      ...
```

```
Step 2：生成接口桩
```

```bash
./scripts/sdd-generate.sh sdd-user-service
# 或
cd services/sdd-user-service && mvn generate-sources
```

生成的接口位于：`target/generated-sources/openapi/src/main/java/`

```
Step 3：实现接口
```

在 Controller 中实现生成的接口方法，调用 Service 完成业务逻辑。

```
Step 4：契约测试
```

```bash
# 启动 Mock Server（基于契约自动生成响应）
docker compose up -d prism-user-mock
# Mock 地址：http://localhost:4010
```

---

## 🔧 服务端口说明

| 服务 | 端口 | 说明 |
|------|------|------|
| sdd-gateway | 8080 | API 网关入口 |
| sdd-auth | 8081 | 认证服务 |
| sdd-user-service | 8082 | 用户服务 |
| Nacos | 8848 | 服务注册/配置中心 |
| MySQL | 3306 | 数据库 |
| Redis | 6379 | 缓存 |
| Prism Mock | 4010 | 用户服务 Mock |
| Swagger Editor | 8090 | 在线契约编辑器 |

---

## 🌐 API 访问

所有请求通过网关统一入口：

```bash
# 登录获取 Token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 查询用户列表（携带 Token）
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer <your_token>"

# 直接访问 Swagger UI
open http://localhost:8082/swagger-ui.html
```

---

## 📦 技术栈

| 分类 | 技术选型 |
|------|---------|
| 微服务框架 | Spring Cloud 2023 + Spring Boot 3.2 |
| 服务注册/发现 | Alibaba Nacos 2.3 |
| API 网关 | Spring Cloud Gateway (WebFlux) |
| 认证授权 | JWT (jjwt 0.12) + Redis |
| ORM | MyBatis Plus 3.5 |
| 数据库 | MySQL 8.0 + Druid 连接池 |
| 缓存 | Redis 7 |
| 对象映射 | MapStruct 1.5 |
| API 规范 | OpenAPI 3.0 (Swagger) |
| 代码生成 | openapi-generator-maven-plugin 7.3 |
| Mock Server | Stoplight Prism 4 |
| 规范校验 | Spectral |
| 容器化 | Docker Compose |

---

## 📋 SDD 编码规范

1. **契约优先**：每个新接口必须先在 YAML 中定义，禁止先写代码后补文档
2. **operationId 必填**：每个操作必须有唯一的 `operationId`，作为代码生成的方法名依据
3. **响应统一**：所有接口响应使用 `Result<T>` 包装，与契约中的 Schema 对应
4. **状态码集中**：业务状态码统一在 `ResultCode.java` 中定义，禁止硬编码
5. **异常规范**：业务异常统一继承 `BizException`，禁止直接抛出 `RuntimeException`
6. **VO 脱敏**：敏感字段（手机号、邮箱等）在 VO 层脱敏后返回
7. **逻辑删除**：所有业务表使用 `deleted` 字段做逻辑删除
8. **破坏性变更**：修改已发布契约时，CI 会检查破坏性变更，需要明确的版本策略

---

## 🤖 SDD + AI 编程大模型协作体系

> 本脚手架原生适配 AI 辅助编程——契约文件就是 AI 最好的"上下文输入"。

### 核心理念：契约是 AI 的"说明书"

```
传统 AI 辅助：你描述需求 → AI 猜测生成代码（上下文模糊，质量不稳定）
SDD + AI：    你提供契约 → AI 严格按规范生成代码（有约束，质量可控）
```

### 项目 AI 配置文件

脚手架已预置以下 AI 辅助文件：

| 文件 | 作用 | 谁会读取 |
|------|------|----------|
| **`.cursorrules`** | 项目规范 + 技术栈约定 + 编码风格 | Cursor IDE 自动加载，补全自动遵循 |
| **`.ai-context/project-rules.md`** | 完整项目背景、禁止事项、代码模式 | 任何 AI 助手手动粘贴作为上下文 |
| **`.ai-context/prompt-templates.md`** | 7 个场景的 Prompt 模板 | 开发者复制粘贴到 AI 对话框 |

---

### 七个经典 AI 协作场景

#### 场景 1：需求 → 契约（⭐⭐⭐⭐⭐ 最高价值）

**你负责**：描述业务需求  
**AI 负责**：生成符合项目规范的 OpenAPI YAML

**推荐 Prompt**：

```
你是一个 SDD 架构师。

当前项目规范：
- 所有响应使用 Result<T> 包装（code/message/data/timestamp）
- 错误码定义在 ResultCode.java 中
- 每个操作必须有 operationId、summary、tags
- DTO 使用 Bean Validation 注解校验

请根据以下需求，生成符合 OpenAPI 3.0 规范的 YAML 契约：

需求：[你的业务需求描述]

参考现有契约风格：[粘贴 user-service-api.yaml 片段]
```

---

#### 场景 2：契约 → Service 实现

**流程**：`契约 YAML` → `mvn generate-sources` → `接口桩` → `AI 填充实现`

**推荐 Prompt**：

```
以下是从 OpenAPI 契约生成的接口（勿修改方法签名）：
[粘贴生成的接口代码]

项目约定：
- Service 层处理业务逻辑，Controller 只做参数传递
- 异常统一抛出 BizException，不要 try-catch 吞异常
- 使用 MyBatis Plus LambdaQueryWrapper，不写 XML
- 参考现有 UserService.java 的代码风格

请实现 [操作名称] 的 Service 方法。
```

---

#### 场景 3：契约 Review（质量门禁）

**目标**：提交契约变更前，让 AI 做质量检查

**推荐 Prompt**：

```
请对以下 OpenAPI 契约做评审，检查：
1. 是否有破坏性变更（字段删除/类型变更/必填新增）
2. 命名是否符合 RESTful 规范
3. 错误响应是否完整（400/401/404/409）
4. 分页接口是否有 page/size 参数
5. 敏感字段（password/phone）是否在 VO 中脱敏

旧契约：[粘贴旧版本]
新契约：[粘贴新版本]
```

---

#### 场景 4：从契约生成测试用例

**目标**：AI 自动根据契约生成测试代码（单元测试/集成测试）

**推荐 Prompt**：

```
基于以下 OpenAPI 契约，生成 JUnit 5 测试类：
- 使用 MockMvc 进行 Controller 层测试
- 正常场景 + 异常场景（400/404/409）都要覆盖
- 使用 AssertJ 断言风格
- 测试数据使用 @MethodSource 参数化生成

契约内容：[粘贴 YAML]
```

---

#### 场景 5：代码 Review（对照规范检查）

**目标**：AI 自动检查代码是否符合项目规范

**推荐 Prompt**：

```
请对以下代码做 Review，对照项目规范检查：
1. 是否违反编码规范（见 .ai-context/project-rules.md）
2. 是否有潜在 NPE / SQL 注入风险
3. 异常处理是否合理
4. 是否有代码异味（重复代码、过长方法等）

代码：[粘贴代码]
```

---

#### 场景 6：生成 API 文档/变更日志

**目标**：从契约变更自动生成 Markdown 文档

**推荐 Prompt**：

```
从以下新旧契约对比中，生成 API 变更日志：

格式要求：
1. 新增接口（New）
2. 修改接口（Modified）——列出变更字段
3. 删除接口（Deprecated）
4. 破坏性变更（Breaking Changes）——单独标注风险

旧契约：[粘贴旧版本]
新契约：[粘贴新版本]
```

---

#### 场景 7：Mock Server 数据生成

**目标**：AI 帮你生成 Prism Mock Server 的扩展数据

**推荐 Prompt**：

```
为以下 OpenAPI 契约生成 Prism Mock 扩展配置：
- /users/:id 的 GET 请求，返回 3 种场景的数据
  - id=1：正常用户
  - id=2：已删除用户（返回 404）
  - id=3：冻结用户（返回 409）
- 使用 Prism 的 x-prism-response 扩展字段

契约：[粘贴 YAML]
```

---

### 使用 AI IDE 插件的推荐配置

#### Cursor IDE（最推荐）

1. 打开项目根目录的 `.cursorrules` 文件
2. Cursor 会自动加载，无需额外配置
3. 在编辑器中按 `Cmd+K`（Mac）/ `Ctrl+K`（Win）唤醒 AI 补全时，会自动遵循项目规范

#### GitHub Copilot

在项目根目录创建 `.github/copilot-instructions.md`：

```markdown
# Copilot Instructions

本项目是 SDD 规范驱动开发项目。

关键规则：
1. 所有接口必须先定义在 OpenAPI YAML 契约中
2. 响应体使用 Result<T> 包装
3. 异常统一抛出 BizException
4. 使用 MyBatis Plus，不写 SQL XML
5. 参考现有代码风格

更多规范见 .ai-context/project-rules.md
```

---

### 为什么 SDD + AI 比直接用 AI 更好？

| 维度 | 直接用 AI | SDD + AI |
|------|----------|----------|
| **上下文质量** | 需要每次描述项目规范 | 契约文件即规范，AI 自然理解 |
| **生成稳定性** | 容易跑偏，每次风格不一致 | 契约束定接口签名，100% 对齐 |
| **可验证性** | 靠人工 Review，易遗漏 | Spectral 校验 + 契约测试自动验证 |
| **可追溯性** | 不知道为什么这样生成 | Git 记录契约变更历史 |
| **团队协作** | 每个人问 AI 得到不同答案 | 契约是唯一真实来源，团队共识 |

---

## 🗺️ 设计决策记录（ADR）

> Architecture Decision Record —— 记录关键设计选择和权衡，避免将来重复踩坑。

---

### ADR-001：契约文件的存放位置

**决策时间**：项目初始化阶段

**背景**：项目根目录存在 `docs/specs/` 目录，同时各业务服务内部也有
`src/main/resources/specs/` 目录。二者职责需要明确区分。

**问题**：契约文件（OpenAPI YAML）应该集中管理还是随服务分散管理？

**四种可选方案及权衡**：

| 方案 | 做法 | 优点 | 缺点 |
|------|------|------|------|
| **A：纯分散**（当前采用） | 契约放各自服务的 `src/main/resources/specs/` 内 | 高内聚、服务独立发布、openapi-generator 直接引用本地路径 | 跨服务查阅契约需要跳目录 |
| **B：聚合只读** | `docs/specs/` 通过符号链接汇聚各服务契约 | 统一入口查阅，不破坏现有结构 | 符号链接在 Windows 和部分 CI 环境不可靠 |
| **C：全局共享契约** | `docs/specs/` 存放跨服务公用 Schema（如分页结构、通用响应体） | 公共结构不重复定义，通过 `$ref` 引用 | 需要处理跨服务 `$ref` 的路径解析问题 |
| **D：纯集中** | 所有契约移到 `docs/specs/`，服务内不放 specs | 一处查全部契约 | 服务与契约解耦，openapi-generator 需要配置远程路径，服务独立发布时耦合变高 |

**当前决策**：采用 **方案 A（分散）为主，方案 C（全局共享）为辅** 的混合策略：

```
docs/specs/
└── common-schemas.yaml          # 跨服务公用 Schema（分页、通用响应体等）

services/sdd-user-service/
└── src/main/resources/specs/
    └── user-service-api.yaml    # 服务自身契约，通过 $ref 引用公共 Schema
```

**理由**：
- 业务契约贴近服务，符合微服务高内聚原则，服务可以独立打包和发布
- 公共 Schema（如 `PageData`、`ErrorResponse`）只定义一次，通过 `$ref` 复用，避免各服务重复维护
- 不引入符号链接，CI/CD 跨平台无障碍

**后续行动**：
- [ ] 在 `docs/specs/common-schemas.yaml` 中提取公共 Schema
- [ ] 各服务契约通过 `$ref: '../../../../docs/specs/common-schemas.yaml#/...'` 引用公共定义

---

### ADR-002：网关鉴权 vs 服务内鉴权

**决策**：鉴权在**网关层统一处理**，下游服务信任网关透传的 `X-User-Id` Header，不再重复验 JWT。

**理由**：避免每个服务都引入 JWT 依赖和鉴权逻辑，减少重复代码；网关是唯一外部入口，安全边界清晰。

**注意**：服务间内部调用（如 Feign）绕过网关时，需要额外的内部调用凭证机制（待实现）。

---

### ADR-003：逻辑删除统一用 `deleted` 字段

**决策**：所有业务表使用 `deleted TINYINT DEFAULT 0` 字段做软删除，不做物理删除。

**理由**：数据可审计、可恢复；MyBatis Plus 的 `@TableLogic` 注解自动处理查询过滤，业务代码无感知。

**约定**：`deleted = 0` 正常，`deleted = 1` 已删除。MyBatis Plus 全局配置统一，不在各 Entity 重复声明逻辑。
