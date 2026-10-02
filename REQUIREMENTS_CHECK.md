# Problem Set 2 requirements review

Reviewed October 2, 2026 against the eight-page original `ps02.pdf` assignment, the implementation, and the final narrated demo. The assignment does not provide a numerical point rubric; this is a requirement/evidence check, not a predicted grade. Examples introduced as possible responsibilities are distinguished from mandatory structure and deliverables.

| Assignment requirement | Implementation evidence | Assessment |
| --- | --- | --- |
| Small Bash programs with visible layered architecture | `app.sh`, `ui/`, `workflows/`, `books/`, `recommendations/`, `data/` | Present. UI library rendering uses the data API directly for browsing; storage access remains isolated. |
| Required entry point, screens, workflows, components, and storage files | All 14 named assignment files are present; list below | Covered. Additional helpers support personalized features. |
| Gum menus and prompts; small routing entry point | `ui/main_menu.sh`, screen scripts, `app.sh` | Covered. Gum is used in the recording; fallback is development-only. |
| Add, browse, and search a personal library | `workflows/manage_library.sh`, `ui/library_screen.sh` | Covered and shown in the demo. |
| Metadata enrichment component | `books/fetch_book_metadata.sh` | Basic implementation: fills provider format such as Amazon → Audible/Kindle and normalizes fields. It does not perform an external title/author metadata lookup. Photo import adds live vision-derived title/creator/topic metadata. |
| Search accepts command-line or piped input | `books/search_books.sh` | Covered by tests for both interfaces. |
| Independent history, interests, and discovery strategies | Three named wrappers and `recommendations/run_live_recommender.sh` | Covered with distinct live-model instructions. History may return no candidates when completed history is unavailable. |
| Intentional discovery beyond normal interests | Discovery wrapper and prompt | Requests one or two adjacent-topic suggestions from the curated catalog. Model-directed selection, not open-web research. |
| Concurrent execution, PID tracking, synchronization, visible progress | `workflows/get_recommendations.sh`: `&`, `$!`, `wait`, progress display | Covered; progress appears in the demo. |
| Combine results and pipe through refinement | Workflow pipeline into `recommendations/refine_recommendations.sh` | Covered. Saved-library matches have a separate display lane. |
| Refine: remove duplicates and owned items, reduce and polish or rank | `recommendations/refine_recommendations.sh` | Deduplicates title/format, excludes owned titles and completed statuses, caps at five, and polishes explanation whitespace. Preserves upstream order; no separate ranking algorithm. |
| Encapsulated CSV access | `data/book_database.sh` | Only runtime storage component accessing `books.csv`; setup/tests read files for validation. |
| Deliberate personalization | Mixed formats, provider/subformat, interests, saved reason, energy, climbing guides, video view | Covered; README explains the choices. |
| Complete source and README with run instructions, architecture, personalization | Repository and `README.md` | Included, with dependencies, limitations, and data-handling notes. |
| Short narrated terminal demo in repo or prominently linked | `book manager demo.mp4`, linked near top of README | Included: 130.167 seconds, 1920×1080, video/audio/subtitle tracks. Demonstrates several operations plus photo import. |
| Public repository in student's account | `stephxu96/list-pset-2-book-manager` | Public repository confirmed during review. |
| Enter repository URL in class sign-up spreadsheet | External submission step | Student must complete this; publishing the repository does not submit the spreadsheet entry. |

## Required file checklist

```text
app.sh
ui/main_menu.sh
ui/library_screen.sh
ui/recommendations_screen.sh
workflows/manage_library.sh
workflows/get_recommendations.sh
books/fetch_book_metadata.sh
books/search_books.sh
recommendations/recommend_from_history.sh
recommendations/recommend_from_interests.sh
recommendations/recommend_for_discovery.sh
recommendations/refine_recommendations.sh
data/book_database.sh
data/books.csv
```

## Verification and review changes

- Setup validation passes with Gum, Codex CLI, and jq present.
- All 11 deterministic component tests pass. Live-model selection is mocked in these tests; the recorded demo is evidence of an interactive run, not a guarantee of identical future model output.
- Bash syntax and whitespace checks pass.
- Removed a stale test that prohibited a legitimate book imported during the demo. The user's library entries were preserved.
- Fixed the test runner so an early failed assertion cannot be hidden by a later successful assertion.
- Added refinement checks for whitespace polishing, the five-item limit, completed records, and an input line without a trailing newline.
- Updated the spec and README to describe live model dependencies and curated discovery accurately; removed the obsolete offline/deterministic description.

## Boundaries, not claimed features

The assignment's possible-responsibility examples are not all exposed as menus. The app has no UI for editing/deleting entries, ratings, or saving recommendations; the data API does support status updates. Manual-entry enrichment is minimal and would need a lookup service for richer bibliographic details. Recommendation quality and vision accuracy depend on the live model. Simple CSV storage is intended for one local user, not concurrent writers. HEIC conversion is macOS-specific.

The main required structure and workflows are present. Metadata enrichment depth and simple formatting-only refinement polish are the areas to describe conservatively rather than claiming a richer lookup or ranking system.
