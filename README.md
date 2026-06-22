# Claude RTL — Hebrew / Arabic support for Claude

Automatic right-to-left (RTL) detection and alignment for Hebrew and Arabic text in
**Claude Desktop (macOS)** and **Claude on the web (claude.ai)** — while keeping code
blocks, LaTeX/KaTeX math, and English text left-to-right. Works live, including while
Claude streams a response.

> תמיכה אוטומטית בעברית/ערבית ב-Claude — יישור לימין בזמן אמת, תוך שמירה על קוד ונוסחאות משמאל לימין.

---

# 🚀 התקנה מהירה (Quick install)

הסבר פשוט, צעד-צעד. בחר את מה שצריך — דסקטופ, web, או שניהם.

## ⬇️ קודם: להוריד את הקבצים

**הדרך הקלה (מומלצת):**
1. בראש העמוד הזה ב-GitHub, לחץ על הכפתור הירוק **`<> Code`** ← **`Download ZIP`**.
2. פתח את קובץ ה-ZIP שהורד (לחיצה כפולה). תיווצר תיקייה בשם `claude-hebrew-support`.

**הדרך למתקדמים (Terminal):**
```bash
git clone https://github.com/Zeev-L/claude-hebrew-support
```

---

## 🖥️ התקנה — Claude Desktop (macOS)

**מה צריך מראש:** [Node.js](https://nodejs.org/) מותקן. (בדיקה: ב-Terminal הקלד `node -v` — אם מופיע מספר, אתה מוכן.)

1. פתח את אפליקציית **Terminal** (Cmd+רווח, הקלד "Terminal", Enter).
2. העתק והדבק את שתי השורות הבאות, אחת-אחת, ולחץ Enter. **החלף את הנתיב** לתיקייה שהורדת (אם הורדת ZIP, היא כנראה ב-`~/Downloads`):
   ```bash
   cd ~/Downloads/claude-hebrew-support/desktop-mac
   ./patch.sh --install
   ```
3. זהו! נוצרה אפליקציה חדשה בשם **Claude-RTL** (עם תווית RTL על האייקון). היא תיפתח אוטומטית.

**מעכשיו:** פתח תמיד את **Claude-RTL** (לא את Claude הרגיל) כדי לקבל עברית מסודרת. שתיהן יכולות לחיות זו לצד זו.

| פעולה | פקודה |
|---|---|
| הסרה | `./patch.sh --uninstall` |
| בדיקת מצב | `./patch.sh --status` |

> ⚠️ **אחרי כל עדכון של Claude Desktop** — הרץ שוב `./patch.sh --install` (העדכון "דורס" את הגרסה המתוקנת). העותק המקורי ב-`/Applications` אף פעם לא נוגעים בו.

---

## 🌐 התקנה — claude.ai (בדפדפן Chrome)

1. **התקן את התוסף Tampermonkey** (פעם אחת): [לחץ כאן](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) ← **Add to Chrome** ← **Add extension**.

2. **התקן את הסקריפט שלנו:** פתח בדפדפן את הקישור הזה —
   [התקנת הסקריפט (claude-rtl.user.js)](https://github.com/Zeev-L/claude-hebrew-support/raw/main/web/claude-rtl.user.js)
   — Tampermonkey יציג עמוד התקנה, לחץ על הכפתור הירוק **Install**.

3. **⚠️ הדלק userscripts ב-Chrome (קריטי — קל לפספס!):** Chrome חוסם userscripts כברירת מחדל.
   - בשורת הכתובת הקלד `chrome://extensions` ולחץ Enter.
   - בפינה הימנית-עליונה **הדלק את "Developer mode"**.
   - (ב-Chrome חדש) על כרטיס Tampermonkey לחץ **Details** ← הדלק **"Allow User Scripts"**.

4. **רענן את [claude.ai](https://claude.ai)** (Cmd+R) — וזהו, עברית תתיישר לימין.

> בלי שלב 3 הסקריפט יופיע כ"מותקן ופעיל" אבל **לא ירוץ**. זו הטעות הכי נפוצה.

---

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
2. Install the script: open
   [`web/claude-rtl.user.js`](web/claude-rtl.user.js) (or its raw URL) — the userscript
   manager will offer to install it. To rebuild from the shared payload: `cd web && ./build-web.sh`.
3. **Enable user scripts in Chrome (required, easy to miss):** Chrome (Manifest V3) silently
   blocks userscripts until you turn this on. Go to `chrome://extensions`, enable
   **Developer mode** (top-right toggle); on newer Chrome also open Tampermonkey's **Details**
   and enable **Allow User Scripts**. Without this the script is "installed & enabled" but never runs.
4. Reload claude.ai.

> **Why `@grant GM_addStyle` and not `@grant none`:** claude.ai's CSP blocks page-context
> injection (`@grant none`), so the script must run in the userscript manager's isolated
> sandbox. Any non-`none` grant flips it into sandbox mode (full DOM access, CSP-exempt).
>
> Web DOM selectors can drift; if input-box direction misbehaves, adjust `WRITING_SEL`
> in `shared/rtl-payload.js` and rebuild. (Verified working: paragraphs and the
> `[data-testid="chat-input"]` composer both go RTL on claude.ai.)

## Credits & license

MIT. RTL detection logic by [@shraga100](https://github.com/shraga100/claude-desktop-rtl-patch)
(Windows original); macOS patcher by [@soguy](https://github.com/soguy/claude-desktop-rtl-mac).
This repository packages both into one cross-surface framework. See [LICENSE](LICENSE).
