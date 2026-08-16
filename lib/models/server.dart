enum ServerStatus {
  shelvedOffloaded,
  active,
  reboot,
  shutoff,
  build,
  unknown;

  @override
  String toString() {
    switch (this) {
      case ServerStatus.shelvedOffloaded:
        return 'Off (Terminated)';
      case ServerStatus.shutoff:
        return 'Off (Stopped)';
      case ServerStatus.active:
        return 'Active';
      case ServerStatus.reboot:
        return 'Rebooting';
      case ServerStatus.build:
        return 'Building';
      case ServerStatus.unknown:
        return 'Unknown';
    }
  }

  factory ServerStatus.fromString(String? str) {
    switch (str?.toUpperCase()) {
      case 'SHELVED_OFFLOADED':
        return ServerStatus.shelvedOffloaded;
      case 'SHUTOFF':
        return ServerStatus.shutoff;
      case 'ACTIVE':
        return ServerStatus.active;
      case 'REBOOT':
      case 'HARD_REBOOT':
        return ServerStatus.reboot;
      case 'BUILD':
        return ServerStatus.build;
      default:
        return ServerStatus.unknown;
    }
  }
}

class ServerList {
  final List<Server> data;

  const ServerList({
    required this.data,
  });

  factory ServerList.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    if (list is List) {
      final data = list
          .whereType<Map<String, dynamic>>()
          .map((i) => Server.fromJson(i))
          .toList();
      return ServerList(data: data);
    }
    return const ServerList(data: []);
  }
}

class Server {
  final String id;
  final String name;
  final ServerFlavor flavor;
  final ServerStatus status;
  final ServerImage image;
  final DateTime? created;
  final dynamic taskState;
  final String keyName;
  final String arNext;
  final List<dynamic> securityGroups;
  final ServerAddresses addresses;
  final List<dynamic> tags;
  final bool haEnabled;
  final String clusterId;

  const Server({
    required this.id,
    required this.name,
    required this.flavor,
    required this.status,
    required this.image,
    required this.created,
    required this.taskState,
    required this.keyName,
    required this.arNext,
    required this.securityGroups,
    required this.addresses,
    required this.tags,
    required this.haEnabled,
    required this.clusterId,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      flavor: ServerFlavor.fromJson(
          json['flavor'] is Map<String, dynamic> ? json['flavor'] : {}),
      status: ServerStatus.fromString(json['status']?.toString()),
      image: ServerImage.fromJson(
          json['image'] is Map<String, dynamic> ? json['image'] : {}),
      created: json['created'] != null
          ? DateTime.tryParse(json['created'].toString())
          : null,
      taskState: json['task_state'],
      keyName: json['key_name']?.toString() ?? '',
      arNext: json['ar_next']?.toString() ?? '',
      securityGroups:
          json['security_groups'] is List ? json['security_groups'] : [],
      addresses: ServerAddresses.fromJson(
          json['addresses'] is Map<String, dynamic> ? json['addresses'] : {}),
      tags: json['tags'] is List ? json['tags'] : [],
      haEnabled: json['ha_enabled'] == true,
      clusterId: json['cluster_id']?.toString() ?? '',
    );
  }
}

class ServerAddresses {
  final List<ServerAddress> data;

  const ServerAddresses({
    required this.data,
  });

  factory ServerAddresses.fromJson(Map<String, dynamic> json) {
    final List<ServerAddress> data = [];
    for (final key in json.keys) {
      final value = json[key];
      if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            data.add(ServerAddress.fromJson(item));
          }
        }
      }
    }
    return ServerAddresses(data: data);
  }
}

class ServerAddress {
  final String macAddr;
  final String version;
  final String addr;
  final String type;
  final bool isPublic;

  const ServerAddress({
    required this.macAddr,
    required this.version,
    required this.addr,
    required this.type,
    required this.isPublic,
  });

  factory ServerAddress.fromJson(Map<String, dynamic> json) {
    return ServerAddress(
      macAddr: json['mac_addr']?.toString() ?? '',
      version: json['version']?.toString() ?? '4',
      addr: json['addr']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isPublic: json['is_public'] == true,
    );
  }
}

class ServerFlavor {
  final String id;
  final String name;
  final int ram;
  final String swap;
  final int vcpus;
  final int disk;

  const ServerFlavor({
    required this.id,
    required this.name,
    required this.ram,
    required this.swap,
    required this.vcpus,
    required this.disk,
  });

  factory ServerFlavor.fromJson(Map<String, dynamic> json) {
    return ServerFlavor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ram: (json['ram'] as num?)?.toInt() ?? 0,
      swap: json['swap']?.toString() ?? '0',
      vcpus: (json['vcpus'] as num?)?.toInt() ?? 0,
      disk: (json['disk'] as num?)?.toInt() ?? 0,
    );
  }
}

class ServerImage {
  final String id;
  final String name;
  final int minDisk;
  final int minRam;
  final String os;
  final String osVersion;
  final int progress;
  final int size;
  final String status;
  final DateTime? created;
  final String username;
  final ServerImageMetadata? metadata;
  final List<dynamic> documents;

  const ServerImage({
    required this.id,
    required this.name,
    required this.minDisk,
    required this.minRam,
    required this.os,
    required this.osVersion,
    required this.progress,
    required this.size,
    required this.status,
    required this.created,
    required this.username,
    required this.metadata,
    required this.documents,
  });

  factory ServerImage.fromJson(Map<String, dynamic> json) {
    return ServerImage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      minDisk: (json['min_disk'] as num?)?.toInt() ?? 0,
      minRam: (json['min_ram'] as num?)?.toInt() ?? 0,
      os: json['os']?.toString() ?? 'ubuntu',
      osVersion: json['os_version']?.toString() ?? '',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      created: json['created'] != null
          ? DateTime.tryParse(json['created'].toString())
          : null,
      username: json['username']?.toString() ?? '',
      metadata: json['metadata'] is Map<String, dynamic>
          ? ServerImageMetadata.fromJson(json['metadata'])
          : null,
      documents: json['documents'] is List ? json['documents'] : [],
    );
  }
}

class ServerImageMetadata {
  final String arIaCImage;
  final String arVisibility;
  final String hwDiskBus;
  final String hwQemuGuestAgent;
  final String hwVifMultiqueueEnabled;
  final String imageVersion;
  final String os;
  final String osDistro;
  final String osType;
  final String osVersion;
  final String ownerSpecifiedOpenstackObject;
  final String panelName;
  final String sshKey;
  final String sshPassword;
  final String username;

  const ServerImageMetadata({
    required this.arIaCImage,
    required this.arVisibility,
    required this.hwDiskBus,
    required this.hwQemuGuestAgent,
    required this.hwVifMultiqueueEnabled,
    required this.imageVersion,
    required this.os,
    required this.osDistro,
    required this.osType,
    required this.osVersion,
    required this.ownerSpecifiedOpenstackObject,
    required this.panelName,
    required this.sshKey,
    required this.sshPassword,
    required this.username,
  });

  factory ServerImageMetadata.fromJson(Map<String, dynamic> json) {
    return ServerImageMetadata(
      arIaCImage: json['arIaCImage']?.toString() ?? '',
      arVisibility: json['ar_visibility']?.toString() ?? '',
      hwDiskBus: json['hw_disk_bus']?.toString() ?? '',
      hwQemuGuestAgent: json['hw_qemu_guest_agent']?.toString() ?? '',
      hwVifMultiqueueEnabled: json['hw_vif_multiqueue_enabled']?.toString() ?? '',
      imageVersion: json['imageVersion']?.toString() ?? '',
      os: json['os']?.toString() ?? '',
      osDistro: json['os_distro']?.toString() ?? '',
      osType: json['os_type']?.toString() ?? '',
      osVersion: json['os_version']?.toString() ?? '',
      ownerSpecifiedOpenstackObject:
          json['owner_specified.openstack.object']?.toString() ?? '',
      panelName: json['panelName']?.toString() ?? '',
      sshKey: json['ssh_key']?.toString() ?? '',
      sshPassword: json['ssh_password']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}
