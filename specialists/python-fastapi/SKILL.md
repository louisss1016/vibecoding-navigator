---
name: python-fastapi
description: Python + FastAPI + SQLite + pytest 栈的技术专家。当项目用 Python 写后端、用 FastAPI 做 API、用 SQLite 做数据存储、用 pytest 做测试时使用。
contract:
  owns: [FastAPI 路由与依赖注入, Pydantic 模型与校验, SQLAlchemy/sqlite3 访问层, pytest 测试组织, uvicorn 启动配置]
  input: [切片定义, 接口契约（路由签名/响应模型）, 禁区清单, 验证命令]
  output: [改动文件清单, pytest 原始输出, 自审结论, 冲突标记]
  forbidden: [流程决策, 需求澄清, 前端 UI 实现, 打包部署细节（找 deploy-ops）]
---

# Python + FastAPI 技术规范

## 项目结构（推荐）

```
项目根/
├── app/
│   ├── __init__.py
│   ├── main.py            # FastAPI 入口，create_app()
│   ├── config.py          # 环境变量读取（pydantic-settings）
│   ├── api/               # 路由层，一个文件一组相关端点
│   │   └── todos.py
│   ├── models.py          # SQLAlchemy 模型
│   ├── schemas.py         # Pydantic 请求/响应模型
│   ├── db.py              # engine / SessionLocal / get_db 依赖
│   └── core/
│       ├── errors.py      # 统一错误信封
│       └── deps.py        # 共享依赖
├── tests/
│   ├── conftest.py        # fixture：测试库、client、数据工厂
│   └── test_todos.py
├── requirements.txt       # 固定版本，提交 lock（pip freeze > requirements.txt）
└── .env.example           # 环境变量模板，真实 .env 不进 git
```

## FastAPI 约定

### 路由

- 路由函数只做：解析请求 → 调 service/CRUD → 返回响应模型。业务逻辑不放路由里。
- 响应一律声明 `response_model`，不让 FastAPI 猜。
- 路径用名词复数（`/todos`），动作用 HTTP 方法表达（POST 建、PATCH 改、DELETE 删）。

### 错误信封（统一格式）

```python
# 成功：直接返回资源或 { "data": ... }
# 失败：HTTPException + 统一 detail 结构
{
  "ok": false,
  "error": { "code": "TODO_NOT_FOUND", "message": "人话错误信息" }
}
```

- 全局异常处理器把未捕获异常也转成这个信封，**不许把堆栈返回给客户端**。
- `message` 写人话（"这条记录不存在"），不写技术细节（"no such table: todos"）。

### 依赖注入

- 数据库 session 用 `Depends(get_db)`，路由函数不自己开 session。
- 配置从 `app/config.py` 读，路由里不直接 `os.environ`。

## 数据库（SQLAlchemy）

**选型边界**：SQLite 只适合演示/本地单机工具；真实项目（多用户、要上线）直接 PostgreSQL，换库不是改连接串——并发模型、类型严格度、备份全不同。表怎么设计（ER、命名、索引、迁移策略）见 `references/00-preflight/data-modeling.md`。

- SQLite 多线程场景：`db.py` 里创建 engine 时加 `connect_args={"check_same_thread": False}`。
- session 用 `yield` 的依赖，请求结束自动 close；长任务不用请求级 session。
- schema 变更走迁移工具（alembic），**不许手改已上线库的表结构**；SQLite 用 alembic 同样支持。
- 查询用 ORM，复杂统计可以 text() 裸 SQL，但**参数必须绑定**，禁止 f-string 拼 SQL。

## 测试（pytest）

- `conftest.py` 提供：临时文件库（`tmp_path`）、`TestClient(app)`、造数 fixture。
- API 测试用 `TestClient`，断言响应体结构 + 状态码，不只断言 200。
- 每个 bug 修复后，把复现步骤固化成一条测试（golden case 的自动化部分）。
- 异步路由用 `httpx.AsyncClient`，别混用 requests 阻塞事件循环。

## 命令

- 安装：`pip install -r requirements.txt`
- 开发：`uvicorn app.main:app --reload`
- 测试：`pytest -v`
- 单文件：`pytest tests/test_todos.py -v`

## 常见坑

1. **同步/异步混用**：路由声明了 `async def` 却在里面跑阻塞的 sqlite3 同步调用，拖垮整个事件循环。要么全异步栈，要么路由声明 `def`（FastAPI 会自动丢线程池）。
2. **CORS**：浏览器前端调 API 报 CORS，是在 `main.py` 加 CORSMiddleware 时 origins 写了 `*` 又带 credentials——生产环境 origins 要显式列。
3. **连接池**：SQLite 单文件别配大连接池；换 PostgreSQL 时再调 pool_size。
4. **Pydantic v1/v2 混用**：`@validator`（v1）和 `@field_validator`（v2）别在一个项目里混。
5. **启动时建表**：`Base.metadata.create_all()` 只适合第一次开发；上线后用 alembic。
6. **uvicorn 生产模式**：发布时别用 `--reload`，worker 数和日志级别显式配置。

## 什么时候不用这个专家

- 需要前端重交互（去 web-react）
- 需要桌面壳（去 ts-react-electron）
- 高性能计算 / CPU 密集（Python 不是最优解，考虑局部换语言）
