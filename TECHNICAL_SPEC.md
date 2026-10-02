# Learning Library Technical Specification

## Purpose

Learning Library is a small Bash and Gum terminal application that helps its owner decide what to read, listen to, or watch next. It prioritizes saved-library matches in the display and offers adjacent-topic suggestions from a curated discovery catalog in a separate lane. Both are evaluated concurrently.

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

`data/book_database.sh` is the only runtime component permitted to access `data/books.csv`. Application callers use its command interface; setup and test scripts also inspect the CSV for validation.

## Learning Concierge

The Concierge collects a single free-text question. The live agents interpret any stated energy, format, duration, goal, or topic constraints and do not require repetitive follow-up selections. Saved matches are displayed first; adjacent-topic discoveries are drawn from the discovery catalog. The main menu also exposes a dedicated Video Library view for saved YouTube and Netflix records.

## Bonus: photo import

`books/import_book_photo.sh` is an optional Codex-vision component launched from Bash. The user drags a photo containing one or more book covers or spines into the terminal, Codex returns structured title, creator, and topic candidates for every legible book, and the workflow displays the complete list before one batch confirmation adds the new books through `book_database.sh`. PNG, JPEG, and HEIC inputs are supported; HEIC is converted locally to a temporary PNG before analysis. The selected image is sent to Codex for analysis.

## Recommendation workflow

`workflows/get_recommendations.sh` sends the natural-language prompt and library/catalog context to three independent live Codex CLI agents (history, interests, adjacent-topic discovery), launches them concurrently using `&`, stores their process IDs with `$!`, displays progress, and synchronizes with `wait`. The model makes first-stab relevance and constraint decisions; the application does not infer energy, format, or time with hard-coded keyword rules. Every model-selected ID is validated against the supplied catalog before display. Their combined candidates pass through:

```text
cat agent-results | recommendations/refine_recommendations.sh
```

The required refinement component removes duplicates, completed content, and every item already present in the personal library; it polishes explanation whitespace and limits the new-content shortlist to five items. It preserves agent order rather than implementing a separate relevance-ranking model. Saved-library matches are displayed separately as the Concierge's “Start from your library” lane. Subjective matching and the adjacent-topic choices are made by the live agents, not deterministic keyword scoring.

## Scope

Version 1 stores the library locally, but recommendations and photo analysis require a signed-in Codex CLI and network access. Discovery uses live model selection from a curated catalog, not open-web research. Provider scraping, graphical chat, user accounts, and cloud sync are out of scope. Manual-entry metadata enrichment normalizes provider/format relationships. HEIC conversion requires macOS `sips`; other systems can use PNG or JPEG.

## Success criteria

- The user can add, browse, and search mixed content.
- The Concierge recommends a suitable saved item when one exists.
- The app offers adjacent-topic discovery alongside saved matches, or on its own when no saved match is selected.
- All three recommendation programs run concurrently with visible progress.
- The code remains small enough to explain file by file.
