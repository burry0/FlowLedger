# FlowLedger user guide

This guide walks through a typical month with FlowLedger. Screen names are shown as they appear in the English interface.

## 1. Clients and default categories

1. Open **Clients → Add client** and enter a name.
2. Open the client. Under **Default categories**, add the services you usually sell to this client, each with a price. You can also add **work stages** (for example *Rough cut → Colour → Sound*) that are copied as a checklist into every work item created from that category.

Default categories are templates. When a period opens, their names and prices are copied into the period, so changing a price later never changes past work.

## 2. The active period

Every client always has exactly one **active period**. The client page shows:

- the period start date, total and received amounts,
- a summary strip: **Receivable**, work **In Progress**, **Open revisions** and items **Awaiting feedback**,
- buttons to export the period as TXT or XLSX and to record payments.

## 3. Adding work

- Click a **category button** to add work at the period's fixed price.
- Or use **+ One-off work** for anything without a category (you enter the title, price and quantity).
- New work starts as **In Progress**. Tick its stages as you go and use **Mark as Completed** when it is done. Only completed work counts towards the receivable amount.

To change a work item, expand it and choose **Edit**: you can change the title, the quantity, the **multiplier** (×1, ×1.25, ×1.5, ×2, ×3 — for rush or extra-effort jobs) and the notes. The dialog shows `price × quantity × multiplier = total` while you type.

## 4. Revisions and feedback

Each work item is a deliverable. Expand it and click **Revisions**.

- **New Version** adds V1, V2, … (you can rename it, for example *Final*). Add what changed and a file path or link.
- Set the version status: **Draft**, **Sent** (you delivered it) or **Approved**.
- **Add Feedback** records what the client asked for. Choose **Revision** (a change to the current work) or **New Scope** (something new, for example "also make a 9:16 version"). For videos, add a timecode such as `00:43`.
- Click the circle next to a feedback item to mark it **Resolved**; use its menu for **Won't do**, **Reopen**, **Edit** or **Delete**.
- The work card on the client page shows a one-line summary such as `V3 · Changes requested · 2 open revisions`.

Revisions work on closed periods too, and they never change amounts, payments or the work status.

The **History** panel (on the right, or in a tab on small windows) shows versions, feedback, completed stages and completion in time order. It is built from your records, so when a status changes several times only the latest time is shown.

## 5. Getting paid

- **Record Partial Payment** records money received while the period stays open.
- **Record Payment** records the final payment and **closes the period**. A new active period starts automatically with the current default categories. Work that is still in progress must be completed or deleted first.

Closed periods are listed under **Past Periods** on the client page and in **Periods**. They are read-only, except for revisions.

## 6. Reports

On the client page, **Export TXT** and **Export XLSX** save a report of the active period in your current language and currency: summary, work items (with quantity and multiplier) and payments.

## 7. Backup and restore

**Settings → Backup**

- **Create backup** saves all data to a single `.db` file. Do this regularly and keep a copy outside your computer.
- **Restore from backup** replaces all current data with a backup. FlowLedger first checks the file, shows how many clients and work items it contains, and saves your current data to a safety copy before replacing anything.

## 8. Language and currency

**Settings → Language** switches between English, Türkçe, Deutsch and Русский.
**Settings → Currency** changes the currency symbol and format. Amounts are not converted.
