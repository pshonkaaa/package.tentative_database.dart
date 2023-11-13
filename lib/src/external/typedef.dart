import 'package:ientity/library.dart';
import 'package:json_ex/library.dart';

@Deprecated("")
typedef ModelConstructorFunction<T extends IEntity> = T Function(JsonObjectEx json);



typedef EntityPredicate<T extends IEntity> = bool Function(T entity);
typedef EntityComparison<T extends IEntity> = bool Function(T e1, T e2);
typedef EntityTest<T extends IEntity> = bool Function(T e1, T e2);
typedef EntityByIdPredicate<T extends IEntity, ID> = bool Function(T entity, ID id);
// typedef EntityByMapPredicate<T extends IEntity> = bool Function(T entity, JsonObject row);
typedef MapToEntityConverter<T extends IEntity> = T Function(Map<String, dynamic> map);
typedef MapToCustomDataConverter<TCUSTOM> = TCUSTOM Function(Map<String, dynamic> map);
typedef EntityToCustomDataConverter<T extends IEntity, TCUSTOM> = TCUSTOM Function(T entity);
// typedef EntityExtractor<T, ID> = ID Function(T entity);

typedef OnQueueModificationError = void Function(QueueModificationError error, StackTrace stackTrace);

class QueueModificationError<T> extends Error {
  final List<T> entities;
  QueueModificationError({
    required this.entities,
  });
}