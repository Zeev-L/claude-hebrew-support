# Claude RTL — Hebrew / Arabic support for Claude

Automatic right-to-left (RTL) detection and alignment for Hebrew and Arabic text in
**Claude Desktop (macOS)** and **Claude on the web (claude.ai)** — while keeping code
blocks, LaTeX/KaTeX math, and English text left-to-right. Works live, including while
Claude streams a response.

> תמיכה אוטומטית בעברית/ערבית ב-Claude — יישור לימין בזמן אמת, תוך שמירה על קוד ונוסחאות משמאל לימין.

## One logic, two delivery pipes

The RTL detection logic is a single file — [`shared/rtl-payload.js`](shared/rtl-payload.js) —
used by both targets:

| Target | How the payload is delivered |
|--------|------------------------------|
| **Desktop (macOS)** | `desktop-mac/patch.sh` injects it into a **copy** of `Claude.app`'s `app.asar`, disables the Electron ASAR-integrity fuse, and ad-hoc re-signs. The original `/Applications/Claude.app` is never touched. |
| **Web (claude.ai)** | `web/build-web.sh` wraps the same payload in a Tampermonkey/Violentmonkey userscript. |

Edit the shared payload once; rebuild the web userscript with `web/build-web.sh`.

## How the RTL detection works

1. **Script detection** by Unicode range (Hebrew `U+0590–05FF`, Arabic blocks).
2. **First-strong** direction: the first strong character (Hebrew vs. Latin) sets the
   paragraph direction; leading URLs, file paths and inline code are stripped first.
3. **Code blocks** (`pre`, `code`, `.code-block__code`) are forced LTR even inside Hebrew.
4. **Math** (KaTeX / MathJax) is isolated LTR via `unicode-bidi: isolate`.
5. **Streaming**: a debounced `MutationObserver` re-runs detection as the DOM updates.

## Desktop (macOS) — install

```bash
cd desktop-mac
./patch.sh --install      # builds ~/Applications/Claude-RTL.app (original untouched)
./patch.sh --status       # show patch status
./patch.sh --uninstall    # remove the patched copy
```

Requirements: Node.js (provides `npx`) and Xcode Command Line Tools (`codesign`).

**What it changes / safety:** operates only on a copy at `~/Applications/Claude-RTL.app`.
Because the app.asar is modified, the Electron `EnableEmbeddedAsarIntegrityValidation`
fuse is disabled and the copy is re-signed **ad-hoc** — so the copy is no longer signed
by Anthropic. Your original `/Applications/Claude.app` keeps its Anthropic signature and
notarization. Rollback = `--uninstall` or delete the copy.

> ⚠️ After every Claude Desktop update, re-run `./patch.sh --install` to re-patch a fresh copy.

## Web (claude.ai) — install

1. Install a userscript manager: [Tampermonkey](https://www.tampermonkey.net/) or Violentmonkey.
2. Build / open the userscript:
   ```bash
   cd web && ./build-web.sh
   ```
   Then open `web/claude-rtl.user.js` and your userscript manager will offer to install it.
3. Reload claude.ai.

> Web DOM selectors can drift; if input-box direction misbehaves, adjust `WRITING_SEL`
> in `shared/rtl-payload.js` and rebuild.

## Credits & license

MIT. RTL detection logic by [@shraga100](https://github.com/shraga100/claude-desktop-rtl-patch)
(Windows original); macOS patcher by [@soguy](https://github.com/soguy/claude-desktop-rtl-mac).
This repository packages both into one cross-surface framework. See [LICENSE](LICENSE).
