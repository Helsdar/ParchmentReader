# Parchment Reader

Parchment Reader is an in-game library for World of Warcraft. Save stories,
notes, roleplay material, and other long-form text, then read it in a focused,
resizable window.

## Features

- Create, edit, organize, and search saved books and notes.
- Read continuously with automatic position saving.
- Group books into collections.
- Add, rename, navigate, delete, and restore bookmarks.
- Capture text quickly without leaving the game through Quick Note.
- Use Compact Mode or minimize the reader to a movable floating icon.
- Keep the Reader or minimized launcher in its saved screen position between
  sessions, and pin the Reader to prevent accidental movement or resizing.
- Enable keyboard navigation only when the book page has focus, leaving
  gameplay keys available to WoW at other times.
- Configure reader size, font, transparency, shortcuts, and minimap access.
- Choose the interface language independently of the WoW client: English,
  German, French, Russian, or Spanish.

## Supported clients

- World of Warcraft Retail
- Mists of Pandaria Classic
- Burning Crusade Classic Anniversary
- Classic Era, Hardcore, and Season of Discovery

All supported clients use the same download. World of Warcraft automatically
selects the appropriate manifest.

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
the corresponding Classic client.

## Getting started

- Left-click the minimap icon to show or hide the reader.
- Right-click the minimap icon to open settings.
- Ctrl + left-click the minimap icon to open Quick Note.
- Drag the minimap icon to reposition it.
- Use **+ Add Book** to create your first saved book.
- Right-click a saved book for edit and move actions.
- Click the book page before using keyboard navigation; click outside it or
  press Escape to return keyboard control to WoW.
- Use the Pin button in the Reader header to lock its position and size and
  restore it after reloads or logins.
- Open **Keyboard Help** in the reader or editor to see available shortcuts.

## Commands

- `/reader` — show or hide the reader.
- `/reader refresh` — refresh the reader interface.
- `/pr` — short alias for `/reader`.

## Saved data

Books, collections, bookmarks, reading positions, and settings are stored by
World of Warcraft in `ParchmentReaderDB`. Back up the account's `WTF` directory
before reinstalling the game or moving to another computer.

## License

Copyright © 2026 Helsdar. All rights reserved. See [LICENSE](LICENSE).
