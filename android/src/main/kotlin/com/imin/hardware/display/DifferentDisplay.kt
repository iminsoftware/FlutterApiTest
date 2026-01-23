package com.imin.hardware.display

import android.annotation.SuppressLint
import android.app.Presentation
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Display
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.VideoView
import com.bumptech.glide.Glide
import java.io.File
import java.io.FileOutputStream

@SuppressLint("NewApi")
class DifferentDisplay(outerContext: Context, display: Display) : Presentation(outerContext, display) {
    
    private lateinit var rootLayout: LinearLayout
    private lateinit var titleText: TextView
    private lateinit var contentText: TextView
    private lateinit var contentLayout: LinearLayout
    private lateinit var imageView: ImageView
    private lateinit var videoView: VideoView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Set window type to keep display visible even when main activity goes to background
        if (Build.VERSION.SDK_INT >= 32) {
            // Android 12+ (API 32+)
            // No special window type needed
        } else if (Build.VERSION.SDK_INT >= 26) {
            // Android 8.0+ (API 26-31)
            window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
        } else {
            // Android 7.1 and below
            @Suppress("DEPRECATION")
            window?.setType(WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY)
        }
        
        createLayout()
    }

    private fun createLayout() {
        // Create root layout
        rootLayout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(0xFFFFFFFF.toInt())
        }

        // Title TextView
        titleText = TextView(context).apply {
            text = "Secondary Display"
            textSize = 20f
            setTextColor(0xFF000000.toInt())
            gravity = android.view.Gravity.CENTER
            setPadding(0, 20, 0, 20)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        rootLayout.addView(titleText)

        // Content TextView
        contentText = TextView(context).apply {
            textSize = 16f
            setTextColor(0xFF000000.toInt())
            setPadding(40, 20, 40, 20)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        rootLayout.addView(contentText)

        // Content layout for image and video
        contentLayout = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = android.view.Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            ).apply {
                setMargins(20, 20, 20, 20)
            }
        }

        // ImageView
        imageView = ImageView(context).apply {
            visibility = View.GONE
            scaleType = ImageView.ScaleType.FIT_CENTER
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        }
        contentLayout.addView(imageView)

        // VideoView
        videoView = VideoView(context).apply {
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        }
        contentLayout.addView(videoView)

        rootLayout.addView(contentLayout)
        setContentView(rootLayout)
    }

    fun showText(text: String) {
        contentText.post {
            contentText.text = text
            contentText.visibility = View.VISIBLE
            imageView.visibility = View.GONE
            videoView.visibility = View.GONE
        }
    }

    fun showImage(context: Context, imagePath: String) {
        imageView.post {
            try {
                if (imagePath.startsWith("http://") || imagePath.startsWith("https://")) {
                    // 网络图片 - 使用 Glide
                    Log.d("DifferentDisplay", "Loading network image: $imagePath")
                    Glide.with(context)
                        .load(imagePath)
                        .fitCenter()
                        .into(imageView)
                } else {
                    // 本地 asset 图片 - 使用 BitmapFactory
                    Log.d("DifferentDisplay", "Loading local image: $imagePath")
                    val inputStream = context.assets.open(imagePath)
                    val bitmap = android.graphics.BitmapFactory.decodeStream(inputStream)
                    inputStream.close()
                    
                    if (bitmap != null) {
                        imageView.setImageBitmap(bitmap)
                    } else {
                        Log.e("DifferentDisplay", "Failed to decode bitmap")
                    }
                }
                
                contentText.visibility = View.GONE
                imageView.visibility = View.VISIBLE
                videoView.visibility = View.GONE
            } catch (e: Exception) {
                Log.e("DifferentDisplay", "Error loading image: ${e.message}")
            }
        }
    }

    fun playVideo(context: Context, videoPath: String) {
        videoView.post {
            try {
                if (videoPath.startsWith("http://") || videoPath.startsWith("https://")) {
                    // 网络视频 - 直接播放
                    Log.d("DifferentDisplay", "Playing network video: $videoPath")
                    videoView.setVideoURI(Uri.parse(videoPath))
                } else {
                    // 本地 asset 视频 - 复制到临时文件
                    Log.d("DifferentDisplay", "Playing local asset video: $videoPath")
                    val inputStream = context.assets.open(videoPath)
                    val tempFile = File(context.cacheDir, "temp_video.mp4")
                    val outputStream = FileOutputStream(tempFile)
                    inputStream.copyTo(outputStream)
                    inputStream.close()
                    outputStream.close()
                    videoView.setVideoURI(Uri.fromFile(tempFile))
                }

                videoView.setOnPreparedListener { mp ->
                    mp.isLooping = true
                    mp.start()
                }

                contentText.visibility = View.GONE
                imageView.visibility = View.GONE
                videoView.visibility = View.VISIBLE
            } catch (e: Exception) {
                Log.e("DifferentDisplay", "Error playing video: ${e.message}")
            }
        }
    }

    fun clear() {
        contentText.post {
            contentText.text = ""
            contentText.visibility = View.GONE
            imageView.visibility = View.GONE
            videoView.visibility = View.GONE
            videoView.stopPlayback()
            imageView.setImageBitmap(null)
            
            try {
                Glide.with(context).clear(imageView)
            } catch (e: Exception) {
                Log.e("DifferentDisplay", "Error clearing Glide: ${e.message}")
            }
        }
    }
}
