# Bundled upstream skills

The directories under `vendor/skills/` are exact upstream skill-directory copies at the commits recorded in `manifest/skills.json`.

They are installed locally by `scripts/install.sh`; the installer does not replace these bundled copies with a GitHub-only reference. `scripts/vendor.sh --latest` refreshes the MIT-licensed copies and records the fetched commit in the manifest.

The NinjaSln Electron skill and Anthropic `frontend-design` skill are intentionally not present here. Their current repositories do not provide permissive redistribution terms for the requested directories, so the installer fetches those two at install time instead. See `THIRD-PARTY-NOTICES.md` and `docs/distribution.md`.
