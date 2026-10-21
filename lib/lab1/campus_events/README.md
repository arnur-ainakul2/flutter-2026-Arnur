# Campus Events

An in-memory campus event app built with Flutter. Browse events by category, search, register, save favourites, create or edit events, and maintain a profile. Online events store a link; in-person events store a campus location.

## Screenshots

Add these before submission:

- Phone, light theme: `screenshots/phone-light.png`
- Phone, dark theme: `screenshots/phone-dark.png`
- Tablet grid: `screenshots/tablet-grid.png`

## Decisions

The event list and profile live in the shell state so all three tabs read the same in-memory data. The detail screen receives its event and callbacks through typed route arguments, while the form returns a changed event so cancelling it leaves the list untouched. The grid uses `LayoutBuilder` because the available width of the list is the constraint that determines whether cards should become columns. The dirty form compares its current field values with the values that were present when the form opened, and asks before discarding edits. Event places are stored as a string whose meaning depends on the online mode: a URL for online events and a campus location otherwise. With week 9's storage tools, I would persist the event list and profile so they survive an app restart.
