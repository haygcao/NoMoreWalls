import 'package:flutter/material.dart';
import 'package:spotube/models/unified/recommendation.dart';

/// 推荐属性辅助类，用于处理推荐属性的更新
class RecommendationAttributeHelper {
  /// 属性名称到获取/设置函数的映射
  static final Map<String, _AttributeAccessors> _attributeAccessors = {
    'acousticness': _AttributeAccessors(
      getter: (seeds) => seeds.acousticness,
      setter: (seeds, attr) => seeds.copyWith(acousticness: attr),
    ),
    'danceability': _AttributeAccessors(
      getter: (seeds) => seeds.danceability,
      setter: (seeds, attr) => seeds.copyWith(danceability: attr),
    ),
    'energy': _AttributeAccessors(
      getter: (seeds) => seeds.energy,
      setter: (seeds, attr) => seeds.copyWith(energy: attr),
    ),
    'instrumentalness': _AttributeAccessors(
      getter: (seeds) => seeds.instrumentalness,
      setter: (seeds, attr) => seeds.copyWith(instrumentalness: attr),
    ),
    'liveness': _AttributeAccessors(
      getter: (seeds) => seeds.liveness,
      setter: (seeds, attr) => seeds.copyWith(liveness: attr),
    ),
    'loudness': _AttributeAccessors(
      getter: (seeds) => seeds.loudness,
      setter: (seeds, attr) => seeds.copyWith(loudness: attr),
    ),
    'popularity': _AttributeAccessors(
      getter: (seeds) => seeds.popularity,
      setter: (seeds, attr) => seeds.copyWith(popularity: attr),
    ),
    'speechiness': _AttributeAccessors(
      getter: (seeds) => seeds.speechiness,
      setter: (seeds, attr) => seeds.copyWith(speechiness: attr),
    ),
    'tempo': _AttributeAccessors(
      getter: (seeds) => seeds.tempo,
      setter: (seeds, attr) => seeds.copyWith(tempo: attr),
    ),
    'valence': _AttributeAccessors(
      getter: (seeds) => seeds.valence,
      setter: (seeds, attr) => seeds.copyWith(valence: attr),
    ),
  };

  /// 更新推荐属性
  /// 
  /// [attributeName] 属性名称
  /// [value] 新的属性值
  /// [target] 目标值
  /// [min] 最小值
  /// [max] 最大值
  static void updateAttribute({
    required String attributeName,
    required RecommendationAttribute value,
    required ValueNotifier<RecommendationSeeds> target,
    required ValueNotifier<RecommendationSeeds> min,
    required ValueNotifier<RecommendationSeeds> max,
  }) {
    final accessors = _attributeAccessors[attributeName];
    if (accessors == null) return;

    // 更新目标值
    final targetAttr = accessors.getter(target.value);
    target.value = accessors.setter(
      target.value,
      RecommendationAttribute(
        min: targetAttr?.min,
        max: targetAttr?.max,
        target: value.target,
      ),
    );
    
    // 更新最小值
    final minAttr = accessors.getter(min.value);
    min.value = accessors.setter(
      min.value,
      RecommendationAttribute(
        min: value.min,
        max: minAttr?.max,
        target: minAttr?.target,
      ),
    );
    
    // 更新最大值
    final maxAttr = accessors.getter(max.value);
    max.value = accessors.setter(
      max.value,
      RecommendationAttribute(
        min: maxAttr?.min,
        max: value.max,
        target: maxAttr?.target,
      ),
    );
  }

  /// 获取推荐属性值
  /// 
  /// [targetSeeds] 目标推荐种子
  /// [minSeeds] 最小推荐种子
  /// [maxSeeds] 最大推荐种子
  /// [attributeName] 属性名称
  static RecommendationAttribute getAttributeValues({
    required RecommendationSeeds targetSeeds,
    required RecommendationSeeds minSeeds,
    required RecommendationSeeds maxSeeds,
    required String attributeName,
  }) {
    final accessors = _attributeAccessors[attributeName];
    if (accessors == null) {
      return const RecommendationAttribute(target: 0, min: 0, max: 0);
    }

    final targetAttr = accessors.getter(targetSeeds);
    final minAttr = accessors.getter(minSeeds);
    final maxAttr = accessors.getter(maxSeeds);

    return RecommendationAttribute(
      target: targetAttr?.target ?? 0,
      min: minAttr?.min ?? 0,
      max: maxAttr?.max ?? 0,
    );
  }
}

/// 属性访问器，包含获取和设置属性的函数
class _AttributeAccessors {
  /// 获取属性的函数
  final RecommendationAttribute? Function(RecommendationSeeds) getter;
  
  /// 设置属性的函数
  final RecommendationSeeds Function(RecommendationSeeds, RecommendationAttribute) setter;

  _AttributeAccessors({
    required this.getter,
    required this.setter,
  });
}