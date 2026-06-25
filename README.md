# Claude RTL — Hebrew / Arabic support for Claude

Automatic right-to-left (RTL) detection and alignment for Hebrew and Arabic text in
**Claude Desktop (macOS)** and **Claude on the web (claude.ai)** — while keeping code
blocks, LaTeX/KaTeX math, and English text left-to-right. Works live, including while
Claude streams a response.

> 🇮🇱 **גרסה עברית מלאה — בתחתית העמוד** ⬇️ &nbsp; ([קפיצה לעברית](#hebrew))
> &nbsp;|&nbsp; Hebrew version available at the bottom of this page.

---

# 🚀 Quick install

Pick what you need — Desktop, web, or both.

> 🤖 **With Claude Code:** an agent can clone the repo and run the scripts for
> you (`desktop-mac/patch.sh --install`, `web/build-web.sh`) and explain each
> step. The rest is hands-on by design and **only you** can do it: installing
> the Tampermonkey extension, enabling Chrome **Developer mode**, and approving
> the macOS re-sign / Gatekeeper prompt. Those are GUI / OS trust actions that
> can't be scripted.

## ⬇️ First: download the files

**Easy way (recommended):** at the top of this GitHub page click the green **`<> Code`**
button ← **`Download ZIP`**, then double-click the ZIP to unpack it into a
`claude-hebrew-support` folder.

**Advanced (Terminal):**
```bash
git clone https://github.com/Zeev-L/claude-hebrew-support
```

## 🖥️ Desktop (macOS)

**Prerequisite:** [Node.js](https://nodejs.org/) installed (check with `node -v`).

1. Open the **Terminal** app (Cmd+Space, type "Terminal", Enter).
2. Paste these two lines (adjust the path to where you unpacked the download — usually `~/Downloads`):
   ```bash
   cd ~/Downloads/claude-hebrew-support/desktop-mac
   ./patch.sh --install
   ```
3. A new app **Claude-RTL** (RTL-badged icon) is created and opens automatically.

From now on, open **Claude-RTL** (not the regular Claude) for proper Hebrew. Both can coexist.

| Action | Command |
|---|---|
| Uninstall | `./patch.sh --uninstall` |
| Status | `./patch.sh --status` |

> ⚠️ **After every Claude Desktop update**, re-run `./patch.sh --install` (the update overwrites
> the patched copy). Your original `/Applications/Claude.app` is never touched.

## 🌐 Web (claude.ai, Chrome)

1. **Install Tampermonkey** (once): [Chrome Web Store](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) → **Add to Chrome** → **Add extension**.
2. **Install the script:** open
   [`web/claude-rtl.user.js`](https://github.com/Zeev-L/claude-hebrew-support/raw/main/web/claude-rtl.user.js)
   → Tampermonkey shows an install page → click **Install**.
3. **⚠️ Enable user scripts in Chrome (critical, easy to miss):** Chrome blocks userscripts by default.
   Go to `chrome://extensions`, turn on **Developer mode** (top-right); on newer Chrome also open
   Tampermonkey's **Details** → enable **Allow User Scripts**.
4. **Reload [claude.ai](https://claude.ai)** (Cmd+R). Hebrew now aligns right.

> Without step 3 the script appears "installed & enabled" but never runs — the most common mistake.

---

# How it works & how it's built

## RTL detection logic

1. **Script detection** by Unicode range (Hebrew `U+0590–05FF`, Arabic blocks).
2. **First-strong** direction: the first strong character (Hebrew vs. Latin) sets the
   paragraph direction; leading URLs, file paths and inline code are stripped first.
3. **Code blocks** (`pre`, `code`, `.code-block__code`) are forced LTR even inside Hebrew.
4. **Math** (KaTeX / MathJax) is isolated LTR via `unicode-bidi: isolate`.
5. **Streaming**: a debounced `MutationObserver` re-runs detection as the DOM updates.

## One logic, two delivery pipes

The RTL detection logic is a single file — [`shared/rtl-payload.js`](shared/rtl-payload.js) —
used by both targets. Edit it once; rebuild the web userscript with `web/build-web.sh`.

| Target | How the payload is delivered |
|--------|------------------------------|
| **Desktop (macOS)** | `desktop-mac/patch.sh` injects it into a **copy** of `Claude.app`'s `app.asar`, disables the Electron ASAR-integrity fuse, and ad-hoc re-signs. The original `/Applications/Claude.app` is never touched. |
| **Web (claude.ai)** | `web/build-web.sh` wraps the same payload in a Tampermonkey/Violentmonkey userscript. |

## Safety / what it changes

- **Desktop:** operates only on a copy at `~/Applications/Claude-RTL.app`. Because the app.asar
  is modified, the Electron `EnableEmbeddedAsarIntegrityValidation` fuse is disabled and the copy
  is re-signed **ad-hoc** — so the copy is no longer signed by Anthropic. The original keeps its
  Anthropic signature + notarization. Rollback = `--uninstall` or delete the copy.
- **Web:** the userscript uses `@grant GM_addStyle` (not `@grant none`) because claude.ai's CSP
  blocks page-context injection; a non-`none` grant runs it in the manager's isolated sandbox
  (full DOM access, CSP-exempt). Verified: paragraphs and the `[data-testid="chat-input"]`
  composer both go RTL on claude.ai.

## Credits & license

MIT. RTL detection logic by [@shraga100](https://github.com/shraga100/claude-desktop-rtl-patch)
(Windows original); macOS patcher by [@soguy](https://github.com/soguy/claude-desktop-rtl-mac).
This repository packages both into one cross-surface framework. See [LICENSE](LICENSE).

---
<a id="hebrew"></a>

# 🇮🇱 גרסה עברית

תמיכה אוטומטית בעברית/ערבית ב-Claude — יישור לימין בזמן אמת ב-**Claude Desktop (macOS)** וב-**claude.ai בדפדפן**, תוך שמירה על בלוקי קוד, נוסחאות וטקסט אנגלי משמאל לימין. עובד גם תוך כדי שהתשובה נכתבת.

## 🚀 התקנה מהירה

> 🤖 **עם Claude Code:** סוכן יכול לשכפל את ה-repo ולהריץ עבורך את הסקריפטים
> (`desktop-mac/patch.sh --install`, `web/build-web.sh`) ולהסביר כל שלב. השאר
> ידני בכוונה ו**רק אתה** יכול לעשות אותו: התקנת התוסף Tampermonkey, הדלקת
> **Developer mode** ב-Chrome, ואישור החתימה-מחדש / Gatekeeper ב-macOS — פעולות
> ממשק/אמון של מערכת ההפעלה שאי אפשר לבצע בסקריפט.

### ⬇️ קודם: להוריד את הקבצים

**הדרך הקלה (מומלצת):** בראש העמוד הזה ב-GitHub לחץ על הכפתור הירוק **`<> Code`** ← **`Download ZIP`**, ואז פתח את ה-ZIP (לחיצה כפולה). תיווצר תיקייה בשם `claude-hebrew-support`.

**הדרך למתקדמים (Terminal):**
```bash
git clone https://github.com/Zeev-L/claude-hebrew-support
```

### 🖥️ התקנה — Claude Desktop (macOS)

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

### 🌐 התקנה — claude.ai (בדפדפן Chrome)

1. **התקן את התוסף Tampermonkey** (פעם אחת): [לחץ כאן](https://chromewebstore.google.com/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo) ← **Add to Chrome** ← **Add extension**.
2. **התקן את הסקריפט:** פתח בדפדפן את הקישור —
   [claude-rtl.user.js](https://github.com/Zeev-L/claude-hebrew-support/raw/main/web/claude-rtl.user.js)
   — Tampermonkey יציג עמוד התקנה, לחץ על הכפתור הירוק **Install**.
3. **⚠️ הדלק userscripts ב-Chrome (קריטי — קל לפספס!):** Chrome חוסם userscripts כברירת מחדל.
   - בשורת הכתובת הקלד `chrome://extensions` ולחץ Enter.
   - בפינה הימנית-עליונה **הדלק את "Developer mode"**.
   - (ב-Chrome חדש) על כרטיס Tampermonkey לחץ **Details** ← הדלק **"Allow User Scripts"**.
4. **רענן את [claude.ai](https://claude.ai)** (Cmd+R) — וזהו, עברית תתיישר לימין.

> בלי שלב 3 הסקריפט יופיע כ"מותקן ופעיל" אבל **לא ירוץ**. זו הטעות הכי נפוצה.

## איך זה עובד (בקצרה)

מזהה עברית/ערבית לפי טווחי Unicode, קובע כיוון לפי התו ה"חזק" הראשון בפסקה, ומיישר לימין — אבל **בלוקי קוד ונוסחאות נשארים תמיד משמאל לימין**. תוך כדי סטרימינג, מנגנון מעקב (MutationObserver) מריץ את הזיהוי מחדש על כל טקסט חדש.

## בטיחות

- **דסקטופ:** עובד רק על **עותק** ב-`~/Applications/Claude-RTL.app`. המקור ב-`/Applications` נשאר חתום ע"י Anthropic ולא נגעים בו. כדי לאפשר את השינוי, מכבים בעותק את בדיקת התקינות של Electron וחותמים אותו מחדש "אד-הוק". חזרה אחורה = `--uninstall` או מחיקת העותק.
- **web:** תיקון תצוגה בלבד בדפדפן שלך — לא משנה כלום בתוכן השמור.

## קרדיט ורישיון

רישיון MIT. לוגיקת זיהוי ה-RTL מאת [@shraga100](https://github.com/shraga100/claude-desktop-rtl-patch) (מקור ל-Windows); מתקין ה-macOS מאת [@soguy](https://github.com/soguy/claude-desktop-rtl-mac). הריפו הזה אורז את שניהם למסגרת אחת + מוסיף את גרסת ה-web.
