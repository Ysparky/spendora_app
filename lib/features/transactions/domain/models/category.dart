import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

mixin CategoryMixin {
  String get name;
  Map<String, String> get translations;

  /// Gets the translated name for the given locale code (e.g., 'es', 'en')
  /// Falls back to the default name if no translation is available
  String getLocalizedName(String localeCode) {
    return translations[localeCode] ?? name;
  }
}

@freezed
abstract class Category with _$Category, CategoryMixin {
  const Category._();

  const factory Category({
    required String id,
    required String name,
    required String icon,
    @Default({}) Map<String, String> translations,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Creates a Category from a Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category.fromJson({
      ...data,
      'id': doc.id,
      'translations':
          (data['translations'] as Map<String, dynamic>?)
              ?.cast<String, String>() ??
          {},
    });
  }
}
