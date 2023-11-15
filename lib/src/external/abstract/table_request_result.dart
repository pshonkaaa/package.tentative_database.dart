import 'package:itable_ex/library.dart';

@deprecated
abstract class ITableRequestResult<T> {
  List<RequestDetails> get transactions;
  
  List<T> get entities;
}

abstract class TableRequestResult<T> implements ITableRequestResult<T> {
  final List<RequestDetails> transactions = [];
  
  List<T> get entities;
}