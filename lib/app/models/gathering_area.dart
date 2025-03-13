import 'package:json_annotation/json_annotation.dart';

part 'gathering_area.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class GatheringArea {
  GatheringArea({
    required this.id,
    required this.geometryName,
    required this.geometry,
    required this.properties,
  });

  factory GatheringArea.fromJson(Map<String, dynamic> json) =>
      _$GatheringAreaFromJson(json);
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String geometryName;

  @JsonKey(required: false)
  final Map<String, dynamic> geometry;

  @JsonKey(required: false)
  final Map<String, dynamic> properties;
  Map<String, dynamic> toJson() => _$GatheringAreaToJson(this);
}

@JsonSerializable()
class Feature {
  Feature({
    required this.type,
    required this.id,
    required this.geometry,
    required this.geometryName,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);
  final String type;
  final String id;
  final Geometry geometry;
  final String geometryName;
  final Properties properties;
  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}

@JsonSerializable()
class Geometry {
  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      _$GeometryFromJson(json);
  final String type;
  final List<List<List<List<double>>>> coordinates;
  Map<String, dynamic> toJson() => _$GeometryToJson(this);
}

@JsonSerializable()
class Properties {
  Properties({
    required this.id,
    required this.il,
    required this.ilce,
    required this.mahalle,
    required this.ad,
  });

  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);
  final int id;
  final String il;
  final String ilce;
  final String mahalle;
  final String ad;
  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
}

@JsonSerializable()
class Crs {
  Crs({
    required this.type,
    required this.properties,
  });

  factory Crs.fromJson(Map<String, dynamic> json) => _$CrsFromJson(json);
  final String type;
  final CrsProperties properties;
  Map<String, dynamic> toJson() => _$CrsToJson(this);
}

@JsonSerializable()
class CrsProperties {
  CrsProperties({
    required this.name,
  });

  factory CrsProperties.fromJson(Map<String, dynamic> json) =>
      _$CrsPropertiesFromJson(json);
  final String name;
  Map<String, dynamic> toJson() => _$CrsPropertiesToJson(this);
}
