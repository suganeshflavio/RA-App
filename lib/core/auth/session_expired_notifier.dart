class SessionExpiredNotifier {
  SessionExpiredNotifier._();

  static final SessionExpiredNotifier instance = SessionExpiredNotifier._();

  void Function()? onSessionExpired;

  void notify() => onSessionExpired?.call();
}
