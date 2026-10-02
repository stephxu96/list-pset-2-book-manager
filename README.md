# Learning Library

Learning Library is a personal Bash command-line application for deciding what to learn, read, listen to, or watch next. It manages books, Audible titles, Kindle books, videos, physical guidebooks, and Gunks App climbing guides across interests including AI/ML, entrepreneurship, operations, mental health, product management, climbing, physiology, and economics. A dedicated Video Library menu section keeps YouTube and Netflix content distinct from reading and listening material.

## Run it

From the project folder, validate dependencies first. Add `--install` to install Gum through Homebrew or apt-get when available:

```bash
./scripts/setup.sh
# or: ./scripts/setup.sh --install
./app.sh
```

Gum is the required, intended interface. The application has a basic shell-menu fallback only so developers can diagnose the project before installing dependencies. The optional photo-import bonus uses the locally authenticated Codex CLI and `jq`; it sends the selected cover image to Codex vision for analysis.

## Architecture

The app follows a visible UI -> workflow -> component -> data-layer -> storage structure. `app.sh` only routes top-level choices. UI scripts handle prompts and presentation; workflow scripts coordinate operations; book and recommendation scripts perform small focused tasks; and `data/book_database.sh` is the only component that reads or writes `data/books.csv`. The recommendation workflow launches three independent agents concurrently, combines their results, and pipes them through the required cleanup component before displaying the shortlist.

## Personalization

This library reflects a learning life that combines AI/ML, entrepreneurship, operations, mental health, career development, climbing, physical therapy, and economics. It treats Amazon as a provider with Kindle and Audible subformats, and supports physical guidebooks and Gunks App references alongside YouTube and Netflix video. The Learning Concierge presents matching saved items under “Start from your library,” then its Discovery Agent deliberately adds one or two adjacent topics for an “Explore something new” stretch pick. The required refinement step removes duplicate, completed, and already-saved items from that new-content shortlist.

## Bonus: import a book from a photo

Choose **Import Book from Photo (Bonus)**, then drag a clear photo containing one or more book covers or spines into the prompted terminal field. PNG, JPEG, and iPhone HEIC images are supported; HEIC is converted locally to a temporary PNG before analysis. Codex vision lists every legible title, creator, and topic, then you confirm one batch import. Existing titles are skipped automatically. This makes the feature more capable than plain OCR without repetitive per-book forms.

See [TECHNICAL_SPEC.md](TECHNICAL_SPEC.md) for the complete implementation specification.

## Demo

Use [DEMO_SCRIPT.md](DEMO_SCRIPT.md) to record the short narrated terminal demo required for submission. Add the finished video to this repository or replace this paragraph with a clearly visible link before submitting.
