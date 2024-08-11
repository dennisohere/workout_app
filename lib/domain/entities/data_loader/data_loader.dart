
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'data_loader.freezed.dart';

@freezed
sealed class DataLoader<T> with _$DataLoader {
  const factory DataLoader.data(T data) = Data<T>;
  const factory DataLoader.initial() = Initial;
  const factory DataLoader.loading() = Loading;
  const factory DataLoader.error({String? message}) = Error;
}