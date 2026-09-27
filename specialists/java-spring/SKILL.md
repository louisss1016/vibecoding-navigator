---
name: java-spring
description: Java + Spring Boot + Maven + JUnit 5 栈的技术专家。当项目用 Java 写后端、用 Spring Boot 做 API、用 MySQL/PostgreSQL 做数据存储、用 JUnit 5 做测试时使用。
contract:
  owns: [Spring Boot 分层与依赖注入, Controller/Service/Repository 边界, Bean Validation 校验, JPA/MyBatis 访问层, 事务管理, JUnit 5 + Mockito 测试组织]
  input: [切片定义, 接口契约（接口签名/请求响应模型）, 禁区清单, 验证命令]
  output: [改动文件清单, Maven 测试原始输出, 自审结论, 冲突标记]
  forbidden: [流程决策, 需求澄清, 前端 UI 实现, 打包部署细节（找 deploy-ops）]
---

# Java + Spring Boot 技术规范

## 项目结构（推荐）

```
项目根/
├── pom.xml                  # Maven 构建，依赖版本统一在 dependencyManagement
├── src/
│   ├── main/
│   │   ├── java/com/example/app/
│   │   │   ├── Application.java        # @SpringBootApplication 入口
│   │   │   ├── config/                 # 配置类（安全、跨域、序列化）
│   │   │   ├── controller/             # 路由层，一个文件一组相关端点
│   │   │   │   └── TodoController.java
│   │   │   ├── service/                # 业务层，接口 + impl
│   │   │   │   └── TodoService.java
│   │   │   ├── repository/             # 数据访问层
│   │   │   │   └── TodoRepository.java
│   │   │   ├── entity/                 # 数据库实体（JPA）或 DO
│   │   │   ├── dto/                    # 请求/响应模型，不拿 entity 直接出参
│   │   │   └── common/
│   │   │       ├── ApiResponse.java    # 统一响应信封
│   │   │       └── GlobalExceptionHandler.java  # @RestControllerAdvice
│   │   └── resources/
│   │       ├── application.yml         # 默认配置
│   │       ├── application-prod.yml    # 生产覆盖
│   │       └── db/migration/           # Flyway 迁移脚本
│   └── test/java/...                   # 与 main 同结构
└── .env.example             # 敏感配置模板，真实密钥不进 git
```

- **分层铁律**：Controller 只做参数解析 + 调 service；业务逻辑进 service；SQL/JPA 细节进 repository。Controller 里不许出现 repository。

## Spring Boot 约定

### Controller

- 构造器注入依赖（`private final` + 构造函数），不用字段 `@Autowired`——字段注入隐藏依赖、测试要起容器。
- 路径用名词复数（`/api/todos`），动作用 HTTP 方法表达。
- 出参一律 DTO，**不许把 JPA entity 直接返回**——entity 字段变更直接变成 API 变更，懒加载代理还会把 Jackson 卡死。
- 请求体加 `@Valid` + DTO 上的 Bean Validation 注解（`@NotBlank` / `@Size`），校验失败由全局异常处理转 400。

### 错误信封（统一格式）

```java
// 成功：{ "ok": true, "data": ... }
// 失败：全局异常处理器统一转这个信封
{
  "ok": false,
  "error": { "code": "TODO_NOT_FOUND", "message": "这条记录不存在" }
}
```

- `@RestControllerAdvice` 兜底所有异常，**不许把堆栈返回给客户端**；堆栈只进日志。
- `message` 写人话，不写技术细节（`org.hibernate.StaleObjectStateException` 这类禁止出参）。

### 事务

- `@Transactional` 标在 service Impl 的 public 方法上，别标在 private 方法上（Spring AOP 代理看不见，静默失效）。
- 事务里不做 HTTP 调用、不发 MQ、不写文件——外部调用超时会把数据库连接和行锁一起拖死。
- 默认只对 RuntimeException 回滚；checked exception 要显式 `rollbackFor`。
- 事务范围越小越好：查询在事务外做，别为了一次读锁住整行。

## 数据库（JPA / MyBatis）

表结构设计（ER 梳理、命名规范、索引策略、迁移纪律）见 `references/00-preflight/data-modeling.md`——建表前先过那五问，别代码写着写着随手加字段。

- 连接池用 HikariCP（Spring Boot 默认），`maximum-pool-size` 按数据库实际承载配，别抄网上的 50。
- schema 变更走 Flyway/Liquibase 迁移脚本，**不许手改已上线库的表结构**；`ddl-auto: update` 只允许本地开发，生产必须是 `validate` 或 `none`。
- JPA 的 N+1：默认 LAZY 加载在循环里逐条查。用 `JOIN FETCH` 或 `@EntityGraph` 一次捞，或按 id 批量 `findAllById` 再内存组装。
- MyBatis 场景：`#{}` 是参数绑定，`${}` 是字符串拼接——表名/排序方向等非占位场景必须白名单校验，其余一律 `#{}`。
- 实体关系别滥用级联（`CascadeType.ALL` + `orphanRemoval` 一把删光联级数据）；级联行为要在注释里写清。

## 测试（JUnit 5 + Mockito）

- 单元测试：Mockito mock 掉 repository，测 service 业务规则，不起 Spring 容器，毫秒级。
- Web 层：`@WebMvcTest` + `MockMvc` 测 Controller，验证状态码 + 响应体结构，不只断言 200。
- 持久层：`@DataJpaTest` 用 H2 或 Testcontainers 起真库，验证自定义查询和映射。
- 集成冒烟：`@SpringBootTest(webEnvironment = RANDOM_PORT)` 最少一条，验证上下文能起来、核心接口能通。
- 每个 bug 修复后，把复现步骤固化成一条测试（golden case 的自动化部分）。

## 命令

- 构建 + 测试：`mvn clean package`（或 `./mvnw clean package`）
- 单跑测试：`mvn test -Dtest=TodoServiceTest`
- 单跑一个方法：`mvn test -Dtest=TodoServiceTest#shouldRejectBlankTitle`
- 跳过测试的构建（本地验证编译：`mvn clean package -DskipTests`——**提交前不许用**）

## 常见坑

1. **`@Transactional` 自调用失效**：同一个类里 `methodA()` 调 `this.methodB()`，B 上的事务注解静默失效——Spring AOP 代理拦截的是外部调用。要么拆成两个 bean，要么注入自身代理（`self` 注入或 `AopContext.currentProxy()`）。
2. **事务里做远程调用**：HTTP/RPC 超时 30 秒 = 数据库连接被占 30 秒 = 连接池打满、后续请求全挂。远程调用挪到事务外，或改用本地消息表最终一致。
3. **checked exception 不回滚**：`@Transactional` 默认只对 RuntimeException 回滚。抛了 `Exception` 子类（如 `IOException`）时数据已写一半但事务不回滚——要么 rollbackFor 显式声明，要么统一转运行时异常。
4. **entity 直接出参**：LAZY 关联在序列化时触发额外查询（甚至 Jackson 无限递归）。出参走 DTO，用 MapStruct 或手写转换；关联查询显式 `JOIN FETCH`。
5. **字段注入**：`@Autowired` 写在字段上，依赖藏起来、单测要起容器。构造器注入让依赖显式，final 字段不可变。
6. **循环依赖**：A 构造器要 B、B 构造器要 A，启动直接失败。要么用 setter 注入打破环（知道自己在打补丁），要么重新划边界——多半是分层没分清。
7. **循环 JSON**：双向关联（`@OneToMany` / `@ManyToOne`）互相引用，序列化 StackOverflow。DTO 单向引用，或 `@JsonIgnore` + `@JsonManagedReference`。
8. **配置进 git**：`application.yml` 里写死数据库密码/密钥。敏感配置走环境变量，仓库只留 `application.yml.example` 模板。

## 什么时候不用这个专家

- 需要前端重交互（去 web-react）
- 需要桌面壳（去 ts-react-electron）
- 部署 / CI / 监控 / 回滚（去 deploy-ops）
- 项目其实是 Python 栈（去 python-fastapi）
