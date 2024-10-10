class RegionList {
  List<Region> data;

  RegionList({
    required this.data,
  });

  factory RegionList.fromJson(Map<String, dynamic> json) {
    Iterable list = json['data'];
    List<Region> data = list.map((i) => Region.fromJson(i)).toList();

    return RegionList(data: data);
  }
}

class Region {
  String nameEn;
  String nameFa;
  String zoneEn;
  String zoneFa;
  String cityEn;
  String cityFa;
  String countryEn;
  String countryFa;
  String region;
  String code;
  dynamic flag;
  bool volumeBacked;
  String state;
  dynamic status;
  String version;
  bool defaultDatacenter;
  String image;

  Region({
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
      nameEn: json['name_en'],
      nameFa: json['name_fa'],
      zoneEn: json['zone_en'],
      zoneFa: json['zone_fa'],
      cityEn: json['city_en'],
      cityFa: json['city_fa'],
      countryEn: json['country_en'],
      countryFa: json['country_fa'],
      region: json['region'],
      code: json['code'],
      flag: json['flag'],
      volumeBacked: json['volume_backed'],
      state: json['state'],
      status: json['status'],
      version: json['version'],
      defaultDatacenter: json['default_datacenter'],
      image: json['image'],
    );
  }
}
