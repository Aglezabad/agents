# Clean Test Input: ALPHA — Well-Defined Feature Request

**Title:** Add dark mode toggle to user settings page

**Body:**
Hi team,

We would like to add a dark mode toggle to the user settings page so users can switch between light and dark themes.

Requirements:
- Add a toggle switch in `/settings/appearance`
- Store preference in `localStorage` under key `theme`
- Default to system preference via `prefers-color-scheme`
- Update CSS custom properties (`--bg`, `--text`) to switch themes
- Smooth transition between themes (200ms ease)

Acceptance criteria:
1. Toggle is visible and functional in settings
2. Theme persists across sessions
3. Respects OS-level dark mode preference on first visit
4. No flash of unstyled content on page load

Environment: Web app, React 18, Tailwind CSS v3
This is a user-facing feature request, not a bug.
