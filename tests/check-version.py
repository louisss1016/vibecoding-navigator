#!/usr/bin/env python3
"""版本一致性检查：VERSION / SKILL.md frontmatter / CHANGELOG.md 三处必须一致。

这个 skill 的 CHANGELOG 纪律要求三处版本号一致，此前靠人工核对——
本脚本把这条纪律变成可执行门禁，进 CI（.github/workflows/routing-tests.yml）。

检查项：
  1. VERSION 文件内容（单行，x.y.z）
  2. SKILL.md frontmatter 的 version: 字段
  3. CHANGELOG.md 第一个版本条目 ## [x.y.z]
三者完全相等才算通过；同时校验 x.y.z 格式。

仅标准库；退出码 0 = 一致，1 = 不一致或文件缺失/格式错误。
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SEMVER = re.compile(r"^\d+\.\d+\.\d+$")


def read(rel):
    p = ROOT / rel
    if not p.is_file():
        print(f"[FAIL] 缺少文件: {rel}")
        sys.exit(1)
    return p.read_text(encoding="utf-8")


def main():
    problems = []

    # 1. VERSION 文件
    version = read("VERSION").strip()
    if not SEMVER.match(version):
        problems.append(f"VERSION 内容不是 x.y.z 格式: {version!r}")

    # 2. SKILL.md frontmatter
    skill = read("SKILL.md")
    m = re.match(r"\A---\s*\n(.*?)\n---", skill, re.DOTALL)
    if not m:
        problems.append("SKILL.md 缺少 frontmatter 块（--- ... ---）")
    else:
        fm = re.search(r"^version:\s*(\S+)\s*$", m.group(1), re.MULTILINE)
        if not fm:
            problems.append("SKILL.md frontmatter 缺少 version: 字段")
        elif fm.group(1) != version:
            problems.append(
                f"SKILL.md frontmatter version={fm.group(1)} 与 VERSION={version} 不一致")
        # name 字段顺带校验，防复制粘贴事故
        nm = re.search(r"^name:\s*(\S+)\s*$", m.group(1), re.MULTILINE)
        if not nm or nm.group(1) != "vibecoding-navigator":
            problems.append("SKILL.md frontmatter name 不是 vibecoding-navigator")

    # 3. CHANGELOG.md 第一个版本条目
    clog = read("CHANGELOG.md")
    cm = re.search(r"^## \[(\d+\.\d+\.\d+)\]", clog, re.MULTILINE)
    if not cm:
        problems.append("CHANGELOG.md 找不到版本条目（## [x.y.z]）")
    elif cm.group(1) != version:
        problems.append(
            f"CHANGELOG 最新条目 [{cm.group(1)}] 与 VERSION={version} 不一致")

    if problems:
        print("版本一致性检查未通过：")
        for p in problems:
            print(f"  - {p}")
        print("\n三处必须同步修改：VERSION / SKILL.md frontmatter / CHANGELOG.md 首条")
        sys.exit(1)

    print(f"[PASS] 版本三处一致: {version}")
    print("  VERSION / SKILL.md frontmatter / CHANGELOG.md")
    sys.exit(0)


if __name__ == "__main__":
    main()
