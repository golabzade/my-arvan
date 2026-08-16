class RegionList {
  final List<Region> data;

  const RegionList({
    required this.data,
  });

  factory RegionList.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    if (list is List) {
      final data = list
          .whereType<Map<String, dynamic>>()
          .map((i) => Region.fromJson(i))
          .toList();
      return RegionList(data: data);
    }
    return const RegionList(data: []);
  }
}

class Region {
  final String nameEn;
  final String nameFa;
  final String zoneEn;
  final String zoneFa;
  final String cityEn;
  final String cityFa;
  final String countryEn;
  final String countryFa;
  final String region;
  final String code;
  final dynamic flag;
  final bool volumeBacked;
  final String state;
  final dynamic status;
  final String version;
  final bool defaultDatacenter;
  final String image;

  const Region({
    required this.nameEn,
    required this.nameFa,
    required this.zoneEn,
    required this.zoneFa,
    required this.cityEn,
    required this.cityFa,
    required this.countryEn,
    required this.countryFa,
    required this.region,
    required this.code,
    required this.flag,
    required this.volumeBacked,
    required this.state,
    required this.status,
    required this.version,
    required this.defaultDatacenter,
    required this.image,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      nameEn: json['name_en']?.toString() ?? '',
      nameFa: json['name_fa']?.toString() ?? '',
      zoneEn: json['zone_en']?.toString() ?? '',
      zoneFa: json['zone_fa']?.toString() ?? '',
      cityEn: json['city_en']?.toString() ?? '',
      cityFa: json['city_fa']?.toString() ?? '',
      countryEn: json['country_en']?.toString() ?? '',
      countryFa: json['country_fa']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      flag: json['flag'],
      volumeBacked: json['volume_backed'] == true,
      state: json['state']?.toString() ?? 'unknown',
      status: json['status'],
      version: json['version']?.toString() ?? '',
      defaultDatacenter: json['default_datacenter'] == true,
      image: json['image']?.toString() ?? '',
    );
  }
}
