# Changelog

## 1.2.0 — 2026-08-28

- Reduced the default Reader size to `720x480` and the standard minimum to
  `460x320`, while keeping the `320x200` Compact Mode minimum.
- Normal and Compact Mode now remember their window sizes independently.
- Added an assignable **Toggle Compact Mode** action to WoW Key Bindings and the
  addon Settings window.
- Added an optional **Transparent background in combat** setting that restores
  the selected Off, Always, or Smart behavior when combat ends.
- Added a complete Brazilian Portuguese (`ptBR`) interface localization, manual
  language selection, automatic `ptBR` client detection, and localized AddOns
  metadata.
- Fixed Reset to Defaults so leaving Compact Mode synchronizes the current
  reading position before restoring the standard layout.
- Reduced repeated locale normalization while sorting large book libraries.

## 1.1.0 — 2026-08-22

- Added Pin Reader to prevent accidental moving or resizing, keep the Reader
  available while using WoW menus, and restore it after reloads or logins.
- The Reader and minimized launcher now remember their positions and minimized
  state between sessions.
- Improved the Compact Mode header, title spacing, and window positioning.
- Parchment Reader windows now stay below native WoW panels such as the World
  Map and Talents.
- Keyboard navigation no longer takes over gameplay keys automatically. Click
  the book page to enable it, and click outside, press Escape, use another key,
  or enter combat to return keyboard control to WoW.
- Added a setting to choose the addon interface language independently from the
  WoW client language: Auto, English, German, French, Spanish, or Russian.
- Fixed Settings dropdown layering and ensured Keyboard Help and confirmation
  messages use the selected interface language.

## 1.0.0 — 2026-08-12

Initial public release.

- Added continuous reading with automatic position restoration.
- Added saved books, collections, search, editing, and Quick Note.
- Added bookmarks with rename, navigation, delete, and undo support.
- Added Compact Mode, a floating minimized launcher, reader transparency, and
  configurable shortcuts.
- Added English, German, French, Russian, and Spanish interface localizations.
- Added support for Retail, Mists of Pandaria Classic, Burning Crusade Classic
  Anniversary, and Classic Era clients.
