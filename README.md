# Learning Library

Learning Library is a personal Bash command-line application for deciding what to learn, read, listen to, or watch next. It manages books, Audible titles, Kindle books, videos, physical guidebooks, and Gunks App climbing guides across interests including AI/ML, entrepreneurship, operations, mental health, product management, climbing, physiology, and economics. A dedicated Video Library menu section keeps YouTube and Netflix content distinct from reading and listening material.

## Narrated demo

**[Watch or download the demo — 2 minutes 10 seconds](book%20manager%20demo.mp4)** · [Direct video file](https://github.com/stephxu96/list-pset-2-book-manager/raw/refs/heads/main/book%20manager%20demo.mp4)

The video includes narration and subtitles. It demonstrates browsing the library, adding *Free Solo*, finding it in the dedicated video view, searching for career titles, requesting live recommendations, and importing two books from a dragged-and-dropped iPhone photo.

## Setup and run

Prerequisites: Bash, Gum, `jq`, and an installed, signed-in Codex CLI. Recommendations and photo recognition need network access and use your Codex account. macOS is the demonstrated environment; HEIC conversion requires macOS `sips`. Use PNG or JPEG on other systems.

```bash
git clone https://github.com/stephxu96/list-pset-2-book-manager.git
cd list-pset-2-book-manager
```

From the project folder, validate dependencies first. Add `--install` to install Gum through Homebrew or apt-get when available:

```bash
./scripts/setup.sh
# or: ./scripts/setup.sh --install
./app.sh
```

The setup script installs **Gum only**, not Codex or `jq`. On macOS with Homebrew, `brew install gum jq` installs those two dependencies. Setup checks installed commands, Bash syntax, and CSV structure; it does not verify Codex authentication or network access.

Gum is the required, intended interface and is used in the demo. The basic shell-menu fallback is for development diagnostics only. The Learning Concierge uses three concurrent, live Codex CLI agents (history, saved-library matching, and adjacent-topic discovery). Photo import also uses Codex CLI for vision analysis.

## Test

Run the deterministic component tests without calling Codex or modifying your library:

```bash
./tests/run_tests.sh
```

The 11 tests use a mocked Codex response. They cover argument/piped search, terminal input cleanup, metadata formatting, model ID validation, dragged photo paths, refinement, multiple-book response parsing, CSV append behavior, and data integrity. They do not replace live-model or full interactive testing. See [the assignment requirements review](REQUIREMENTS_CHECK.md).

## Architecture

The app follows a visible UI -> workflow -> component -> data-layer -> storage structure. `app.sh` only routes top-level choices. UI scripts handle prompts and presentation; workflow scripts coordinate operations; book and recommendation scripts perform small focused tasks; and `data/book_database.sh` is the only runtime component that reads or writes `data/books.csv` (setup/tests also inspect it for validation). For each request, the workflow reads the current library and sends it with the natural-language question to three concurrent Codex agents using Bash `&`, `$!`, and `wait`. It validates model-selected IDs against the supplied catalog, combines the results, and pipes them through refinement. Saved matches are displayed separately so the new-content filter does not discard them from the interface. Energy, format, and time are interpreted by the live model, not fixed keyword rules.

## Personalization

This library reflects a learning life that combines AI/ML, entrepreneurship, operations, mental health, career development, climbing, physical therapy, and economics. It treats Amazon as a provider with Kindle and Audible subformats, and supports physical guidebooks and Gunks App references alongside YouTube and Netflix video. Records also capture status, why an item was saved, and energy level. The Learning Concierge presents matching saved items under “Start from your library,” then its Discovery Agent deliberately considers one or two adjacent topics for an “Explore something new” stretch pick. Refinement removes duplicate, completed, and already-saved items, polishes explanation whitespace, and caps the new-content shortlist at five.

## Bonus: import a book from a photo

Choose **Import Book from Photo (Bonus)**, then drag a clear photo containing one or more book covers or spines into the prompted terminal field. PNG, JPEG, and iPhone HEIC images are supported; HEIC is converted locally to a temporary PNG before analysis. Codex vision lists every legible title, creator, and topic, then you confirm one batch import. Existing titles are skipped automatically. This makes the feature more capable than plain OCR without repetitive per-book forms.

See [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) for the complete implementation specification.

## Scope and data handling

- Discovery selects from a curated local catalog; it does **not** research the open web or verify streaming availability. Live model choices may vary.
- Manual-entry metadata enrichment normalizes supplied fields and provider/format relationships; it does not fetch publication details online.
- The library is a simple single-user CSV. Commas in entered fields are sanitized. There is no edit/delete/rating menu, cloud sync, or automatic saving of recommendations. A status-update command exists in the data layer.
- Recommendation requests send the question and catalog context to Codex. Photo import sends the selected image (a temporary PNG for HEIC) to Codex vision. Review recognition results before confirming.
- The repository includes the demonstrated library and video. Changes to local CSV files are not automatically published to GitHub.

See [DEMO_SCRIPT.md](DEMO_SCRIPT.md) for reproducible demo instructions. Publishing the repository does not complete the separate class sign-up spreadsheet submission.
