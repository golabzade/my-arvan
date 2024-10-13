import 'package:my_arven/models/region.dart';
import 'package:my_arven/models/server.dart';

class ServerWithRegion {
  Server? server;
  Region? region;
  
  ServerWithRegion({
    this.server,
    this.region,
  });
}