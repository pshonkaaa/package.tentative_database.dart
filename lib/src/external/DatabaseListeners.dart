import 'package:true_core/library.dart';

class DatabaseListeners {
  final Notifier<void> onOpen = Notifier.empty();
  final Notifier<void> onClose = Notifier.empty();
}