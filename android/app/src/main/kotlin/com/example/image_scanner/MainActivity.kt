package msd.image_scanner

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.firebase.ml.vision.FirebaseVision
import com.google.firebase.ml.vision.common.FirebaseVisionImage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutterToNative")
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    if (call.method == "start") {
                        val bitmap = BitmapFactory.decodeFile(call.arguments as String?)
                        val image = FirebaseVisionImage.fromBitmap(bitmap)
                        val objectDetector = FirebaseVision.getInstance().onDeviceObjectDetector
                        objectDetector.processImage(image)
                                .addOnSuccessListener { detectedObjects ->
                                    for (obj in detectedObjects) {
                                        val id = obj.trackingId       // A number that identifies the object across images
                                        val bounds = obj.boundingBox  // The object's position in the image

                                        // If classification was enabled:
                                        val category = obj.classificationCategory
                                        val confidence = obj.classificationConfidence
                                    }
                                }
                                .addOnFailureListener { e ->
                                    // Task failed with an exception
                                    // ...
                                }
                        result.success("message")
                    }
                }
    }
}
