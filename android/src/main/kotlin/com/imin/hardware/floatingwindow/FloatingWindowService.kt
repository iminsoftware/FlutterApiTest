package com.imin.hardware.floatingwindow

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView

class FloatingWindowService : Service() {
    
    companion object {
        const val ACTION_SHOW = "com.imin.hardware.floatingwindow.SHOW"
        const val ACTION_HIDE = "com.imin.hardware.floatingwindow.HIDE"
        const val ACTION_UPDATE_TEXT = "com.imin.hardware.floatingwindow.UPDATE_TEXT"
        const val ACTION_SET_POSITION = "com.imin.hardware.floatingwindow.SET_POSITION"
        
        var isShowing = false
            private set
    }

    private var windowManager: WindowManager? = null
    private var floatingView: View? = null
    private var params: WindowManager.LayoutParams? = null
    private var tvFloating: TextView? = null

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> showFloatingWindow()
            ACTION_HIDE -> hideFloatingWindow()
            ACTION_UPDATE_TEXT -> {
                val text = intent.getStringExtra("text")
                updateText(text ?: "")
            }
            ACTION_SET_POSITION -> {
                val x = intent.getIntExtra("x", 0)
                val y = intent.getIntExtra("y", 100)
                setPosition(x, y)
            }
        }
        return START_STICKY
    }

    private fun showFloatingWindow() {
        if (isShowing) return

        try {
            // Create layout params
            val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }

            params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                layoutFlag,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
            )

            params?.gravity = Gravity.TOP or Gravity.START
            params?.x = 0
            params?.y = 100

            // Inflate the floating view layout
            floatingView = createFloatingView()

            // Add the view to the window
            windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
            windowManager?.addView(floatingView, params)

            isShowing = true
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun createFloatingView(): View {
        // Create a simple TextView as floating window
        val textView = TextView(this).apply {
            text = "Floating Window"
            textSize = 16f
            setPadding(32, 16, 32, 16)
            setBackgroundColor(0xCC2196F3.toInt()) // Semi-transparent blue
            setTextColor(0xFFFFFFFF.toInt()) // White text
        }

        tvFloating = textView

        // Set touch listener for dragging
        textView.setOnTouchListener(object : View.OnTouchListener {
            private var lastAction = 0
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f

            override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                event ?: return false
                params ?: return false

                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params!!.x
                        initialY = params!!.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        lastAction = event.action
                        return true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (lastAction == MotionEvent.ACTION_DOWN) {
                            // Handle click event if needed
                        }
                        lastAction = event.action
                        return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params!!.x = initialX + (event.rawX - initialTouchX).toInt()
                        params!!.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager?.updateViewLayout(floatingView, params)
                        lastAction = event.action
                        return true
                    }
                }
                return false
            }
        })

        return textView
    }

    private fun hideFloatingWindow() {
        if (!isShowing) return

        try {
            floatingView?.let {
                windowManager?.removeView(it)
            }
            floatingView = null
            tvFloating = null
            isShowing = false
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun updateText(text: String) {
        tvFloating?.text = text
    }

    private fun setPosition(x: Int, y: Int) {
        params?.let {
            it.x = x
            it.y = y
            floatingView?.let { view ->
                windowManager?.updateViewLayout(view, it)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        hideFloatingWindow()
    }
}
