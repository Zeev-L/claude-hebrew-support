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

**Prerequisites (new machine — do these first):**
1. Install **Claude Desktop** from [claude.ai/download](https://claude.ai/download) and **sign in**.
   (The patched copy shares your login and chats with it, so sign in once here first.)
2. Install **Node.js** from [nodejs.org](https://nodejs.org/) (the green "LTS" button). Check in
   Terminal with `node -v` — a version number means you're set.

**Install:**
1. Open the **Terminal** app (Cmd+Space, type "Terminal", Enter).
2. Paste these two lines (adjust the path to where you unpacked the download — usually `~/Downloads`):
   ```bash
   cd ~/Downloads/claude-hebrew-support/desktop-mac
   ./patch.sh --install
   ```
3. A new app **Claude-RTL** (RTL-badged icon) is created and opens automatically.
4. **Approve the one-time macOS prompts:** the first time it touches files / Keychain, click
   **Allow** (and **Always Allow** for any "Claude Safe Storage" keychain prompt). It's remembered.

From now on, open **Claude-RTL** (not the regular Claude) for proper Hebrew. Both can coexist.
For several conversations side by side, just press **⌘N** for more windows.

| Action | Command |
|---|---|
| Uninstall | `./patch.sh --uninstall` |
| Status | `./patch.sh --status` |

> ⚠️ **After every Claude Desktop update**, rebuild the patched copies (the official update only
> touches `/Applications/Claude.app`). One command rebuilds Claude-RTL + all parallel instances:
> ```bash
> "$HOME/Library/Application Support/claude-rtl/update-rtl.sh"
> ```
> `patch.sh` copies its tooling to that stable folder, so this keeps working even after you delete
> the download.
>
> **Auto-reminder (recommended):** during `patch.sh --install` you're **offered an update checker** —
> at login + once a day it detects a new Claude version and pops "Update your RTL apps now?" ("Update
> now" does it for you). It's installed from the stable folder, so it survives to a fresh install on a
> new machine. Manage it manually with
> `"$HOME/Library/Application Support/claude-rtl/install-update-checker.sh"` (add `--uninstall` to remove).

## 🖥️➕ Work on several conversations side by side

**Recommended: just open more windows.** In Claude-RTL press **⌘N** for a new window — put two (or
more) side by side, each on a different conversation, all with RTL. Same login and history, one app,
nothing extra to install or update. For almost everyone this is all you need.

<details>
<summary><b>Advanced: separate app instances</b> (rarely needed)</summary>

A separate instance (Claude-RTL-2, -3…) is a distinct app **process** with its own Dock icon. It
shares the same login and chats as Claude-RTL, so it gives nothing extra over ⌘N windows **except**
process isolation — worth it only if you run heavy Cowork/agent tasks in parallel and want one to
survive if another crashes. The cost: another app to re-approve permissions for and rebuild after
each Claude update.

```bash
~/Library/Application\ Support/claude-rtl/make-instance.sh 2    # create "Claude-RTL-2"
~/Library/Application\ Support/claude-rtl/make-instance.sh --uninstall 2   # remove it
```

Each instance gets its **own** macOS identity; login/chats/projects stay shared (they key off the
app name, not the id). Don't edit the *same* conversation in two instances at once.
</details>

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

## Troubleshooting

**macOS keeps asking "Claude-RTL would like to access your Desktop folder" on almost every launch.**
This happens when a patched copy keeps Anthropic's bundle id (`com.anthropic.claudefordesktop`):
macOS ties folder-permission grants to bundle id + signature, so it can't tell the copies apart
from the original (or from each other) and never remembers the grant — it re-prompts every time
you switch apps. The fix is a unique bundle id per app, which both scripts now do automatically
(`patch.sh` → `…rtl`, `make-instance.sh` → `…rtlN`). If you're hitting this on an older copy,
re-run `./patch.sh --install` (and `make-instance.sh` for any extra instances), then approve the
prompt **once** — it sticks afterward. Don't manually re-sign the apps later; every re-sign
resets macOS's memory of the grant and the prompt comes back.

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

**מה צריך מראש (במכונה חדשה — קודם כל):**
1. התקן את **Claude Desktop** מ-[claude.ai/download](https://claude.ai/download) ו**התחבר**.
   (הגרסה המתוקנת חולקת איתו את ההתחברות והצ'אטים — אז התחבר פעם אחת כאן קודם.)
2. התקן **Node.js** מ-[nodejs.org](https://nodejs.org/) (הכפתור הירוק "LTS"). בדיקה ב-Terminal: `node -v` — מספר גרסה = מוכן.

**התקנה:**
1. פתח את אפליקציית **Terminal** (Cmd+רווח, הקלד "Terminal", Enter).
2. העתק והדבק את שתי השורות הבאות, אחת-אחת, ולחץ Enter. **החלף את הנתיב** לתיקייה שהורדת (אם הורדת ZIP, היא כנראה ב-`~/Downloads`):
   ```bash
   cd ~/Downloads/claude-hebrew-support/desktop-mac
   ./patch.sh --install
   ```
3. נוצרה אפליקציה חדשה בשם **Claude-RTL** (עם תווית RTL על האייקון), והיא נפתחת לבד. לשיחות מקבילות — פשוט לחץ **⌘N** לחלונות נוספים.
4. **אשר את בקשות ה-macOS החד-פעמיות:** בפעם הראשונה שהיא ניגשת לקבצים/Keychain — לחץ **Allow** (ו-**Always Allow** לבקשת "Claude Safe Storage"). זה נשמר.

**מעכשיו:** פתח תמיד את **Claude-RTL** (לא את Claude הרגיל) כדי לקבל עברית מסודרת. שתיהן יכולות לחיות זו לצד זו.

| פעולה | פקודה |
|---|---|
| הסרה | `./patch.sh --uninstall` |
| בדיקת מצב | `./patch.sh --status` |

> ⚠️ **אחרי כל עדכון של Claude Desktop** צריך לבנות מחדש את העותקים המתוקנים (העדכון הרשמי נוגע רק ב-`/Applications/Claude.app`). פקודה אחת בונה מחדש את Claude-RTL וכל המופעים המקבילים:
> ```bash
> "$HOME/Library/Application Support/claude-rtl/update-rtl.sh"
> ```
> `patch.sh` מעתיק את הכלים לתיקייה היציבה הזו, אז זה עובד גם אחרי שמחקת את ההורדה.
>
> **תזכורת אוטומטית (מומלץ):** במהלך `patch.sh --install` **תוצע לך התקנת בודק עדכונים** — בהתחברות ופעם ביום הוא מזהה גרסה חדשה של Claude וקופץ עם "לעדכן את אפליקציות ה-RTL?" ("Update now" עושה את זה בשבילך). הוא מותקן מהתיקייה היציבה, אז הוא שורד להתקנה טרייה במכונה חדשה. ניהול ידני: `"$HOME/Library/Application Support/claude-rtl/install-update-checker.sh"` (הוסף `--uninstall` להסרה).

### 🖥️➕ עבודה על כמה שיחות במקביל

**מומלץ: פשוט לפתוח עוד חלונות.** ב-Claude-RTL לחץ **⌘N** לחלון חדש — שים שניים (או יותר) זה לצד זה, כל אחד בשיחה אחרת, כולם עם RTL. אותה התחברות והיסטוריה, אפליקציה אחת, בלי שום דבר להתקין או לעדכן. לרוב האנשים זה כל מה שצריך.

<details>
<summary><b>מתקדם: מופעים נפרדים של האפליקציה</b> (לרוב לא נחוץ)</summary>

מופע נפרד (Claude-RTL-2, -3…) הוא **תהליך** אפליקציה נפרד עם אייקון משלו ב-Dock. הוא חולק את אותה התחברות והיסטוריה כמו Claude-RTL, אז הוא לא נותן שום דבר מעבר לחלונות ⌘N **חוץ מ**בידוד תהליכים — שווה רק אם אתה מריץ משימות Cowork/סוכן כבדות במקביל ורוצה שאחד ישרוד אם אחר קורס. המחיר: עוד אפליקציה לאשר לה הרשאות ולבנות מחדש אחרי כל עדכון של Claude.

```bash
~/Library/Application\ Support/claude-rtl/make-instance.sh 2    # יצירת "Claude-RTL-2"
~/Library/Application\ Support/claude-rtl/make-instance.sh --uninstall 2   # הסרה
```

לכל מופע **תעודת זהות משלו** ב-macOS; ההתחברות/הצ'אטים/הפרויקטים נשארים משותפים (תלויים בשם האפליקציה, לא בתעודת הזהות). אל תערוך את **אותה שיחה** בשני מופעים בו-זמנית.
</details>

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
