package msd.image_scanner

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.FileProvider
import com.scanlibrary.ScanActivity
import java.text.SimpleDateFormat;
import com.scanlibrary.ScanConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.Date


class MainActivity: FlutterActivity() {
    private var fileUri: Uri? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutterToNative")
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                   if(call.method == "camera"){
                        val REQUEST_CODE = 99
                       val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                       val file: File = createImageFile()
                       val isDirectoryCreated = file.parentFile.mkdirs()
                       println("openCamera: isDirectoryCreated: $isDirectoryCreated")
                       if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                           val tempFileUri: Uri = FileProvider.getUriForFile(activity.applicationContext,
                                   "com.scanlibrary.provider",  // As defined in Manifest
                                   file)
                           cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, tempFileUri)
                       } else {
                           val tempFileUri = Uri.fromFile(file)
                           cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, tempFileUri)
                       }
                       startActivityForResult(cameraIntent, ScanConstants.START_CAMERA_REQUEST_CODE)
//                        val preference: Int = ScanConstants.OPEN_CAMERA
//                        val intent = Intent(this, ScanActivity::class.java)
//                        intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
//                        startActivityForResult(intent, REQUEST_CODE)
//                        result.success("message")
                    }
                    else if(call.method == "gallery"){
                        val REQUEST_CODE = 100
                        val preference: Int = ScanConstants.OPEN_MEDIA
                        val intent = Intent(this, ScanActivity::class.java)
                        intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
                        startActivityForResult(intent, REQUEST_CODE)
                    }

                }
    }

    private fun createImageFile(): File {
        clearTempImages()
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val file = File(ScanConstants.IMAGE_PATH, "IMG_" + timeStamp +
                ".jpg")
        fileUri = Uri.fromFile(file)
        return file
    }

    private fun clearTempImages() {
        try {
            val tempFolder = File(ScanConstants.IMAGE_PATH)
            for (f in tempFolder.listFiles()) f.delete()
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }
    }

    private fun SaveImage(finalBitmap: Bitmap) {
        verifyStoragePermissions(this)
        val root = Environment.getExternalStorageDirectory().absolutePath
        val myDir = File("$root/saved_images")
        myDir.mkdirs()
        var time=	System.currentTimeMillis()
        val fname = "Image-$time.jpg"
        val file = File(myDir, fname)
        if (file.exists()) file.delete()
        try {
            val out = FileOutputStream(file)
            finalBitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
            out.flush()
            out.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    private val REQUEST_EXTERNAL_STORAGE = 1
    private val PERMISSIONS_STORAGE = arrayOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    )
    fun verifyStoragePermissions(activity: Activity?) {
        // Check if we have write permission
        val permission: Int = ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
        if (permission != PackageManager.PERMISSION_GRANTED) {
            // We don't have permission so prompt the user
            ActivityCompat.requestPermissions(
                    this,
                    PERMISSIONS_STORAGE,
                    REQUEST_EXTERNAL_STORAGE
            )
        }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            val uri: Uri = data.extras.getParcelable(ScanConstants.SCANNED_RESULT)
            var bitmap: Bitmap? = null
            try {
                bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri)
                contentResolver.delete(uri, null, null)
                SaveImage(bitmap);

//                scannedImageView.setImageBitmap(bitmap)
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }
}
