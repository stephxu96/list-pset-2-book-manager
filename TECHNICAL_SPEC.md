# Learning Library Technical Specification

## Purpose

Learning Library is a small Bash and Gum terminal application that helps its owner decide what to read, listen to, or watch next. It searches the personal library first and uses a curated discovery catalog only when no strong saved match exists.

## Content model

Each record uses these fields:

```text
id,title,creator,content_type,provider,provider_format,topic,location,discipline,duration_or_pages,energy,status,reason_saved,link
```

Content types are `text`, `audio`, `video`, and `guidebook`. Providers include Amazon, YouTube, Netflix, Physical, GunksApp, and Other. Amazon is the provider, while Kindle and Audible are its formats.

Topics are AI/ML, entrepreneurship, operations/processes, mental health, career, climbing, physiology/health, economics, fiction, and other. Climbing items may add a location and discipline.

## Architecture

```text
Gum UI -> workflows -> book/recommendation components -> data layer -> CSV storage
```

`data/book_database.sh` is the only script permitted to access `data/books.csv`. All other scripts use its command interface.

## Learning Concierge

The Concierge collects a free-text question, energy level, preferred format, and optional available minutes. A saved item is a strong match if it satisfies at least two applicable conditions: topic, content format, energy, duration, or learning goal. Saved matches are displayed first; otherwise the discovery catalog is searched. The main menu also exposes a dedicated Video Library view for saved YouTube and Netflix records.

## Bonus: photo import

`books/import_book_photo.sh` is an optional Bash OCR component powered by Tesseract. The user drags a cover photo into the terminal, the component returns probable title and creator text, and the workflow requires human confirmation before adding the book through `book_database.sh`. Tesseract is optional and installed with `./scripts/setup.sh --install-ocr`.

## Recommendation workflow

`workflows/get_recommendations.sh` launches the history, interests, and discovery agents concurrently using `&`, stores their process IDs with `$!`, displays progress, and synchronizes with `wait`. Their combined candidates pass through:

```text
cat agent-results | recommendations/refine_recommendations.sh
```

The required refinement component removes duplicates, completed content, and every item already present in the personal library; it limits the new-content shortlist to five items. Saved-library matches are displayed separately as the Concierge's “Start from your library” lane. It does not make subjective ranking decisions.

## Scope

Version 1 is intentionally offline and deterministic: simple keyword matching plus a curated catalog. Live web research, provider scraping, graphical chat, user accounts, and cloud sync are out of scope.

## Success criteria

- The user can add, browse, and search mixed content.
- The Concierge recommends a suitable saved item when one exists.
- The app falls back to a discovery item when none exists.
- All three recommendation programs run concurrently with visible progress.
- The code remains small enough to explain file by file.
