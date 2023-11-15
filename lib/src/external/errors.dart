class QueueModificationError<T> extends Error {
  final List<T> entities;
  QueueModificationError({
    required this.entities,
  });
}