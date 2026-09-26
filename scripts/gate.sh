#!/usr/bin/env bash
# gate.sh — 发布门禁：自动检查层
#
# 用法：在项目根目录运行  bash scripts/gate.sh
# 覆盖：git 干净度 / debug 残留 / 密钥泄露 / 依赖漏洞 / 构建 / 测试 / golden cases
# 输出：终端摘要 + docs/evidence/gate-<时间戳>.txt（如目录存在）
# 退出码：0 = 全过；1 = 有 FAIL；2 = 用法/环境错误
#
# 人眼级检查（主链路亲手走、六状态截图、迁移验证）不在本脚本范围，
# 见 references/02-postflight/release-gate.md。

set -uo pipefail

ROOT="$(pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
FAILS=()
WARNS=()
PASSES=()

pass() { PASSES+=("$1"); printf '  [PASS] %s\n' "$1"; }
fail() { FAILS+=("$1"); printf '  [FAIL] %s\n' "$1"; }
warn() { WARNS+=("$1"); printf '  [WARN] %s\n' "$1"; }
section() { printf '\n== %s ==\n' "$1"; }

report() {
  local out=""
  if [[ -d "$ROOT/docs/evidence" ]]; then
    out="$ROOT/docs/evidence/gate-$TS.txt"
    {
      printf 'gate report %s\n' "$TS"
      printf 'PASS: %s\n' "${PASSES[@]:-}"
      printf 'WARN: %s\n' "${WARNS[@]:-}"
      printf 'FAIL: %s\n' "${FAILS[@]:-}"
    } > "$out" 2>/dev/null || true
  fi
  printf '\n================ 汇总 ================\n'
  printf 'PASS %d | WARN %d | FAIL %d\n' "${#PASSES[@]}" "${#WARNS[@]}" "${#FAILS[@]}"
  if ((${#FAILS[@]})); then
    printf '门禁未过，不能发布。FAIL 项：\n'
    printf '  - %s\n' "${FAILS[@]}"
    [[ -n "$out" ]] && printf '报告：%s\n' "$out"
    exit 1
  fi
  printf '自动门禁通过。继续人眼级检查（release-gate.md）。\n'
  [[ -n "$out" ]] && printf '报告：%s\n' "$out"
  exit 0
}

printf 'gate.sh  %s  cwd=%s\n' "$TS" "$ROOT"

# ---------- 探测栈 ----------
if [[ -f package.json && ( -f requirements.txt || -f pyproject.toml ) ]]; then
  STACK="node+python"
elif [[ -f package.json ]]; then
  STACK="node"
elif [[ -f requirements.txt || -f pyproject.toml ]]; then
  STACK="python"
else
  STACK="unknown"
fi
printf '检测到技术栈：%s\n' "$STACK"

# ---------- 1. git 干净度 ----------
section "1. git 工作区"
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  if [[ -z "$(git status --porcelain)" ]]; then
    pass "git 工作区干净"
  else
    fail "git 有未提交改动（release-gate 要求发布时工作区干净）"
  fi
else
  warn "不是 git 仓库或没有 git——跳过（建议先 git init）"
fi

# ---------- 2. debug 残留 ----------
section "2. debug 残留"
RESIDUE=0
if [[ "$STACK" == *node* ]]; then
  HITS=$(grep -rnE '(^|[^.[:alnum:]])(console\.(log|debug)|debugger)' \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    src app components lib 2>/dev/null | grep -v node_modules | head -20 || true)
  [[ -n "$HITS" ]] && { RESIDUE=1; printf '%s\n' "$HITS"; }
fi
if [[ "$STACK" == *python* ]]; then
  HITS=$(grep -rnE '(^|[^.[:alnum:]])(print\(|breakpoint\(|pdb)' \
    --include='*.py' app tests 2>/dev/null | grep -v '/tests/' | head -20 || true)
  [[ -n "$HITS" ]] && { RESIDUE=1; printf '%s\n' "$HITS"; }
fi
if [[ $RESIDUE -eq 1 ]]; then fail "发现 debug 残留（见上）"; else pass "无 debug 残留"; fi

# ---------- 3. 密钥泄露 ----------
section "3. 密钥泄露"
SECRET_PAT='(api[_-]?key|secret|password|passwd|token|access[_-]?key)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_\-]{12,}'
HITS=$(grep -rniE "$SECRET_PAT" \
  --include='*.ts' --include='*.tsx' --include='*.js' --include='*.py' --include='*.json' --include='*.yml' --include='*.yaml' \
  src app components lib tests .github 2>/dev/null | grep -vE '(\.example|\.sample|test|spec|mock|fixture)' | head -20 || true)
[[ -n "$HITS" ]] && { fail "疑似硬编码密钥："; printf '%s\n' "$HITS"; } || pass "未发现硬编码密钥"
if [[ -f .env ]] && git rev-parse --git-dir >/dev/null 2>&1; then
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    fail ".env 被提交进了 git"
  else
    pass ".env 未被 git 跟踪"
  fi
fi

# ---------- 4. 依赖漏洞 ----------
section "4. 依赖漏洞"
if [[ "$STACK" == *node* ]] && command -v npm >/dev/null 2>&1; then
  if npm audit --audit-level=high >/tmp/gate-audit.txt 2>&1; then
    pass "npm audit 无 high 以上漏洞"
  else
    if grep -qE 'error|EAI_AGAIN|ENOTFOUND' /tmp/gate-audit.txt; then
      warn "npm audit 跑不动（网络？），人工确认后放行"
    else
      fail "npm audit 发现 high 以上漏洞（npm audit 查看详情）"
    fi
  fi
elif [[ "$STACK" == *python* ]]; then
  if command -v pip-audit >/dev/null 2>&1; then
    if pip-audit >/tmp/gate-audit.txt 2>&1; then pass "pip-audit 无已知漏洞"; else fail "pip-audit 发现漏洞（见 /tmp/gate-audit.txt）"; fi
  else
    warn "未安装 pip-audit，跳过依赖扫描（pip install pip-audit 后重跑）"
  fi
else
  warn "无法识别包管理器，跳过依赖扫描"
fi

# ---------- 5. 构建 ----------
section "5. 构建"
if [[ "$STACK" == *node* ]]; then
  if npm run build >/tmp/gate-build.txt 2>&1; then pass "npm run build 通过"; else fail "构建失败（tail /tmp/gate-build.txt）"; fi
elif [[ "$STACK" == *python* ]]; then
  if python -m compileall -q app >/tmp/gate-build.txt 2>&1; then pass "python 编译检查通过"; else fail "编译失败（tail /tmp/gate-build.txt）"; fi
else
  warn "无构建步骤可跑"
fi

# ---------- 6. 测试 ----------
section "6. 测试"
if [[ "$STACK" == *node* ]]; then
  if npm test >/tmp/gate-test.txt 2>&1; then pass "npm test 通过"; else fail "测试失败（tail /tmp/gate-test.txt）"; fi
elif [[ "$STACK" == *python* ]]; then
  if python -m pytest -q >/tmp/gate-test.txt 2>&1; then pass "pytest 通过"; else fail "测试失败（tail /tmp/gate-test.txt）"; fi
else
  warn "无测试命令可跑"
fi

# ---------- 7. golden cases ----------
section "7. golden cases"
if [[ -f tests/golden-cases.json ]]; then
  if command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1; then
    PY=$(command -v python3 || command -v python)
    if "$PY" - <<'PYEOF'
import json, subprocess, sys, shlex
data = json.load(open("tests/golden-cases.json"))
auto = [c for c in data.get("cases", []) if c.get("verify", {}).get("type") == "command"]
manual = [c for c in data.get("cases", []) if c.get("verify", {}).get("type") != "command"]
print(f"golden cases: {len(auto)} 条自动 / {len(manual)} 条手动")
bad = []
for c in auto:
    cmd = c["verify"].get("cmd", "")
    print(f"  [RUN ] {c['id']}: {cmd}")
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if r.returncode != 0:
        bad.append(c["id"])
        print(r.stdout[-2000:]); print(r.stderr[-2000:])
if bad:
    print("FAILED:", ", ".join(bad)); sys.exit(1)
print("自动 golden cases 全部通过")
sys.exit(0)
PYEOF
    then pass "自动 golden cases 全部通过"; else fail "有 golden case 失败（见上方输出）"; fi
  else
    warn "没有 python，无法执行 golden cases 运行器"
  fi
  # 注意：grep -c 无匹配时也会输出 0（退出码 1），直接捕获即可，不要再 || echo 0
  N=$(grep -c '"type"[[:space:]]*:[[:space:]]*"manual"' tests/golden-cases.json 2>/dev/null)
  if [[ -n "$N" && "$N" -gt 0 ]]; then
    warn "还有 $N 条 manual case 需人眼执行（release-gate 人眼级）"
  fi
else
  warn "没有 tests/golden-cases.json——从 references/02-postflight/golden-cases.json.tmpl 复制建立"
fi

report
