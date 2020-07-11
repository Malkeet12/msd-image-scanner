import 'package:permission_handler/permission_handler.dart';

class MyPermission {
  static Future<bool> request(PermissionGroup permission) async {
    var result = await PermissionHandler().requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  static Future<bool> handlePermissions() async {
    var permission1 = await MyPermission.request(PermissionGroup.camera);
    var permission2 = await MyPermission.request(PermissionGroup.storage);
    // var permission3 = await Permission.request(PermissionGroup.mediaLibrary);
    // var permission4 = await Permission.request(PermissionGroup.photos);
    return permission1 && permission2;
  }
}
