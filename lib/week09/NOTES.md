# NOTES

## Level 1: Lift it up
Adding `total` to the badge touched 2 constructors (BooksScreen, CartBadge)
and 1 call site in Shell (the routes). Files: main.dart, books_screen.dart,
cart_badge.dart. CartScreen was not touched, but the value passes through
BooksScreen, which does not need it itself.

One tap on "Add" printed 7 lines: 1 × `BooksScreen build` + 6 × `row ...`
(the whole screen and every row rebuilt). <- verify in your console

## Level 3: provider errors
Loud (`context.watch<Cart>().add(b)` in onPressed):
"Tried to listen to a value exposed with provider, from outside of the
widget tree." <- paste the exact text from your console

Silent (`context.read<Cart>().count` in the badge):
no error, it compiles and runs, but the badge stays at 0 forever,
because the widget never subscribed to the Cart.

## Level 4: badge rebuilds
3 presses of + in the cart:
- with `watch`: `badge build` printed 3 times
- with `select`: 0 times (and 1 time when a book is removed)

## Level 5: Where does it live?
- the cart — provided: many screens (badge, books, cart) need it, and it is
  a model with its own logic
- search text in the Books AppBar — ephemeral: only one screen needs it, and
  it can be lost when you leave the screen
- total expanded/collapsed on the Cart screen — ephemeral: a purely visual
  detail of one widget
- theme mode — provided (or lifted above MaterialApp): MaterialApp reads it
  and the whole app depends on it