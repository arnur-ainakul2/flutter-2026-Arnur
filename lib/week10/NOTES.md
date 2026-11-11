# NOTES — students_async

## Level 1 — the order of events

Predicted:
    A
    C
    fetchStudents #1
    (first frame of the app is drawn)
    B            <- two seconds later
    6 students   <- right after B

Actual:
    A
    C
    fetchStudents #1
    B
    6 students

Why: main() runs to the end first (A, C), the event loop then draws the first
frame, and the two timers come back later as events. The order of B and
"6 students" follows the order in which the two timers were created.

Experiment with sleep(): The app did not draw its first frame for two seconds 
because the event loop was completely blocked by sleep(). It was not waiting, 
the UI was completely frozen.

Third call in a row from main(): 
Unhandled Exception: Instance of 'NoConnectionException'

## Level 2 — setState after dispose

First line of the error with both `if (!mounted) return;` guards deleted:

    setState() called after dispose(): _StudentsScreenState#4a2b1 (lifecycle state: defunct, not mounted)

## Level 3 — FutureBuilder

With `future: _api.fetchStudents()` inside build, flipping the Switch printed:

    fetchStudents #2
    fetchStudents #3
    fetchStudents #4
    fetchStudents #5

With the first two branches swapped (data before error): The app showed a 
loading spinner forever. Because the connectionState was 'waiting', it never 
reached the hasError check, so the UI just hung and I couldn't even see the Retry button.

## Level 4 — the countdown that keeps ticking

- Version B WITHOUT `_sub.cancel()`, Back at 7: The console printed 
  `setState() called after dispose()` and continued ticking: tick 6, tick 5 ... 
  tick 0 with nobody on screen. The generator kept running in the background.
- Version B WITH `_sub.cancel()`: The console stopped at tick 7. The subscription 
  was cancelled, and no more ticks appeared.
- Version A (StreamBuilder), Back at 7: The console stopped at tick 7. There 
  is no cancel() anywhere in my code, StreamBuilder cancelled it automatically.

## Level 5 — errors that do not vanish

My first attempt at the Save button (without awaiting the future):
`onPressed: () { _api.save(n); Navigator.pop(context); }`

- `flutter analyze` flagged the line with: 
  `info • The 'await' keyword is missing before this future expression • lib/students_screen.dart:55:21 • unawaited_futures`
- Console after the failing Save: 
  `Unhandled Exception: Bad state: server rejected 6`
- The user saw a success: the screen popped as if the save worked, while the
  server said no and nobody caught the error.

The honest version (which I left in the final code): awaited, `try / on StateError`, `context.mounted` after
the await, pop only on success, the SnackBar only on failure, and the button
disabled while the request is in flight.