# Parchment Reader

Parchment Reader is an in-game library for World of Warcraft. Save stories,
notes, roleplay material, and other long-form text, then read it in a focused,
resizable window.

## Features

- Create, edit, and organize saved books and notes.
- Rename books while keeping their bookmarks and reading positions.
- Switch between Library, Favorites, and the 20 most recently opened books.
- Search titles and collections by default, or enable the compact **Aa** scope
  to find a complete phrase in book content within the active collection.
- Open a content result with Enter or a click, highlight the matching phrase,
  move between occurrences, and return without replacing saved reading progress.
- Read continuously with automatic position saving.
- Group books into collections.
- Add, rename, navigate, delete, and restore bookmarks.
- Read clearer bookmark titles and excerpts with separate progress percentages,
  longer wrapped excerpts on hover, and a theme-colored rename pencil.
- Capture text quickly without leaving the game through Quick Note.
- Resume the last saved Quick Note in its current collection, or start a new
  note without losing an unsaved draft.
- Use Compact Mode or minimize the reader to a movable floating icon.
- Assign a shortcut that switches a visible Reader into or out of Compact Mode.
- Keep the Reader or minimized launcher in its saved screen position between
  sessions, and pin the Reader to prevent accidental movement or resizing.
- Enable keyboard navigation only when the book page has focus, leaving
  gameplay keys available to WoW at other times.
- Configure reader size, font, transparency, shortcuts, and minimap access, with
  an optional transparent background override while in combat.
- Choose Off, Always, Smart, or Custom reader transparency. Custom reveals a
  live 0–100% slider and a Transparent until hovered checkbox. Text keeps its
  opacity; at high transparency in a light theme, use Azeroth Glass or enable
  Transparent until hovered to keep reading comfortable.
- Choose Azeroth Glass, Light Parchment, or Warm Parchment, and assign the
  sun/moon theme switch independently. Themes update open windows immediately.
- Find settings in Reading, Appearance, Controls, and General, with a live font
  sample and theme previews.
- Choose the interface language independently of the WoW client: English,
  German, French, Russian, Spanish, or Brazilian Portuguese.

## Supported clients

- World of Warcraft Retail
- Mists of Pandaria Classic
- Burning Crusade Classic Anniversary
- Classic Era, Hardcore, and Season of Discovery
- WoW Forever Beta 1.60.1 (Interface 16001)

All supported clients share one package. World of Warcraft automatically selects
the appropriate manifest. On CurseForge, choose the file tagged for your client;
Forever is published as a separate platform file containing the same addon.

The WoW Forever Beta manifest supports client
1.60.1.70205 (Interface 16001), using the native `_Camelot` suffix. Its loader
and API diagnostic passed on Classic Beta PvP. The owner confirmed all six
focused addon game checks passed there on 2026-10-03, including persistence
after reload and a full client restart. The separate CurseForge 2.0.0 Forever
file was owner-confirmed Approved on 2026-10-03. The original GitHub 2.0.0
archive predates that additional manifest. The 2.0.1 package contains all five
manifests. Forever uses a separate CurseForge file tagged only for 1.60.1;
its addon payload is identical to the standard package.
The custom-transparency update was accepted in Retail on 2026-10-05; additional
client checks for this bounded change were waived by the owner.

## Downloads

- [CurseForge](https://www.curseforge.com/wow/addons/parchment-reader)
- [Wago Addons](https://addons.wago.io/addons/parchment-reader)
- [GitHub Releases](https://github.com/Helsdar/ParchmentReader/releases)

## Installation

1. Extract the archive.
2. Copy the `ParchmentReader` folder into the `Interface\AddOns` directory for
   the client you play.
3. Restart World of Warcraft and enable **Parchment Reader** in the AddOns list.

The final path should look like:

```text
World of Warcraft\_retail_\Interface\AddOns\ParchmentReader\ParchmentReader.toc
```

Use `_classic_`, `_anniversary_`, or `_classic_era_` instead of `_retail_` for
the corresponding Classic client. For WoW Forever Beta,
use `_classic_beta_` and keep `ParchmentReader_Camelot.toc` alongside the base
manifest.

## Getting started

- Left-click the minimap icon to show or hide the reader.
- Right-click the minimap icon to open settings.
- Ctrl + left-click the minimap icon to open Quick Note.
- Drag the minimap icon to reposition it.
- Use **+ Add Book** to create your first saved book.
- Use Library, Favorites, and Recent below the search field. Right-click a book
  to change its favorite status, edit it, or move it to another collection.
- Right-click Recent to clear reading history after confirmation.
- Change a book's title in Edit Book; titles must be unique in its collection.
- Open Quick Note and use **Resume** to continue its last saved note. Assign
  **Resume Last Quick Note** in Controls or WoW Key Bindings for direct access.
  Resume becomes available after your first Quick Note save in this version.
- Use the search field for title and collection terms. Toggle **Aa** for content
  phrases, then press Enter to open the first result or click another result.
- Use the contextual footer arrows to move between content matches and **×** to
  return to the ordinary saved reading position.
- Click the book page before using keyboard navigation; click outside it or
  press Escape to return keyboard control to WoW.
- Use the Pin button in the Reader header to lock its position and size and
  restore it after reloads or logins.
- Open **Keyboard Help** in the reader or editor to see available shortcuts.
- In Appearance, choose **Custom — adjust transparency** to show the slider
  and **Transparent until hovered** option.

## Commands

- `/reader` — show or hide the reader.
- `/reader refresh` — refresh the reader interface.
- `/pr` — short alias for `/reader`.

## Saved data

Books, collections, bookmarks, reading positions, and settings are stored by
World of Warcraft in `ParchmentReaderDB`. Back up the account's `WTF` directory
before updating the addon, reinstalling the game, or moving to another computer.
Version 2.0.1 retains books, bookmarks, and reading progress, adding only the
custom transparency amount and hover preference to settings.
Version 2.0.2 improves bookmark presentation without changing saved books,
bookmarks, or reading progress.

## License

Copyright © 2026 Helsdar. All rights reserved. See [LICENSE](LICENSE).
