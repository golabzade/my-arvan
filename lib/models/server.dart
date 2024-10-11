class ServerList {
  List<Server> data;

  ServerList({
    required this.data,
  });

  factory ServerList.fromJson(Map<String, dynamic> json) {
    Iterable list = json['data'];
    List<Server> data = list.map((i) => Server.fromJson(i)).toList();

    return ServerList(data: data);
  }
}

class Server {
  String id;
  String name;
  ServerFlavor flavor;
  ServerStatus status;
  ServerImage image;
  DateTime created;
  dynamic taskState;
  String keyName;
  String arNext;
  List<dynamic> securityGroups;
  ServerAddresses addresses;
  List<dynamic> tags;
  bool haEnabled;
  String clusterId;

  Server({
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
      id: json['id'],
      name: json['name'],
      flavor: ServerFlavor.fromJson(json['flavor']),
      status: ServerStatus.fromString(json['status']),
      image: ServerImage.fromJson(json['image']),
      created: DateTime.parse(json['created']),
      taskState: json['task_state'],
      keyName: json['key_name'],
      arNext: json['ar_next'],
      securityGroups: json['security_groups'],
      addresses: ServerAddresses.fromJson(json['addresses']),
      tags: json['tags'],
      haEnabled: json['ha_enabled'],
      clusterId: json['cluster_id'],
    );
  }
}

enum ServerStatus {
  shelvedOffloaded, active, reboot, shutoff;
  
  @override
  String toString() {
    switch (name) {
      case 'shelvedOffloaded':
        return 'Off (Terminated)';
      case 'shutoff':
        return 'Off (Stopped)';
      case 'active':
        return 'Active';
      case 'reboot':
        return 'Reboot';
      default:
      return 'error on enum ServerStatus.toString()';
    }
  }

  factory ServerStatus.fromString(String str) {
     switch (str) {
      case 'SHELVED_OFFLOADED':
        return ServerStatus.shelvedOffloaded;
      case 'SHUTOFF':
        return ServerStatus.shutoff;
      case 'ACTIVE':
        return ServerStatus.active;
      case 'REBOOT':
        return ServerStatus.reboot;
      default:
    throw ArgumentError.value(str, "name", "No enum value with that name");
    }
  }
}

class ServerAddresses {
  List<ServerAddressePublic213> public213;

  ServerAddresses({
    required this.public213,
  });

  factory ServerAddresses.fromJson(Map<String, dynamic> json) {
    Iterable list = json['public213'];
    List<ServerAddressePublic213> public213 = list.map((i) => ServerAddressePublic213.fromJson(i)).toList();

    return ServerAddresses(public213: public213);
  }
}

class ServerAddressePublic213 {
  String macAddr;
  String version;
  String addr;
  String type;
  bool isPublic;

  ServerAddressePublic213({
    required this.macAddr,
    required this.version,
    required this.addr,
    required this.type,
    required this.isPublic,
  });

  factory ServerAddressePublic213.fromJson(Map<String, dynamic> json) {
    return ServerAddressePublic213(
      macAddr: json['mac_addr'],
      version: json['version'],
      addr: json['addr'],
      type: json['type'],
      isPublic: json['is_public'],
    );
  }
}

class ServerFlavor {
  String id;
  String name;
  int ram;
  String swap;
  int vcpus;
  int disk;

  ServerFlavor({
    required this.id,
    required this.name,
    required this.ram,
    required this.swap,
    required this.vcpus,
    required this.disk,
  });

  factory ServerFlavor.fromJson(Map<String, dynamic> json) {
    return ServerFlavor(
      id: json['id'],
      name: json['name'],
      ram: json['ram'],
      swap: json['swap'],
      vcpus: json['vcpus'],
      disk: json['disk'],
    );
  }
}

class ServerImage {
  String id;
  String name;
  int minDisk;
  int minRam;
  String os;
  String osVersion;
  int progress;
  int size;
  String status;
  DateTime created;
  String username;
  ServerImageMetadata metadata;
  List<dynamic> documents;

  ServerImage({
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
      id: json['id'],
      name: json['name'],
      minDisk: json['min_disk'],
      minRam: json['min_ram'],
      os: json['os'],
      osVersion: json['os_version'],
      progress: json['progress'],
      size: json['size'],
      status: json['status'],
      created: DateTime.parse(json['created']),
      username: json['username'],
      metadata: ServerImageMetadata.fromJson(json['metadata']),
      documents: json['documents'],
    );
  }
}

class ServerImageMetadata {
  String arIaCImage;
  String arVisibility;
  String hwDiskBus;
  String hwQemuGuestAgent;
  String hwVifMultiqueueEnabled;
  String imageVersion;
  String os;
  String osDistro;
  String osType;
  String osVersion;
  String ownerSpecifiedOpenstackObject;
  String panelName;
  String sshKey;
  String sshPassword;
  String username;

  ServerImageMetadata({
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
      arIaCImage: json['arIaCImage'],
      arVisibility: json['ar_visibility'],
      hwDiskBus: json['hw_disk_bus'],
      hwQemuGuestAgent: json['hw_qemu_guest_agent'],
      hwVifMultiqueueEnabled: json['hw_vif_multiqueue_enabled'],
      imageVersion: json['imageVersion'],
      os: json['os'],
      osDistro: json['os_distro'],
      osType: json['os_type'],
      osVersion: json['os_version'],
      ownerSpecifiedOpenstackObject: json['owner_specified.openstack.object'],
      panelName: json['panelName'],
      sshKey: json['ssh_key'],
      sshPassword: json['ssh_password'],
      username: json['username'],
    );
  }
}
