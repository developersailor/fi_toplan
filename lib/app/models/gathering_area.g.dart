// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gathering_area.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GatheringArea _$GatheringAreaFromJson(Map<String, dynamic> json) =>
    GatheringArea(
      id: json['id'] as String? ?? '',
      geometryName: json['geometryName'] as String? ?? '',
      geometry: json['geometry'] as Map<String, dynamic>,
      properties: json['properties'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$GatheringAreaToJson(GatheringArea instance) =>
    <String, dynamic>{
      'id': instance.id,
      'geometryName': instance.geometryName,
      'geometry': instance.geometry,
      'properties': instance.properties,
    };

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
      type: json['type'] as String,
      id: json['id'] as String,
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      geometryName: json['geometryName'] as String,
      properties:
          Properties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'geometry': instance.geometry,
      'geometryName': instance.geometryName,
      'properties': instance.properties,
    };

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => (e as List<dynamic>)
                  .map((e) => (e as List<dynamic>)
                      .map((e) => (e as num).toDouble())
                      .toList())
                  .toList())
              .toList())
          .toList(),
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) => Properties(
      id: (json['id'] as num).toInt(),
      il: json['il'] as String,
      ilce: json['ilce'] as String,
      mahalle: json['mahalle'] as String,
      ad: json['ad'] as String,
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'id': instance.id,
      'il': instance.il,
      'ilce': instance.ilce,
      'mahalle': instance.mahalle,
      'ad': instance.ad,
    };

Crs _$CrsFromJson(Map<String, dynamic> json) => Crs(
      type: json['type'] as String,
      properties:
          CrsProperties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CrsToJson(Crs instance) => <String, dynamic>{
      'type': instance.type,
      'properties': instance.properties,
    };

CrsProperties _$CrsPropertiesFromJson(Map<String, dynamic> json) =>
    CrsProperties(
      name: json['name'] as String,
    );

Map<String, dynamic> _$CrsPropertiesToJson(CrsProperties instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
