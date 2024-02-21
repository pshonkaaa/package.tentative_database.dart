import 'package:foundation/library.dart';

class DatabaseListeners {
  final Notifier<void> onConnect = Notifier(value: null);
  final Notifier<void> onLoad = Notifier(value: null);
  final Notifier<void> onClose = Notifier(value: null);
}