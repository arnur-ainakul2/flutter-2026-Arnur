sealed class Countdown {
  const Countdown();

  factory Countdown.from(DateTime when, {DateTime? now}) {
    final current = now ?? DateTime.now();

    if (current.isBefore(when)) {
      return Upcoming(when.difference(current));
    }

    final sameDay =
        current.year == when.year &&
        current.month == when.month &&
        current.day == when.day;

    if (sameDay) {
      return Started(current.difference(when));
    }

    return const Ended();
  }
}

final class Upcoming extends Countdown {
  final Duration remaining;

  const Upcoming(this.remaining);
}

final class Started extends Countdown {
  final Duration elapsed;

  const Started(this.elapsed);
}

final class Ended extends Countdown {
  const Ended();
}
