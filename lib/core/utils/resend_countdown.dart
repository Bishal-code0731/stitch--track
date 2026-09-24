int resendSecondsRemaining({
  required DateTime sentAt,
  required Duration cooldown,
  required DateTime now,
}) {
  final remainingMs =
      cooldown.inMilliseconds - now.difference(sentAt).inMilliseconds;
  if (remainingMs <= 0) return 0;
  return (remainingMs / 1000).ceil();
}
