# Learning Library Demo Script

Use this as a 2-3 minute narrated screen recording. It demonstrates the required Book Manager behaviors. Do not record setup or menu fallback messages.

## Before recording

1. Run `./scripts/setup.sh --install` once. Confirm that Gum is available.
2. Use a large terminal window with readable text.
3. Have a clear, front-facing cover photo for a title not already in the library ready to drag into the terminal.
4. Run `./app.sh`. Start the screen recording when the flip-book welcome animation appears; the open-book mark remains visible above the main-menu choices.

## Scene 1 — Introduction and browse (0:00-0:20)

**Action:** Choose **Browse Learning Library**.

**Narration:**

> This is Learning Library, my personal Bash application for deciding what to read, listen to, or watch next. It combines Kindle and Audible titles with physical books, climbing guidebooks, and video content. The library is organized around my interests in AI, entrepreneurship, operations, mental health, career development, climbing, physiology, and economics.

**What this proves:** Gum UI, persistent library, mixed content types, personalization.

## Scene 2 — Search the saved library (0:20-0:35)

**Action:** Choose **Search Library** and search for `career`.

**Narration:**

> I can search my saved content across formats. Here are career-related titles, including product-management and coding books. The search component receives my request and asks the data layer for matching records; the rest of the app does not read the CSV directly.

**What this proves:** Search workflow, Book component, data-layer boundary.

## Scene 3 — Import a book from a photo (0:35-0:55)

**Action:** Choose **Import Book from Photo (Bonus)**. Drag the prepared cover image into the prompt, then accept or correct Codex’s title and creator suggestions. Select the remaining metadata and save it.

**Narration:**

> I can also add a physical book from a cover photo. I drag the image into the terminal, and Codex vision proposes the title, creator, and topic. I confirm or correct those details before the item is saved, so the AI speeds up entry without taking control away from me.

**What this proves:** Optional Codex vision feature, image-drop input, human confirmation, metadata workflow, write through the data layer.

## Scene 4 — Saved-first Concierge recommendation (0:55-1:25)

**Action:** Choose **Ask Learning Concierge**. Enter:

```text
I need PM career advice in a medium-energy book.
```

**Narration:**

> The Learning Concierge accepts one natural-language request and extracts my available energy, preferred format, and time from it. It starts three recommendation agents in parallel: one considers my history, one matches my interests, and one looks for discovery options. The status line shows that work is happening while the agents run.

> Because I already own relevant books, it gives me a “Start from your library” shortlist, including my PM-career and PM-interview books.

**What this proves:** Natural-language input, personalization, parallelization, `$!`, `wait`, streaming/progress, saved-first matching.

## Scene 5 — New video discovery (1:25-1:55)

**Action:** Choose **Ask Learning Concierge** again. Enter:

```text
I have about 25 minutes and want a low-energy climbing video.
```

**Narration:**

> This time I do not have a saved climbing video, so the Discovery Agent adds adjacent topics—physiology and mental health—rather than simply finding another climbing video. It returns a short stretch recommendation from my curated discovery catalog and explains the connection.

> The three agents’ outputs are combined and passed through a refinement pipeline. Refinement removes duplicates, completed items, and anything already in my library, leaving only genuinely new content in this “Explore something new” section.

**What this proves:** Video-content support, discovery behavior, a meaningful Bash pipe, refinement, clean final shortlist.

## Scene 6 — Architecture close (1:55-2:10)

**Action:** Return to the main menu, or briefly show the project folder tree in a second terminal if desired.

**Narration:**

> The architecture is intentionally small and visible: UI to workflows to recommendation and book components to the data layer and CSV storage. Each Bash file has one clear responsibility, and the recommendation workflow demonstrates small programs, parallelization, streaming, and composition.

## Recording checklist

- [ ] Gum menu is visible; do not use the plain-shell fallback in the recording.
- [ ] Show Scenes 1-6.
- [ ] Use an unowned title for the photo import.
- [ ] Keep the terminal text readable and narration concise.
- [ ] Do not show installation, debugging, passwords, or paths containing personal information.
- [ ] Save the video in the repository or upload it elsewhere and add a clearly visible link to `README.md`.
