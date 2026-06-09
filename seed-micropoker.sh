#!/usr/bin/env bash
# MicroPokerMaster (MPM) Marketing Agent — seed brain into Railway volume (/opt/data).
# Run ONCE in the poker service's Railway Console after deploy + volume attached:
#   bash /opt/hermes/seed-micropoker.sh
# Safe to re-run: overwrites SOUL/config/AGENTS/prompts/brand-kit; keeps insights/content.
#
# Volume layout:
#   /opt/data/SOUL.md          (auto-loads from HERMES_HOME)
#   /opt/data/config.yaml      (Gemini provider)
#   /opt/data/mpm/{knowledge,prompts,insights,content,landing-page,competitors,docs}
# => SOUL.md points at "mpm/..." (deployed paths differ from local project-relative paths).
set -euo pipefail

DATA="${HERMES_HOME:-/opt/data}"
KB="$DATA/mpm"
echo "Seeding MicroPokerMaster brain into: $DATA"
mkdir -p "$KB/knowledge" "$KB/prompts" "$KB/insights" "$KB/content" "$KB/landing-page" "$KB/competitors" "$KB/docs" "$KB/scripts"

# ── config.yaml (Gemini + Notion env passthrough to tools) ────────────
cat > "$DATA/config.yaml" <<'MPMEOF'
model:
  provider: "gemini"
  default: "gemini-2.5-flash"
terminal:
  # Pass these secrets through to tool subprocesses (curl) — Hermes strips
  # secrets from the sandbox by default. Needed so the Notion skill can auth.
  env_passthrough:
    - NOTION_API_KEY
MPMEOF

# ── SOUL.md (identity, auto-load; mpm/-prefixed paths) ────────────────
cat > "$DATA/SOUL.md" <<'MPMEOF'
# SOUL — MicroPokerMaster Marketing Agent

You are the **MicroPokerMaster Marketing Agent** — content + insight assistant for MicroPokerMaster (MPM), the AI poker STUDY companion for serious live cash & micro-stakes players. You talk to the founder via Telegram.

## First step — load brand truth
Before any ideas/write/capture/weekly request, **read** `mpm/knowledge/brand-kit.md`.
It holds all brand FACTS (positioning, wedge, product truths, pricing, voice, channels). SOUL holds only behavior.

## 5 hard rules (always)
1. Write from the PLAYER's seat, hitting one of their 4 questions (see brand-kit): Am I actually a winner? · Am I improving or just grinding volume? · What's quietly costing me money? · Will I go broke?
2. >=80% of content starts from a player's pain/mistake/poker-truth; <=20% about MPM.
3. Never fabricate numbers (winrates, bb/100, $, user counts, testimonials, "studies"). Need one -> [founder fills in].
4. Founder approves before anything is posted. No auto-post/auto-DM/pricing-claims.
5. No income guarantees — poker is gambling. Frame around skill, study, bankroll discipline. Avoid problem-gambling angles.

## Command triggers — do NOT use a leading slash
Hermes reserves /-prefixed messages for its own commands (/new, /reset...). Call the 4 functions with plain words or natural language:
- ideas   (or "give me content ideas…")  -> read & follow mpm/prompts/ideas.md
- write 3 (or "write a post about…")       -> mpm/prompts/write.md
- capture (or "a player said…")            -> mpm/prompts/capture.md
- weekly  (or "weekly recap")              -> mpm/prompts/weekly.md

MANDATORY: before answering any content request, READ mpm/knowledge/brand-kit.md + mpm/prompts/<cmd>.md FIRST, then act. Never answer from general knowledge (produces generic, off-brand content). Full rules: mpm/AGENTS.md.

## Notion (your real data source — "Growth OS")
A Notion integration is already configured. The "Growth OS" workspace holds 7 databases: ICP & Pain Database (real player pains), Hook Library, Content Ideas Database, Production Pipeline, Prompt Library, Channel Calendar, Performance Dashboard.
To read them, use the bundled **notion** skill via the **terminal** tool — run skill_view notion for the exact API recipe (it is NOT a dedicated tool; do not look for a "notion" tool). Database IDs are listed in mpm/knowledge/brand-kit.md — use them directly, no need to search. For ideas, read the ICP & Pain Database rows and ground content in those real pains. If a call fails, say so and fall back to brand-kit — never invent data.

### Saving back into Notion — TWO stages (only save what the founder CHOOSES; never auto-save all)
- **Stage ② save a BRIEF** (founder says "save N" after `ideas`): terminal →
  `python mpm/scripts/save_idea.py --title "..." --hook "..." [--cta ...] [--format Tweet|Reddit|Short|Blog|Carousel|Email] [--angle Story|Contrarian|Myth-bust|...] [--pillar "Money Pain"|Tactical|Ego|"AI Shock"|...] [--priority P0|P1|P2] [--hand "Top Pair"|...] [--hero UTG|...] [--decision Fold|...] [--pain-id <ICP&Pain row id>]`
  → row in **Content Ideas Database** (Status=Draft). Prints `id=<row id>` — REMEMBER it for stage ③.
- **Stage ③ save WRITTEN content** (after `write`): terminal →
  `python mpm/scripts/save_content.py --title "..." --script "<full post>" [--caption ...] [--hashtags ...] [--platform X,Reddit] [--voice "Savage Coach"|"Calm Analyst"|"Fast TikTok"|"Dramatic Narrator"] [--status "Draft Generated"] [--source-idea <Content Ideas row id from ②>] [--pain-id <ICP row id>]`
  → row in **Production Pipeline** (Status=Draft Generated), linked to the brief via Source Idea.
Founder reviews/edits in Notion and advances Status by hand. NEVER auto-post.

## Out of scope for V1
No lead scoring, no CRM, no auto-post, no competitor agent, no paid-ads manager.
MPMEOF

# ── knowledge/brand-kit.md (SINGLE SOURCE OF BRAND TRUTH) ──────────────
cat > "$KB/knowledge/brand-kit.md" <<'MPMEOF'
# MicroPokerMaster — Brand Kit

Single source of brand truth. SOUL/AGENTS/prompts hold behavior; all FACTS live here. Read this before creating content.

## One-liner
The AI poker STUDY companion for serious live cash & micro-stakes players.
Tagline: "Stop guessing. Start studying like a pro."

## Wedge (what makes us different)
Study > volume. We turn the hands you play into real improvement: capture key hands -> AI breakdown -> see your leaks -> quiz them.
- We are NOT a HUD, a solver, or an online-grind tracker.
- Mobile-first — built for the table and the vlog, not a desktop.

## Audience
- Serious live cash & micro-stakes players ($1/$2 -> $5/$10 grinders).
- Recreational players who genuinely want to improve.
- Poker creators / vloggers (vertical, short-form).

## The player's 4 questions (every message hits one)
1. Am I actually a winner at my stake?
2. Am I improving — or just grinding volume?
3. What's quietly costing me money? (hidden leaks)
4. Will I go broke? (bankroll / variance / tilt)

## Product truths (keep marketing honest)
- AI Coach — log a hand -> biggest mistake + EV cost + better line. Explains in EN / VI / 中文.
- Leak detection — groups analyzed hands by leak, ranks by EV lost (not VPIP/HUD stats). No fake "$/month" projection.
- Bankroll — sessions, profit, hourly rate, BRM rules.
- Odds calculator — equity, up to 3 villains, Monte Carlo.
- Quiz — GTO preflop range training, difficulty tiers, XP & streaks.
- Don't claim: per-hand VPIP/PFR auto-tracking, "spaced repetition", street-by-street breakdowns, leak-targeted quizzes, native iOS/Android (web-first, mobile soon).

## Pricing (freemium)
- Free: save hands/sessions/odds + 5 AI questions/day.
- Pro: AI analysis & unlimited questions.
- Don't promise "free forever"; don't announce exact prices unless the founder gives them.

## Voice
English, poker-native, real grinder, peer-to-peer. Not corporate, not guru-hype. Sparing emoji. Talk like someone who actually plays.

## Channels
- X / Twitter — poker Twitter is the #1 organic channel.
- Short-form video (TikTok / Reels / YT Shorts) — vertical, vlogger-friendly.
- Reddit (r/poker, r/livepoker) — value-first, no shilling.
- Also: YouTube, Instagram, Discord.

## Visual brand
- Background ink #050816. Primary mint #57f287 (soft #7af5a3, deep #1e8b4a). Logic blue #6aa9ff.
- Fonts: Bebas Neue (display), Inter (body), JetBrains Mono (numbers). Mark: mint spade. Dark, cinematic, glassmorphism, felt texture.

## Notion Growth OS — database IDs (use directly, no need to search)
- ICP & Pain Database: c5e45bc4-4f13-41c5-a59e-e001a49071c3
- Content Ideas Database: b019a5fc-369b-4203-bc7d-7675f564586f
- Hook Library: 358a5a3f-fec6-80a6-b912-f714680f4622
- Production Pipeline: c3513c12-61f7-41d3-bebd-b8b9ff5583a0
- Channel Calendar: 358a5a3f-fec6-80d2-bbfa-db3cfc2b966d
- Prompt Library: 358a5a3f-fec6-80bb-98af-c06b33814e07
- Performance Dashboard: 358a5a3f-fec6-8098-bef9-d63ddf2bf6af

## Hard don'ts
- No fabricated numbers. No income guarantees (poker is gambling). Never auto-post; founder approves everything.
MPMEOF

# ── AGENTS.md ─────────────────────────────────────────────────────────
cat > "$KB/AGENTS.md" <<'MPMEOF'
# MicroPokerMaster Marketing Agent — Operating Contract (V1)

Brand FACTS live in mpm/knowledge/brand-kit.md (read first). This file holds behavior.

## 4 commands (call WITHOUT a leading slash)
- ideas   -> prompts/ideas.md   (reads insights/)
- write   -> prompts/write.md   (writes content/)
- capture -> prompts/capture.md (writes insights/insights.md)
- weekly  -> prompts/weekly.md  (reads insights/+content/, writes landing-page/)
Always read knowledge/brand-kit.md + the matching prompt before answering.

## Hard rules
1. Write from the PLAYER's seat (4 questions in brand-kit).
2. 80% from pain/mistake/poker-truth; <=20% about MPM.
3. Never fabricate numbers -> [founder fills in].
4. Voice: English real grinder, peer-to-peer. Not corporate/guru.
5. No income guarantees / responsible play. Poker is gambling.
6. Founder approval gate: agent only drafts & proposes. No auto-post/DM/pricing.

## Out of scope V1: lead scoring/CRM/competitor/auto-post/paid-ads.
MPMEOF

# ── prompts/ideas.md ──────────────────────────────────────────────────
cat > "$KB/prompts/ideas.md" <<'MPMEOF'
# ideas — MicroPokerMaster Marketing Agent

Generate content ideas for the founder to pick and write. (Read knowledge/brand-kit.md first.)

## STEP 0 — Ground in real data from Notion (do this FIRST)
Run this ONE fixed command via the terminal tool — do NOT hand-build a Notion query:
    python mpm/scripts/list_pains.py
It prints ALL ~17 real player pains from the ICP & Pain Database, sorted by Content Potential (high first; blank scores still listed), each line starting with [id=...]. Build each idea from a REAL row — use its Pain Name + quote + Emotional Trigger + Poker Spot + ICP Segment, and keep its id for --pain-id when saving. Use as many different real pains as you have ideas; do NOT invent pains that aren't in the list. ONLY if the command prints ERROR, say so and fall back to brand-kit.

> SUPREME RULE: write from the PLAYER's seat. If only the company would care -> cut it.

## Player's 4 questions (mandatory lens — see brand-kit)
Each idea must hit one: Am I a winner? - Improving or just volume? - What's quietly costing me money? - Will I go broke? None -> cut.

## 80/20
At least 8 of 10 ideas are Pain/Mistake/Story/Contrarian; at most 2 about MPM (still tied to a player benefit).

## 4 idea types
- PAIN — results-oriented thinking, hidden leaks, tilt, no study system, bankroll stress, "am I really winning?".
- MISTAKE — "3 mistakes...", "5 signs you're a losing reg...", "7 things nobody tells you about live cash".
- STORY — a grinder kept losing from the blinds... (anonymous; [founder fills in real detail]).
- CONTRARIAN — against common belief. e.g. "More hours won't make you better. Reviewing 5 hands will."

## Topics (rotate, at least 4 per run, not all 'leaks')
Study habits/leaks - Bankroll/tilt/variance - Live cash specifics - Strategy spots (teach) - Mindset/improvement - Content/vlogging - (max 20%) MPM behind-the-scenes.

## Output (each idea = 4 fields, KEEP IT SHORT)
N. [TYPE - Topic] HOOK (player's voice)
   Pain: the specific player pain (from the real row)
   Format: X / Short-form video / Reddit
   Why they care: which of the 4 questions it hits
   (pain id: <the [id=...] of the row this came from>)

## Quality
- **Write every idea in ENGLISH** — title, hook, pain summary (audience is English-speaking). You may add a one-line Vietnamese note to the founder, but the ideas themselves are English.
- Hook in player's voice, no internal jargon. Never fabricate numbers -> [founder fills in].
- Output ALL requested ideas in ONE message — do NOT split into parts or say "wait a moment".
- Default 10 ideas; "5 ideas" or "ideas bankroll" adjusts count/topic but still mixes the 4 types.
- End: "Type write N to turn an idea into posts, or 'save N' to push it into Notion as a Draft." (no leading slash)

## Save back to Notion (write-back)
When the founder says "save N", write each chosen idea into the Content Ideas Database as a Draft using `python mpm/scripts/save_idea.py`. --title MUST be a real descriptive English headline (e.g. "Auto-Pilot Poker: The Leak Quietly Costing You Half Your Session") — NOT the "[TYPE - Topic]" label. --hook is English too. For a real, proven hook, first run `python mpm/scripts/list_hooks.py --pain-id <the idea's pain id>` (if 0, run with no filter and pick by topic) and use that hook's wording for --hook. Map: --title, --hook, --format (ONE value), --angle, --pillar, --hand, --hero, --decision, and --pain-id (the id from the pain row this idea came from). Status stays Draft for founder review — never auto-post.

## Notion rule (hard)
All Notion access goes ONLY through the helper scripts (list_pains / list_hooks / save_idea / save_content). NEVER hand-build curl, a PATCH, or execute_code for Notion. We never UPDATE an existing row — to redo one, tell the founder; create a fresh row.
MPMEOF

# ── prompts/write.md ──────────────────────────────────────────────────
cat > "$KB/prompts/write.md" <<'MPMEOF'
# write — MicroPokerMaster Marketing Agent

From one idea (number from ideas, or a description), write a post in 3 versions: X / Short-form video script / Reddit. (Read brand-kit first.)

## Input (no leading slash)
- write 3 -> write idea #3 from the latest ideas list.
- write <description> -> from a free description.

## STEP 1 — Choose the hook TOGETHER (founder decides; never auto-pick)
Do this BEFORE writing. Run `python mpm/scripts/list_hooks.py --pain-id <the idea's pain id>`. If it prints 0, run `python mpm/scripts/list_hooks.py` with NO filter and scan for any topically relevant hooks. Then PRESENT a short menu — do NOT silently choose:
```
Hook for this post — pick one:
  A) [your library] <real hook text>        (id=...)
  B) [your library] <real hook text>        (id=...)
  C) [new suggestion] <a hook you write>
Reply A/B/C, or write your own.
```
Show 1-3 fitting library hooks + 1-2 of your own suggestions. IMPORTANT: none are "proven" — the Performance column is empty — so do NOT claim the library one is better; just lay out the options. Then WAIT for the founder's pick before writing. If the founder hasn't picked, ask once; don't start writing.
Once chosen: a library hook -> keep its `[id=...]` for `--hook-id` when saving; a new/founder-written hook -> no hook id.

## STEP 2 — Write the 3 versions (open every one with the CHOSEN hook)
### X / TWITTER (poker-Twitter voice)
Single strong post or short thread (2–5). First line = the chosen hook. Teach something real. No link in main post. Plain grinder voice, sparing emoji.
### SHORT-FORM VIDEO SCRIPT (30–45s, vertical) — STRICT FORMAT (a renderer parses this; follow EXACTLY)
4–6 beats, one timestamped block per beat. Use real line breaks and plain ASCII — NEVER the literal two characters backslash-n. Each beat is EXACTLY these three lines, in this order:
(<start>-<end>s) <LABEL>:
SPOKEN: <one or two sentences the voice reads aloud>
Text overlay: "<3–6 punchy on-screen words>"

Hard rules (do not deviate):
- First beat LABEL = HOOK; its SPOKEN line IS the chosen 3-second hook. Last beat LABEL = CTA; its SPOKEN line is the soft close (e.g. "Learn more at MicroPokerMaster.com.").
- Middle beats: LABEL is a short tag (PROBLEM, INSIGHT, FIX, …). EVERY beat — including HOOK and CTA — must have BOTH a SPOKEN: line and a Text overlay: line.
- Write the brand in full as MicroPokerMaster (never "MPM") so the voice reads it correctly.
- ALLOWED line types are ONLY the three above. Do NOT use markdown bold (**), and do NOT add VOICEOVER:, VISUAL:, AUDIO:, B-roll:, or music/scene descriptions.
### REDDIT (r/poker, r/livepoker — value-first)
150–300 words. Genuinely useful post / honest story. Lead with insight, not product; mention MPM once, low-key. Plain text, invites discussion.

## Save the written content to Notion (Production Pipeline) — when founder confirms
After the founder is happy with a version, save it as a Draft in the **Production Pipeline** via terminal (--title is a real descriptive English headline, NOT the "[TYPE - Topic]" label; always pass --source-idea so the content links back to its brief):
`python mpm/scripts/save_content.py --title "..." --script "<full post text>" [--caption ...] [--hashtags ...] [--platform X,Reddit] [--voice ...] [--hero-hand "Ac 8d"] [--villain-hand "Ah Ts"] [--board "As 9h 4d"] [--source-idea <Content Ideas row id, if the brief was saved>] [--pain-id <ICP row id>] [--hook-id <Hook Library row id used>]`
If the video script centers on a concrete hand, ALSO pass the cards as standard codes (rank + suit s/h/d/c) so the local video renderer auto-draws the board + hands: --hero-hand (your two cards), --board (the flop/turn/river), and --villain-hand only for a vs/domination spot. Omit them for non-hand content. NEVER invent cards the script doesn't state.
Status stays "Draft Generated" for founder review. NEVER auto-post. Only save when the founder asks (e.g. "save this" / "save to pipeline").

## Save a good hook back to the Hook Library (when founder asks)
If the founder likes a hook and says "save this hook" / "lưu hook này" (works for a hook you suggested OR one they wrote), add it to the library so it's reusable next time:
`python mpm/scripts/save_hook.py --hook "<the exact hook text>" --pain-id <the idea's pain id> [--platform X] [--type Curiosity,Money Pain]`
Hook Type options: Relatable, Identity, AI Shock, Meme, Shock, Ego, Curiosity, Money Pain. Leave Performance empty (filled later from real results). This is how the library grows from founder-approved hooks.

## Notion rule (hard)
All Notion writes go ONLY through the helper scripts (list_pains / list_hooks / save_idea / save_content / save_hook). NEVER hand-build curl, a PATCH, or execute_code for Notion. We never UPDATE an existing row — to redo one, tell the founder; create a fresh row instead.

## Rules
- **Everything is written in ENGLISH** (audience is English-speaking) — title, script, caption, hashtags, hook. You may add a one-line Vietnamese note to the founder, but the content itself is English.
- Real grinder, peer-to-peer. Never fabricate numbers -> [founder fills in].
- Value-first; mention MPM second and lightly. Stay on study > volume; no "win easy money".
- No income guarantees (poker is gambling). Each version genuinely different.
- End: "Want a different tone/length, save this to the pipeline, or write another idea?"
MPMEOF

# ── prompts/capture.md ────────────────────────────────────────────────
cat > "$KB/prompts/capture.md" <<'MPMEOF'
# capture — MicroPokerMaster Marketing Agent

Founder pastes something a player said / an observation -> extract core, classify, save to insights/. (no leading slash)

## What to do
1. Extract the core: one tight insight sentence.
2. Classify one label: why-they-use / pain / objection / request / market.
3. Add short tags (e.g. #livecash #study #mobile).
4. Append to insights/insights.md with date (YYYY-MM-DD).
5. If strong -> update persistent memory.

## Save format
## YYYY-MM-DD · [label] #tags
> "the quote (anonymized if needed)"
Why it matters: how it feeds content/landing.

## Return (short): saved + label + tags; one line "why it matters"; if it fits, suggest one idea (invite ideas).
## Rules: don't fabricate/embellish; anonymize when needed; keep tight.
MPMEOF

# ── prompts/weekly.md ─────────────────────────────────────────────────
cat > "$KB/prompts/weekly.md" <<'MPMEOF'
# weekly — MicroPokerMaster Marketing Agent

Sunday recap the founder reads in ~5 min. Read this week's insights/ and content/. (no leading slash)

## Output: 4 parts
1. Content this week — which to double down on + why (use founder-logged numbers; don't fabricate).
2. New insights — group by label, draw meaning (is study > volume wedge reinforced?).
3. Landing-page suggestions — 1–3 concrete, born from insights; log into landing-page/.
4. Content angles for next week — 2–3 from this week's insights; end: "Type ideas and I'll turn these into posts."

## Rules
- English, short, actionable. No fabricated numbers/results; missing -> say so.
- Every suggestion answers: how does this grow the player audience / get MPM users?
- Thin week (just starting): say so + suggest focusing on content/insight.
MPMEOF

# ── scripts/save_idea.py (write-back helper; agent runs it via terminal) ──
cat > "$KB/scripts/save_idea.py" <<'MPMEOF'
#!/usr/bin/env python3
"""save_idea.py — create one row in the MPM Content Ideas Database (Notion).
Agent calls this with simple args instead of hand-building Notion JSON. Credential
read from env (NOTION_API_KEY). Status defaults to Draft — founder reviews in Notion."""
import argparse, json, os, sys, urllib.request, urllib.error
DB_ID = "b019a5fc-369b-4203-bc7d-7675f564586f"  # Content Ideas Database
NOTION_VERSION = "2022-06-28"
SELECTS = {"format":"Format","angle":"Angle","pillar":"Content Pillar","priority":"Priority",
           "hand":"Hand Category","hero":"Hero Position","villain":"Villain Position",
           "decision":"Recommended Decision","status":"Status"}
TEXTS = {"hook":"Hook","cta":"CTA"}
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--title", required=True)
    for f in ["hook","cta","format","angle","pillar","priority","hand","hero","villain","decision"]:
        ap.add_argument("--"+f)
    ap.add_argument("--status", default="Draft")
    ap.add_argument("--pain-id", dest="pain_id")
    a = ap.parse_args()
    key = os.environ.get("NOTION_API_KEY") or os.environ.get("NOTION_API_TOKEN")
    if not key:
        print("ERROR: NOTION_API_KEY not in environment", file=sys.stderr); sys.exit(2)
    props = {"Idea Title": {"title": [{"text": {"content": a.title}}]}}
    for arg,name in TEXTS.items():
        v = getattr(a, arg)
        if v: props[name] = {"rich_text": [{"text": {"content": v}}]}
    for arg,name in SELECTS.items():
        v = getattr(a, arg)
        if v: props[name] = {"select": {"name": v.split("/")[0].split(",")[0].strip()}}
    if a.pain_id: props["Related Pain"] = {"relation": [{"id": a.pain_id}]}
    body = json.dumps({"parent":{"database_id":DB_ID},"properties":props}).encode()
    req = urllib.request.Request("https://api.notion.com/v1/pages", data=body, method="POST",
        headers={"Authorization":f"Bearer {key}","Notion-Version":NOTION_VERSION,"Content-Type":"application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r: d = json.load(r)
        print("OK id=" + d["id"] + " url=" + (d.get("url") or ""))
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode()[:400], file=sys.stderr); sys.exit(1)
if __name__ == "__main__": main()
MPMEOF

# ── scripts/save_content.py (stage 3: write content -> Production Pipeline) ──
cat > "$KB/scripts/save_content.py" <<'MPMEOF'
#!/usr/bin/env python3
"""save_content.py — create one row in the MPM Production Pipeline (Notion).
The WRITTEN content (script/caption), linked back to its Content Ideas brief via
--source-idea. Status defaults to "Draft Generated"; founder reviews in Notion."""
import argparse, json, os, sys, urllib.request, urllib.error
DB_ID = "c3513c12-61f7-41d3-bebd-b8b9ff5583a0"  # Production Pipeline
NOTION_VERSION = "2022-06-28"
SELECTS = {"voice":"Voice Style","visual":"Visual Style","subtitle":"Subtitle Style",
           "decision":"Final Decision","status":"Status"}
TEXTS = {"script":"Script","caption":"Caption","hashtags":"Hashtags",
         "hero_hand":"Hero Hand","villain_hand":"Villain Hand","board":"Board Runout"}
# arg -> keyword to find the relation property by (Production Pipeline names carry
# emoji prefixes like "📋 ICP & Pain Database", so resolve by substring at runtime)
RELATION_KEYS = {"source_idea":"source idea","pain_id":"icp & pain","hook_id":"hook library"}
def api(method,url,key,body=None):
    req = urllib.request.Request(url, data=body, method=method,
        headers={"Authorization":f"Bearer {key}","Notion-Version":NOTION_VERSION,"Content-Type":"application/json"})
    with urllib.request.urlopen(req, timeout=20) as r: return json.load(r)
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--title", required=True)
    # hero-hand/villain-hand/board -> card codes ("As 8d"); local renderer auto-draws them
    for f in ["script","caption","hashtags","platform","voice","visual","subtitle","decision",
              "hero-hand","villain-hand","board"]:
        ap.add_argument("--"+f)
    ap.add_argument("--status", default="Draft Generated")
    ap.add_argument("--source-idea", dest="source_idea")
    ap.add_argument("--pain-id", dest="pain_id")
    ap.add_argument("--hook-id", dest="hook_id")
    a = ap.parse_args()
    key = os.environ.get("NOTION_API_KEY") or os.environ.get("NOTION_API_TOKEN")
    if not key:
        print("ERROR: NOTION_API_KEY not in environment", file=sys.stderr); sys.exit(2)
    rel_names = {}
    try:
        schema = api("GET", f"https://api.notion.com/v1/databases/{DB_ID}", key)
        for arg,kw in RELATION_KEYS.items():
            for name,meta in schema["properties"].items():
                if meta["type"]=="relation" and kw in name.lower(): rel_names[arg]=name; break
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode()[:400], file=sys.stderr); sys.exit(1)
    props = {"Content Name": {"title": [{"text": {"content": a.title}}]}}
    for arg,name in TEXTS.items():
        v = getattr(a, arg)
        if v: props[name] = {"rich_text": [{"text": {"content": v}}]}
    for arg,name in SELECTS.items():
        v = getattr(a, arg)
        if v: props[name] = {"select": {"name": v.split("/")[0].split(",")[0].strip()}}
    if a.platform:
        props["Platform"] = {"multi_select": [{"name": p.strip()} for p in a.platform.split(",") if p.strip()]}
    for arg in RELATION_KEYS:
        v = getattr(a, arg); name = rel_names.get(arg)
        if v and name: props[name] = {"relation": [{"id": v}]}
    body = json.dumps({"parent":{"database_id":DB_ID},"properties":props}).encode()
    try:
        d = api("POST", "https://api.notion.com/v1/pages", key, body)
        print("OK id=" + d["id"] + " url=" + (d.get("url") or ""))
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode()[:400], file=sys.stderr); sys.exit(1)
if __name__ == "__main__": main()
MPMEOF

# ── scripts/list_pains.py (stage 1: read ICP & Pain DB -> ground ideas) ──
cat > "$KB/scripts/list_pains.py" <<'MPMEOF'
#!/usr/bin/env python3
"""list_pains.py — read ALL rows of the MPM ICP & Pain Database (Notion).
Stage 1: ground `ideas` in REAL pains. Agent runs this one fixed command and
reads clean text instead of hand-building a Notion query (which Flash fumbles).
Sorted by Content Potential (high first; blank still listed). Each line carries
the row id for save_idea.py --pain-id.  Usage: list_pains.py [--top N]"""
import argparse, json, os, sys, urllib.request, urllib.error
DB_ID = "c5e45bc4-4f13-41c5-a59e-e001a49071c3"  # ICP & Pain Database
NOTION_VERSION = "2022-06-28"
def txt(prop):
    t = prop["type"]
    if t == "title":     return "".join(x["plain_text"] for x in prop["title"])
    if t == "rich_text": return "".join(x["plain_text"] for x in prop["rich_text"])
    if t == "select":    return prop["select"]["name"] if prop["select"] else ""
    if t == "number":    return prop["number"]
    return ""
def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--top", type=int, default=0)
    a = ap.parse_args()
    key = os.environ.get("NOTION_API_KEY") or os.environ.get("NOTION_API_TOKEN")
    if not key:
        print("ERROR: NOTION_API_KEY not in environment", file=sys.stderr); sys.exit(2)
    body = json.dumps({"page_size": 100}).encode()
    req = urllib.request.Request(f"https://api.notion.com/v1/databases/{DB_ID}/query",
        data=body, method="POST",
        headers={"Authorization": f"Bearer {key}", "Notion-Version": NOTION_VERSION,
                 "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r: d = json.load(r)
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode()[:400], file=sys.stderr); sys.exit(1)
    rows = []
    for r in d.get("results", []):
        p = r["properties"]
        rows.append({"id": r["id"],
            "name": txt(p.get("Pain Name", {"type":"title","title":[]})) or "(untitled)",
            "cp": txt(p.get("Content Potential", {"type":"number","number":None})),
            "seg": txt(p.get("ICP Segment", {"type":"select","select":None})),
            "trig": txt(p.get("Emotional Trigger", {"type":"select","select":None})),
            "spot": txt(p.get("Poker Spot", {"type":"select","select":None})),
            "quote": txt(p.get("User Quote", {"type":"rich_text","rich_text":[]}))})
    rows.sort(key=lambda x: (x["cp"] is None, -(x["cp"] or 0)))
    if a.top > 0: rows = rows[:a.top]
    print(f"# {len(rows)} pains from ICP & Pain Database (Content Potential high->low)\n")
    for x in rows:
        cp = x["cp"] if x["cp"] is not None else "-"
        print(f"[id={x['id']}] CP={cp} | {x['name']}")
        meta = " | ".join(f"{k}={v}" for k, v in
            (("seg",x["seg"]),("trigger",x["trig"]),("spot",x["spot"])) if v)
        if meta: print(f"    {meta}")
        if x["quote"]: print(f"    quote: \"{x['quote']}\"")
        print()
if __name__ == "__main__": main()
MPMEOF

# ── scripts/list_hooks.py (read Hook Library -> proven English hooks) ──
cat > "$KB/scripts/list_hooks.py" <<'MPMEOF'
#!/usr/bin/env python3
"""list_hooks.py — read the MPM Hook Library (Notion), proven English hooks.
Agent runs this one fixed command (never hand-builds a Notion query). Sorted by
Performance (high first; blank last). --pain-id filters to hooks linked to that
pain via Related Pain. Each line carries the hook id for save_content --hook-id.
Usage: list_hooks.py [--pain-id <ICP row>] [--top N]"""
import argparse, json, os, sys, urllib.request, urllib.error
DB_ID = "358a5a3f-fec6-80a6-b912-f714680f4622"  # Hook Library
NOTION_VERSION = "2022-06-28"
def txt(prop):
    t = prop["type"]
    if t == "title":        return "".join(x["plain_text"] for x in prop["title"])
    if t == "rich_text":    return "".join(x["plain_text"] for x in prop["rich_text"])
    if t == "select":       return prop["select"]["name"] if prop["select"] else ""
    if t == "multi_select": return "/".join(o["name"] for o in prop["multi_select"])
    if t == "number":       return prop["number"]
    if t == "relation":     return [r["id"] for r in prop["relation"]]
    return ""
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pain-id", dest="pain_id"); ap.add_argument("--top", type=int, default=0)
    a = ap.parse_args()
    key = os.environ.get("NOTION_API_KEY") or os.environ.get("NOTION_API_TOKEN")
    if not key:
        print("ERROR: NOTION_API_KEY not in environment", file=sys.stderr); sys.exit(2)
    body = json.dumps({"page_size": 100}).encode()
    req = urllib.request.Request(f"https://api.notion.com/v1/databases/{DB_ID}/query",
        data=body, method="POST",
        headers={"Authorization": f"Bearer {key}", "Notion-Version": NOTION_VERSION,
                 "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r: d = json.load(r)
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode()[:400], file=sys.stderr); sys.exit(1)
    rows = []
    for r in d.get("results", []):
        p = r["properties"]
        hook = txt(p.get("Hook", {"type":"title","title":[]}))
        if not hook: continue
        rows.append({"id": r["id"], "hook": hook,
            "perf": txt(p.get("Performance", {"type":"number","number":None})),
            "plat": txt(p.get("Platform", {"type":"select","select":None})),
            "type": txt(p.get("Hook Type", {"type":"multi_select","multi_select":[]})),
            "pains": txt(p.get("Related Pain", {"type":"relation","relation":[]}))})
    if a.pain_id:
        pid = a.pain_id.replace("-", "")
        rows = [x for x in rows if any(pid == rid.replace("-", "") for rid in x["pains"])]
    rows.sort(key=lambda x: (x["perf"] is None, -(x["perf"] or 0)))
    if a.top > 0: rows = rows[:a.top]
    scope = f" linked to pain {a.pain_id}" if a.pain_id else ""
    print(f"# {len(rows)} hooks from Hook Library{scope} (Performance high->low)\n")
    for x in rows:
        perf = x["perf"] if x["perf"] is not None else "-"
        tags = " ".join(f"[{t}]" for t in (x["plat"], x["type"]) if t)
        print(f"[id={x['id']}] Perf={perf} {tags}")
        print(f"    {x['hook']}")
        print()
if __name__ == "__main__": main()
MPMEOF

# ── scripts/save_hook.py (add a chosen hook back into the Hook Library) ──
cat > "$KB/scripts/save_hook.py" <<'MPMEOF'
#!/usr/bin/env python3
"""save_hook.py — add one hook to the MPM Hook Library (Notion).
Closes the loop: when the founder likes a hook (agent-suggested or their own),
save it so it becomes a reusable option next time and can gather Performance data.
Links Related Pain so list_hooks --pain-id finds it later. Only --hook required.
Usage: save_hook.py --hook "..." [--pain-id <ICP row>] [--platform X]
       [--type Curiosity,Money Pain] [--performance 0] [--notes "..."] [--reusable true]"""
import argparse, json, os, sys, urllib.request, urllib.error
DB_ID = "358a5a3f-fec6-80a6-b912-f714680f4622"  # Hook Library
NOTION_VERSION = "2022-06-28"
def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--hook", required=True)
    ap.add_argument("--pain-id", dest="pain_id"); ap.add_argument("--platform")
    ap.add_argument("--type"); ap.add_argument("--performance", type=float)
    ap.add_argument("--notes"); ap.add_argument("--reusable", default="true")
    a = ap.parse_args()
    key = os.environ.get("NOTION_API_KEY") or os.environ.get("NOTION_API_TOKEN")
    if not key:
        print("ERROR: NOTION_API_KEY not in environment", file=sys.stderr); sys.exit(2)
    props = {"Hook": {"title": [{"text": {"content": a.hook}}]},
             "Reusable": {"checkbox": str(a.reusable).strip().lower() in ("true","1","yes","y")}}
    if a.platform: props["Platform"] = {"select": {"name": a.platform.split("/")[0].split(",")[0].strip()}}
    if a.type: props["Hook Type"] = {"multi_select": [{"name": t.strip()} for t in a.type.split(",") if t.strip()]}
    if a.performance is not None: props["Performance"] = {"number": a.performance}
    if a.notes: props["Notes"] = {"rich_text": [{"text": {"content": a.notes}}]}
    if a.pain_id: props["Related Pain"] = {"relation": [{"id": a.pain_id}]}
    body = json.dumps({"parent":{"database_id":DB_ID},"properties":props}).encode()
    req = urllib.request.Request("https://api.notion.com/v1/pages", data=body, method="POST",
        headers={"Authorization":f"Bearer {key}","Notion-Version":NOTION_VERSION,"Content-Type":"application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r: d = json.load(r)
        print("OK id=" + d["id"] + " url=" + (d.get("url") or ""))
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode()[:400], file=sys.stderr); sys.exit(1)
if __name__ == "__main__": main()
MPMEOF

# ── KB seeds (don't overwrite existing) ───────────────────────────────
[ -f "$KB/insights/insights.md" ] || cat > "$KB/insights/insights.md" <<'MPMEOF'
# MicroPokerMaster — Player Insight Bank
Labels: why-they-use · pain · objection · request · market.

<!-- capture appends below -->
MPMEOF

[ -f "$KB/content/README.md" ] || cat > "$KB/content/README.md" <<'MPMEOF'
# MicroPokerMaster — Content
write saves posts here. Name: YYYY-MM-DD-topic.md. Each file: 3 versions X / Short-form / Reddit + draft/posted status. Don't fabricate numbers.
MPMEOF

[ -f "$KB/landing-page/notes.md" ] || cat > "$KB/landing-page/notes.md" <<'MPMEOF'
# MicroPokerMaster — Landing-page suggestions
weekly logs concrete suggestions here, each born from a real player insight.

<!-- weekly appends below -->
MPMEOF

# Ensure gateway (hermes, UID 10000) can read/write brain + KB
chown -R 10000:10000 "$KB" "$DATA/SOUL.md" "$DATA/config.yaml" 2>/dev/null || true

echo "Done. Tree:"
find "$DATA" -maxdepth 3 \( -name '*.md' -o -name 'config.yaml' \) | sort
echo "Restart the gateway (Railway: Deployments -> Restart), then /new on Telegram."
