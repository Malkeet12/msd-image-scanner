package msd.image_scanner

//import com.scanlibrary.ScanConstants
import android.Manifest
import android.app.Activity
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.StrictMode
import android.os.StrictMode.VmPolicy
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants
import com.scanlibrary.Utils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.apache.commons.io.FileUtils
import org.json.JSONObject
import java.io.*

class MainActivity : FlutterActivity() {
    companion object {
        var channel: MethodChannel? = null
    }

    private var PICK_IMAGE_REQUEST_CODE: Int = 55
    private var currentGroupId: Any? = null
    private var fileUri: Uri? = null

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nativeToFlutter")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutterToNative")
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    when (call.method) {
                        "camera" -> {
                            val REQUEST_CODE = 99

                            currentGroupId = call.arguments
                            val preference: Int = ScanConstants.OPEN_CAMERA
                            val intent = Intent(this, ScanActivity::class.java)
                            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                            intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                            intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
                            startActivityForResult(intent, REQUEST_CODE)
                            result.success("message")

                        }
                        "gallery" -> {
                            currentGroupId = call.arguments
                            val intent: Intent
                            if (Build.VERSION.SDK_INT < 19) {
                                intent = Intent()
                                intent.action = Intent.ACTION_GET_CONTENT
                                intent.type = "*/*"
                                startActivityForResult(intent, PICK_IMAGE_REQUEST_CODE)
                            } else {
                                intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
                                intent.addCategory(Intent.CATEGORY_OPENABLE)
                                intent.type = "*/*"
                                startActivityForResult(intent, PICK_IMAGE_REQUEST_CODE)
                            }
                            result.success("message")

                        }
                        "getImages" -> {
                            val images = getImages()
                            if (images.isEmpty()) {
                                val list: MutableList<JSONObject> = ArrayList()
                                result.success(list.toString())
                            } else {
                                result.success(images.toString())
                            }
                        }
                        "getGroupImages" -> {
                            val images = getGroupImages(call.arguments as String)
                            if (images!!.isEmpty()) {
                                val list: MutableList<JSONObject> = ArrayList()
                                result.success(list.toString())
                            } else {
                                result.success(images.toString())
                            }
                        }
                        "addImageToGroup" -> {
                            val imgs = updateGroup(call.arguments as String)
                            if (imgs!!.isEmpty()) {
                                result.error("Empty", "No Images.", null)
                            } else {
                                result.success(imgs)
                            }
                        }
                        "saveAsPdf" -> {
                            var file= File("${call.arguments}")
                            val fileName: String = file.name
                            var src = file.absolutePath.substring(1, file.absolutePath.lastIndexOf("/"))
                            val root = Environment.getExternalStorageDirectory().absolutePath
                            var dest = "$root/digipaper/"
                            moveFile("$src/", "$fileName", "$dest")
                            result.success("$dest$fileName")
                        }
                        "deleteFile" -> {
                            val documentName = call.argument<String>("documentName")
                            val filePath = call.argument<String>("filePath")
                            var file= File(filePath)
                            var name=file.name

                            var success = deleteFile("$documentName", "$name")
                            result.success(success)
                        }
                        "deleteFolder" -> {
                            val documentName = call.arguments as String
                            val root = Environment.getExternalStorageDirectory().absolutePath
                            var path = "$root/digipaper/$documentName"
                            var success = FileUtils.deleteDirectory(File(path));
                            refreshUI()
                            result.success(true)
                        }
                        "renameDocument" -> {
                            val currentName = call.argument<String>("currentName")
                            val futureName = call.argument<String>("futureName")
                            val root = Environment.getExternalStorageDirectory().absolutePath
                            var currentFile= File("$root/digipaper/$currentName")

                            var destinationFile=File("$root/digipaper/$futureName");
                            try {
                              var res=  currentFile.renameTo(destinationFile);
                                if(res){
                                refreshUI()
                                result.success(true)
                                }else {
                                    result.success(false)
                                }
                            } catch (e: FileAlreadyExistsException) {
                                result.success(false)
                            } catch (e: java.lang.Exception) {
                                result.success(false)
                            }

                        }
                        "shareFile" -> {
                            val path = call.argument<String>("str")
                            val type = call.argument<String>("type")
                            shareFile("$path", "$type")
                        }
                        "shareMultipleFiles" -> {
                            val name = call.arguments
                            val root = Environment.getExternalStorageDirectory().absolutePath
                            val folder = File("$root/digipaper/$name/")
                            shareMultipleFiles(folder.listFiles())
                        }
                        "sendEmail" -> {
                            val emailIntent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:developer@eagertools.com"))
                            emailIntent.putExtra(Intent.EXTRA_SUBJECT, "digipaper")
                            emailIntent.putExtra(Intent.EXTRA_TEXT, "")
                            startActivity(Intent.createChooser(emailIntent, "Chooser Title"))
                        }
//                        "capture" -> {
//                            openCamera();
//                        }
                    }
                }
    }

    private fun shareMultipleFiles(filesToSend: Array<File>) {
        val builder = VmPolicy.Builder()
        StrictMode.setVmPolicy(builder.build())
        val intent = Intent()
        intent.action = Intent.ACTION_SEND_MULTIPLE
        intent.putExtra(Intent.EXTRA_SUBJECT, "Here are some files.")
        intent.type = "image/png"

        val files = ArrayList<Uri>()

        for (file in filesToSend) {
            val file = File(file.absolutePath)
            val uri = Uri.fromFile(file)
            intent.setClipData(ClipData.newRawUri("", uri))
            files.add(uri)
        }

        intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files)
        startActivity(intent)
    }

    private fun shareFile(str: String, type: String) {
        val builder = VmPolicy.Builder()
        StrictMode.setVmPolicy(builder.build())
        val share = Intent()
        share.action = Intent.ACTION_SEND
        share.type = type
        if (type != "text/plain") {
            val outputFile = File(str)
            var uri = Uri.fromFile(outputFile)
            share.setClipData(ClipData.newRawUri("", uri))
            share.putExtra(Intent.EXTRA_STREAM, uri)
        } else {
            share.putExtra(Intent.EXTRA_TEXT, str);
        }
        startActivity(Intent.createChooser(share, "Share"));
    }

    private fun deleteFile(documentName: String, fileName: String): Boolean {
        val root = Environment.getExternalStorageDirectory().absolutePath
        var file = File("$root/digipaper/$documentName", "$fileName")
        return file.delete()
    }

    private fun moveFile(inputPath: String, inputFile: String, outputPath: String) {
        var `in`: InputStream? = null
        var out: OutputStream? = null
        try {

            //create output directory if it doesn't exist
            val dir = File(outputPath)
            if (!dir.exists()) {
                dir.mkdirs()
            }
            `in` = FileInputStream(inputPath + inputFile)
            out = FileOutputStream(outputPath + inputFile)
            val buffer = ByteArray(1024)
            var read: Int
            while (`in`.read(buffer).also { read = it } != -1) {
                out.write(buffer, 0, read)
            }
            `in`.close()
            `in` = null

            // write the output file
            out.flush()
            out.close()
            out = null

            // delete the original file
            File(inputPath + inputFile).delete()
        } catch (fnfe1: FileNotFoundException) {
            println("exception");
        } catch (e: java.lang.Exception) {
            println(e.message)
        }
    }

    private fun getImages(): MutableList<JSONObject> {
        val root = Environment.getExternalStorageDirectory().absolutePath
        val folder = File("$root/digipaper/")
        folder.mkdirs()
        if (folder.listFiles() == null) return ArrayList()
        val directoryListing: Array<File> = folder.listFiles()
        val list: MutableList<JSONObject> = ArrayList()
//        val list: List<String> = MutableList()
        for (child in directoryListing) {
            if (child.isDirectory) {
                var first = true
                val item = JSONObject()
                if (child.isDirectory) {
                    val file = File("${child.absolutePath}")
                    var lastUpdatedTime = getLatestModifiedDate(file)
                    item.put("folderSize",folderSize(file))
                    item.put("lastUpdated", lastUpdatedTime)
                }
                for (file in child.listFiles()) {
                    if (first) {
                        first = false
                        if (file.isFile) {
                            var path = file.absolutePath.split("/")
                            val id = path[path.size - 2]
                            item.put("name", id)
                            item.put("firstChild", file.toString())
                            list.add(item)
                        }
                    }

                }
            }
        }
        return list
    }
    fun folderSize(directory: File): Long {
        var length: Long = 0
        for (file in directory.listFiles()) {
            length += if (file.isFile) file.length() else folderSize(file)
        }
        return length
    }
    // return mapOf("length" to length, "lastModifiefDate" to Math.max(latestDate, dir.lastModified()))
    private fun getLatestModifiedDate(dir: File): Long {
        val files = dir.listFiles()
        var latestDate: Long = 0
        for (file in files) {
            val fileModifiedDate = if (file.isDirectory) getLatestModifiedDate(file) else file.lastModified()
            if (fileModifiedDate > latestDate) {
                latestDate = fileModifiedDate
            }
        }
        return Math.max(latestDate, dir.lastModified())
    }


    private fun updateGroup(groupId: String): List<String>? {
        val root = Environment.getExternalStorageDirectory().absolutePath
        val folder = File("$root/digipaper/$groupId")
//        folder.mkdirs()
        val allFiles: Array<File> = folder.listFiles(object : FilenameFilter {
            override fun accept(dir: File?, name: String): Boolean {
                return name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png")
            }
        })

        val item: MutableList<String> = ArrayList()
        for (file in allFiles) {
            item.add(file.toString() + "")
        }
        return item
    }

    private fun getGroupImages(groupId: String): MutableList<JSONObject> {
        val root = Environment.getExternalStorageDirectory().absolutePath
        val folder = File("$root/digipaper/$groupId")
//        folder.mkdirs()
        val allFiles: Array<File> = folder.listFiles(object : FilenameFilter {
            override fun accept(dir: File?, name: String): Boolean {
                return name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png")
            }
        })

        val list: MutableList<JSONObject> = ArrayList()
        for (file in allFiles) {
            val item = JSONObject()
            item.put("path", file.toString())
            item.put("lastUpdated", file.lastModified())
            list.add(item)
        }
        return list
    }

    //
    private fun SaveImage(finalBitmap: Bitmap) {
        verifyStoragePermissions(this)
        val root = Environment.getExternalStorageDirectory().absolutePath
        val myDir = File("$root/digipaper")
        if (!myDir.exists()) {
            myDir.mkdirs()
        }
        var currentFolder = ""
        currentFolder = if (currentGroupId != "" && currentGroupId != null) {
            currentGroupId as String
        } else {
            "digipaper${System.currentTimeMillis().toString()}"
        }
        val imageGroupDir = File("$root/digipaper/$currentFolder")
        if (!imageGroupDir.exists()) {
            imageGroupDir.mkdirs()
        }
        var time = System.currentTimeMillis()
        val fname = "$time.jpg"
        val file = File(imageGroupDir, fname)
        if (file.exists()) file.delete()
        try {
            val out = FileOutputStream(file)
            finalBitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
            if (currentGroupId != "" && currentGroupId != null) {
                refreshCurrentDoc()
            }
            refreshUI()

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

    fun refreshCurrentDoc() {
        channel?.invokeMethod("refreshCurrentDoc", "",
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        println("successfully went to dart")
                    }

                    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                        println(errorDetails)
                    }

                    override fun notImplemented() {
                        println("not implememted")
                    }
                }
        )
    }

    fun refreshUI() {
        channel?.invokeMethod("refreshUI", "",
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        println("successfully went to dart")
                    }

                    override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                        println(errorDetails)
                    }

                    override fun notImplemented() {
                        println("not implememted")
                    }
                }
        )
    }

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
            var bitmap: Bitmap? = null
            if(requestCode==PICK_IMAGE_REQUEST_CODE){
                val uri = data.data
                try {
                    bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri)
                    val preference: Int = ScanConstants.OPEN_MEDIA
                    val intent = Intent(this, ScanActivity::class.java)
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                    val uri: Uri = Utils.getUri(activity, bitmap)
                    intent.putExtra("image", uri)
                    intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
                    startActivityForResult(intent, 100)
//                    SaveImage(bitmap);
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }else{
                val uri: Uri = data.extras.getParcelable(ScanConstants.SCANNED_RESULT)
                try {
                    bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri)
                    contentResolver.delete(uri, null, null)
                    SaveImage(bitmap);

                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }

        }
    }
}
