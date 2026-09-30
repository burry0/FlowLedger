# Changelog

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
