# NOTES

## Level 1: Lift it up
Adding `total` to the badge touched 2 constructors (BooksScreen, CartBadge)
and 1 call site (Shell). Files: main.dart, books_screen.dart, cart_badge.dart.
BooksScreen does not use `total` itself, it only passes it down.

One tap on "Add" printed 7 lines: 1 x `BooksScreen build` + 6 x `row ...`.