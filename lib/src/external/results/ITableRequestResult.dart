import 'package:itable_ex/library.dart';

abstract class ITableRequestResult<T> {
  final List<RequestDetails> transactions = [];
  List<T>   get entities;
}