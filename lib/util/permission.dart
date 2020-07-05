import 'package:permission_handler/permission_handler.dart';

class Permission {
  static Future<bool> request(PermissionGroup permission) async {
    var result = await PermissionHandler().requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }
}
