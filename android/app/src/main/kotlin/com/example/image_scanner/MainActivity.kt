package msd.image_scanner

import android.content.Intent
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutterToNative")
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                   if(call.method == "camera"){
                        val REQUEST_CODE = 99
                        val preference: Int = ScanConstants.OPEN_CAMERA
                        val intent = Intent(this, ScanActivity::class.java)
                        intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
                        startActivityForResult(intent, REQUEST_CODE)
                        result.success("message")
                    }
                    else if(call.method == "gallery"){
//                        val REQUEST_CODE = 99
//                        val preference: Int = ScanConstants.OPEN_MEDIA
//                        val intent = Intent(this, ScanActivity::class.java)
//                        intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
//                        startActivityForResult(intent, REQUEST_CODE)
                    }

                }
    }
}
