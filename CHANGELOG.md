# Changelog

## 1.2.0

### Added
- **Drafts billed in parts:** when adding one-off work or editing any work item, switch on *Draft — the rest comes later* and choose with a slider how much of the full price is billed now (5–95 %, default 50 %).
- **Drafts to complete:** the client page lists drafts from any period whose rest is not billed yet. *Complete* adds the rest to the active period as completed work, at the draft's own price, quantity and multiplier.
- Drafts and completions are labelled (*Draft 50 %*, *Completion 50 %*) on the client page, in closed periods and in TXT/XLSX reports.

### Changed
- Database schema version 7 (adds draft columns to work items). The usual automatic copy is written before upgrading; existing work is billed in full as before.

## 1.1.0

### Added
- **Partial payment by work:** *Record Partial Payment* now offers **Enter amount** or **Select work**. Selecting work uses the total of the ticked items as the amount and marks those items as paid.
- Paid work shows **Paid** with the payment date on the client page and in closed periods; each payment lists the work it covers.
- A reminder when editing or deleting work that is marked as paid (the recorded payment does not change).

### Changed
- Database schema version 6 (adds payment–work links). The usual automatic copy is written before upgrading; balances are calculated as before.

## 1.0.0 — first public release

### Added
- **Revisions:** versions (Draft / Sent / Approved) with notes and a file or link for every work item; client feedback as *Revision* or *New scope* with optional timecodes; open / resolved / won't do / reopen; a derived history timeline. Works on closed periods and never changes amounts or payments.
- **Backup and restore** from Settings, with validation and an automatic safety copy before restoring.
- **Languages:** German and Russian, in addition to English and Turkish.
- **Currency setting:** ₺, $, €, £, ₽, CHF (display only).
- **Work item editing:** editable title, quantity typed directly, and a multiplier (×1–×3). Reports include the multiplier.
- Automatic database copy before every schema upgrade.

### Changed
- New app icon (flat "calm bolt" F), used in the app, the Windows executable and the taskbar.
- New calmer visual style ("Calm Ledger"): neutral colours, one accent colour, a summary strip and grouped work list on the client page.
- Reports use the app's language and currency and are titled FlowLedger.
- Data folder moved to `%APPDATA%\com.burry.flowledger\FlowLedger`; data from 0.1 is copied there automatically on first start (the old files are kept).
- Licensed under GPL-3.0.

### Fixed
- Deleting a work item from the client page reported "could not be deleted" although it was deleted.

## 0.1.0

- Initial private version: clients, default categories, billing periods, work items with stages, payments, TXT/XLSX export, Turkish and English.
