# AGENTS.md — minchiaHuang (GitHub profile repo)
<!--
  Goes in the REPO ROOT and IS COMMITTED. This is the cross-tool standard file:
  Codex, Cursor, Copilot and Claude Code all read it, so project rules travel
  with the repo — to another machine, another account, another AI.

  Target length: 30-50 lines to start, 150 max. Every token spent on advice the
  model already knows ("write readable code") dilutes the instructions that
  actually differ from its defaults.

  Highest-ROI sections are COMMANDS and BOUNDARIES. Fill those on day one and
  leave the rest as placeholders; a file with only those two is already useful.
-->

One line: the README shown on github.com/minchiaHuang — a single line of links for
recruiters and visitors.

## Stack
- <language / framework + pinned version>
- Package manager: <npm | pnpm | uv | swift>

## Commands
<!-- Exact commands with exact flags. No paraphrasing — these get run verbatim. -->
```
verify   bash bin/verify.sh          # no setup, dev or build — the repo is Markdown only
preview  gh repo view minchiaHuang/minchiaHuang --web
```

## Boundaries
<!-- Three tiers. "Never" must name real files/branches/tables, not principles. -->
**Always** — run `bash bin/verify.sh` before saying the work is done; paste the output.
Keep `README.md` a plain native link index: no badges, stats cards, images or HTML.
**Ask first** — any change to the text or links in `README.md` (it is the public
profile); adding anything under `.github/` (workflows, generated stats).
**Never** — make the repository private or rename it (the profile README stops
rendering); push straight to `main`; commit `*.local.md` or `.env`; add personal
details that are not already public in `README.md`.

## Gotchas
<!-- Grown one line at a time, each time an AI gets something wrong HERE.
     Format: what was wrong -> what is correct. Never "be careful with X".
     Delete these examples once you have real ones. -->
- <config lives in X, not the obvious Y -> Y is silently ignored at runtime>
- <file Z is gitignored -> a clean clone failing to build is expected, not a bug>

## Reading order
1. This file.
2. `docs/STATUS.md` — where the work actually stands. **Outranks any older note.**
3. `docs/decisions/` — only when you need to know *why* something is the way it is.
