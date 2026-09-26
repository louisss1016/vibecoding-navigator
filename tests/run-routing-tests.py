#!/usr/bin/env python3
# run-routing-tests.py — 路由测试执行器
#
# 用法：在 skill 根目录或任意目录运行
#   python tests/run-routing-tests.py
#
# 它让 tests/routing-cases.json 从"数据"变成"测试"。四类检查：
#   1. schema：每条用例 id 唯一且非空、prompt 非空、expected 为非空字符串列表
#   2. 路由真实存在：expected 里每个条目都能在 skill 里定位到真实文件
#      （specialist 的 SKILL.md / pack 内 router / 前期流程文件）
#   3. 防路由漂移：每个条目必须同时出现在 docs/stack-routing.md（唯一事实源）
#      和主 SKILL.md（摘要）里——改了专家忘了改表，在这里失败
#   4. specialist 覆盖：specialists/ 下每个专家至少要有一条用例，
#      新增专家没配用例 = 不可路由，FAIL
#
# 依赖：仅标准库。退出码：0 = 全过；1 = 有 FAIL。

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CASES_FILE = ROOT / "tests" / "routing-cases.json"
STACK_ROUTING = ROOT / "docs" / "stack-routing.md"
MAIN_SKILL = ROOT / "SKILL.md"
SPECIALISTS_DIR = ROOT / "specialists"

failures = []


def fail(case_id, msg):
    failures.append(f"[{case_id}] {msg}")
    print(f"  [FAIL] {case_id}: {msg}")


def ok(case_id, msg):
    print(f"  [PASS] {case_id}: {msg}")


def resolve_entry(entry):
    """把 expected 条目解析成 skill 里的真实文件（相对路径）；解析不到返回 None。"""
    candidates = []
    if "/" in entry:
        pack, sub = entry.split("/", 1)
        candidates += [
            f"specialists/{pack}/skills/{sub}/SKILL.md",
            f"specialists/{pack}/{sub}/SKILL.md",
            f"specialists/{pack}/skills/{sub}.md",
        ]
    else:
        candidates += [
            f"specialists/{entry}/SKILL.md",
            # ts-react-electron 是 pack，没有根 SKILL.md，入口是 pack 内 router
            f"specialists/{entry}/skills/fullstack-desktop/SKILL.md",
            f"references/00-preflight/{entry}.md",
            f"references/01-in-flight/{entry}.md",
            f"references/02-postflight/{entry}.md",
            f"docs/{entry}.md",
        ]
    for rel in candidates:
        if (ROOT / rel).is_file():
            return rel
    return None


def table_tokens(entry):
    """在路由表里检索这条目时可接受的 token：完整名 / 第一段 / 最后一段。"""
    parts = [p for p in entry.split("/") if p]
    tokens = {entry, parts[0]}
    if len(parts) > 1:
        tokens.add(parts[-1])
    return tokens


def main():
    if not CASES_FILE.is_file():
        print(f"FATAL: 找不到 {CASES_FILE}")
        return 1
    try:
        cases = json.loads(CASES_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"FATAL: routing-cases.json 不是合法 JSON: {e}")
        return 1
    if not isinstance(cases, list) or not cases:
        print("FATAL: routing-cases.json 顶层必须是非空数组")
        return 1

    stack_routing_text = STACK_ROUTING.read_text(encoding="utf-8") if STACK_ROUTING.is_file() else ""
    main_skill_text = MAIN_SKILL.read_text(encoding="utf-8") if MAIN_SKILL.is_file() else ""
    if not stack_routing_text:
        print("FATAL: 找不到 docs/stack-routing.md——路由唯一事实源缺失")
        return 1
    if not main_skill_text:
        print("FATAL: 找不到主 SKILL.md")
        return 1

    seen_ids = set()
    print(f"路由测试：{len(cases)} 条用例\n")

    for c in cases:
        cid = c.get("id", "<无id>")
        # ---- 1. schema ----
        if not isinstance(c.get("id"), str) or not c["id"]:
            fail(cid, "缺少 id 或 id 不是字符串")
            continue
        if cid in seen_ids:
            fail(cid, f"id 重复（{cid} 出现多次）")
            continue
        seen_ids.add(cid)
        prompt = c.get("prompt")
        if not isinstance(prompt, str) or not prompt.strip():
            fail(cid, "prompt 缺失或为空")
            continue
        expected = c.get("expected")
        if not isinstance(expected, list) or not expected or not all(
            isinstance(e, str) and e.strip() for e in expected
        ):
            fail(cid, "expected 必须是非空字符串列表")
            continue

        # ---- 2. 路由真实存在 ----
        resolved, missing = [], []
        for e in expected:
            r = resolve_entry(e)
            (resolved if r else missing).append((e, r))
        if missing:
            for e, _ in missing:
                fail(cid, f"expected 路由 '{e}' 在 skill 里定位不到真实文件")
            continue

        # ---- 3. 防路由漂移 ----
        drift = []
        for e, _ in resolved:
            toks = table_tokens(e)
            if not any(t in stack_routing_text for t in toks):
                drift.append(f"'{e}' 不在 docs/stack-routing.md")
            elif not any(t in main_skill_text for t in toks):
                drift.append(f"'{e}' 不在主 SKILL.md 摘要路由表")
        if drift:
            for d in drift:
                fail(cid, f"路由漂移：{d}（改专家/改表后两边必须同步）")
            continue

        ok(cid, " -> ".join(r for _, r in resolved))

    # ---- 4. specialist 覆盖检查 ----
    print()
    covered = set()
    for c in cases:
        for e in c.get("expected", []):
            covered.add(e.split("/")[0])
    if SPECIALISTS_DIR.is_dir():
        for d in sorted(SPECIALISTS_DIR.iterdir()):
            if not d.is_dir():
                continue
            if d.name in covered:
                print(f"  [PASS] specialist 覆盖：{d.name}")
            else:
                fail(d.name, f"specialists/{d.name}/ 存在，但没有任何路由用例覆盖它——新专家不可路由")

    print("\n================ 汇总 ================")
    print(f"用例 {len(cases)} 条 | FAIL {len(failures)} 处")
    if failures:
        print("路由测试未过：")
        for f in failures:
            print(f"  - {f}")
        return 1
    print("路由测试全部通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
