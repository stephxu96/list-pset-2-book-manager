# Learning Library — Full Demo Walkthrough

This is the end-to-end demo checklist and narration for the main-menu features: browse, add, video library, photo import, search, recommendations, and quit. Allow about 5–7 minutes; the live recommendation run may take a little longer while Codex responds.

## Before recording

1. Make sure Gum, `jq`, and the Codex CLI are installed. Sign in to Codex and confirm `codex` works. `./scripts/setup.sh` checks prerequisites; use `./scripts/setup.sh --install` only if Gum still needs installing.
2. Run `./tests/run_tests.sh` once. The app’s live recommendations need connectivity and a signed-in Codex CLI.
3. For a safe demo, record from a disposable copy of the project so Add and photo import cannot change the library in the actual repo:

   ```bash
   DEMO_ROOT="$(mktemp -d /tmp/learning-library-demo.XXXXXX)"
   cp -R "$PWD"/. "$DEMO_ROOT"/
   cd "$DEMO_ROOT"
   ./app.sh
   ```

   The copy includes current project files and data. Any demo-only entries or photo imports stay in that temporary copy. Do not add fake/test records to the real project data.
4. Enlarge the terminal, use a clear photo of books you actually want in the demo library, and start recording just before launch. Review the photo’s detected titles; cancel if any are wrong.

The app returns to the main menu after each feature. At each “press Enter” pause, press Enter and choose the next menu option. The book banner remains visible above the menu.

## Run of show and narration

### 1. Launch and browse the full library

**Action:** Start `./app.sh`, then choose **Browse Learning Library**. Pause on the full table and return to the menu.

**Narration:**

> Learning Library is a Bash command-line app for deciding what to read, listen to, or watch next. My library combines Kindle and Audible titles, physical books, climbing guidebooks, and video. Amazon is the provider, with Kindle and Audible as its formats. The other content types have their own providers and details.

**Shows:** Launch animation/banner, Gum main menu, saved library across content types, and return-to-menu flow.

### 2. Add Free Solo as a climbing video

**Action:** Choose **Add Book, Audio, Video, or Guidebook** and enter:

```text
Title: Free Solo
Creator: Alex Honnold
Content type: video
Provider: YouTube
Topic: climbing
Status: want_to_watch
Why save it?: curiosity
Energy: low
```

Show the saved confirmation and return to the menu. Add it only if it is not already present in the demo library.

**Narration:**

> I can add books, audiobooks, videos, and guidebooks. Here I’m adding Free Solo as a YouTube climbing video. The app records its creator, topic, status, reason, and energy in the library.

**Shows:** Add workflow, video provider choice, metadata capture, and persistence. In the disposable demo copy this entry stays only until that copy is discarded.

**Content-type choices in Add:**

| Type | Provider choices | Status choices |
|---|---|---|
| Text | Amazon, Physical, Other | want to read, reading, finished |
| Audio | Amazon, Other | want to listen, listening, listened |
| Video | YouTube, Netflix, Other | want to watch, watching, watched |
| Guidebook | Physical, GunksApp, Other | want to read, reading, finished |

### 3. Browse videos and show Free Solo

**Action:** Choose **Browse Video Library**. Point out Free Solo in the video-only list, then return.

**Narration:**

> The Video Library filters out books and guidebooks. Free Solo is now visible here with the other saved YouTube and Netflix content.

**Shows:** Video filter, distinct menu option, and the item added in the previous step.

### 4. Search across the library

**Action:** Choose **Search Library**, enter `career`, show the results (including the PM-career/interview material), then return.

**Narration:**

> Search looks across the saved library—not just one format—so I can find career material whether it is a book, audiobook, guide, or video.

**Shows:** Search input, search component, and display of matching records.

### 5. Ask for a recommendation from saved items

**Action:** Choose **Ask Learning Concierge** and enter:

```text
I need PM career advice.
```

Wait for the live agents to finish. Show the “Start from your library” lane, then return.

**Narration:**

> I ask in plain language, without filling out a second form. Three live Codex agents run in parallel: one uses my completed history, one finds matches in my saved library, and one explores adjacent topics. They make the first relevance judgment. Here the saved list contains PM-career and interview resources, so those come first. Notice that the app does not assume an energy level, format, or time limit that I never mentioned.

**Shows:** Natural-language request, live model decisions, parallel agents/progress, saved-library matching, no repeated constraint selections, and candidate explanations.

### 6. Import one or more books from a dropped image (bonus)

**Action:** Choose **Import Book from Photo (Bonus)**. Drag the prepared image directly into the terminal prompt and press Enter. Review the complete candidate list. Choose **Cancel** if a title/author is wrong; otherwise choose **Import all detected books**, select the shared status/reason/energy, and show the import/duplicate-skip messages. Return to the menu.

**Narration:**

> I can also drop in one photo containing multiple book covers or spines. The path is normalized even when Terminal escapes characters in it. Codex vision identifies each legible book, and I review the whole list before confirming a batch import. HEIC photos are converted locally for analysis. Existing titles are skipped instead of duplicated.

**Shows:** Drag-and-drop path parsing, multiple books per image, Codex vision, human confirmation/cancel, shared metadata, duplicate protection, and writes through the data layer. Never confirm an incorrect title just to advance the demo.

### 7. Quit and close on the architecture

**Action:** Return to the menu, choose **Quit**, and finish on the terminal.

**Narration:**

> The flow stays small and inspectable: Gum handles the interface, Bash workflows coordinate components, the database script owns CSV access, and the live recommendation agents make the subjective matches. The test suite checks core behavior without calling the live model or changing my library.

**Shows:** Clean exit and a concise architecture summary.

## Coverage checklist

- [ ] Launch animation and persistent main-menu book banner
- [ ] Browse Learning Library
- [ ] Browse Video Library
- [ ] Add an item and show its metadata/provider choices
- [ ] Search saved content
- [ ] Concierge saved-library recommendation
- [ ] Add Free Solo as a video, then show it in Browse Video Library
- [ ] Import from a drag-dropped image, including multi-book review and cancel/confirm
- [ ] Return to menu between flows and Quit
- [ ] No test entries left in the actual project data; no inaccurate photo detections imported
