package com.imin.hardware.serial

import android.content.Context
import android.util.Log
import com.neostra.serialport.SerialPort
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

/**
 * Serial Port Handler for iMin devices
 * 
 * Based on IMinApiTest SerialActivity implementation
 * Uses NeoStra SerialPort SDK for serial communication
 */
class SerialHandler(
    private val context: Context,
    private val eventChannel: EventChannel
) : EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "SerialHandler"
        private const val BUFFER_SIZE = 512
        
        init {
            try {
                // Disable su usage for serial port access
                // This prevents "Cannot run program /system/xbin/su" error
                SerialPort.setSuPath("")
            } catch (e: Exception) {
                Log.w(TAG, "Failed to set su path", e)
            }
        }
    }

    private var serialPort: SerialPort? = null
    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var readThread: ReadThread? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isReading = false

    init {
        // Set event stream handler
        eventChannel.setStreamHandler(this)
        Log.d(TAG, "SerialHandler initialized")
    }

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "serial.open" -> openPort(call, result)
            "serial.close" -> closePort(result)
            "serial.write" -> writeData(call, result)
            "serial.isOpen" -> checkOpen(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Open serial port
     * 
     * Parameters:
     * - path: Serial port device path (e.g., "/dev/ttyS4")
     * - baudRate: Baud rate (default: 115200)
     */
    private fun openPort(call: MethodCall, result: Result) {
        try {
            val path = call.argument<String>("path")
            val baudRate = call.argument<Int>("baudRate") ?: 115200
            
            if (path.isNullOrEmpty()) {
                result.error("INVALID_ARGUMENT", "Serial port path is required", null)
                return
            }
            
            // Close existing port if open
            if (serialPort != null) {
                closePortInternal()
            }
            
            // Try to open serial port
            // Method 1: Using File object (recommended)
            try {
                val file = java.io.File(path)
                serialPort = SerialPort(file, baudRate, 0)
                Log.d(TAG, "Opened serial port using File object")
            } catch (e: Exception) {
                Log.w(TAG, "Failed to open with File object, trying String path", e)
                // Method 2: Using String path (fallback)
                serialPort = SerialPort(path, baudRate)
                Log.d(TAG, "Opened serial port using String path")
            }
            
            inputStream = serialPort?.inputStream
            outputStream = serialPort?.outputStream
            
            if (inputStream == null || outputStream == null) {
                result.error("OPEN_FAILED", "Failed to get input/output streams", null)
                return
            }
            
            // Start reading thread
            startReading()
            
            Log.d(TAG, "Serial port opened: $path @ $baudRate")
            result.success(true)
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception opening serial port", e)
            result.error("SECURITY_ERROR", "Permission denied: ${e.message}", null)
        } catch (e: IOException) {
            Log.e(TAG, "IO exception opening serial port", e)
            result.error("IO_ERROR", "Failed to open port: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening serial port", e)
            result.error("OPEN_FAILED", e.message, null)
        }
    }

    /**
     * Close serial port
     */
    private fun closePort(result: Result) {
        try {
            closePortInternal()
            Log.d(TAG, "Serial port closed")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error closing serial port", e)
            result.error("CLOSE_FAILED", e.message, null)
        }
    }

    /**
     * Write data to serial port
     * 
     * Parameters:
     * - data: Byte array to write
     */
    private fun writeData(call: MethodCall, result: Result) {
        try {
            val data = call.argument<ByteArray>("data")
            
            if (data == null || data.isEmpty()) {
                result.error("INVALID_ARGUMENT", "Data is required", null)
                return
            }
            
            if (outputStream == null) {
                result.error("NOT_OPEN", "Serial port is not open", null)
                return
            }
            
            outputStream?.write(data)
            outputStream?.flush()
            
            Log.d(TAG, "Wrote ${data.size} bytes to serial port")
            result.success(true)
        } catch (e: IOException) {
            Log.e(TAG, "IO exception writing to serial port", e)
            result.error("WRITE_FAILED", e.message, null)
        } catch (e: Exception) {
            Log.e(TAG, "Error writing to serial port", e)
            result.error("WRITE_FAILED", e.message, null)
        }
    }

    /**
     * Check if serial port is open
     */
    private fun checkOpen(result: Result) {
        val isOpen = serialPort != null && inputStream != null && outputStream != null
        result.success(isOpen)
    }

    /**
     * Start reading thread (same as IMinApiTest)
     */
    private fun startReading() {
        if (readThread != null && isReading) {
            return
        }
        
        isReading = true
        readThread = ReadThread()
        readThread?.start()
        Log.d(TAG, "Started reading thread")
    }

    /**
     * Stop reading thread
     */
    private fun stopReading() {
        isReading = false
        readThread?.interrupt()
        readThread = null
        Log.d(TAG, "Stopped reading thread")
    }

    /**
     * Internal method to close port
     */
    private fun closePortInternal() {
        stopReading()
        
        try {
            inputStream?.close()
            inputStream = null
        } catch (e: IOException) {
            Log.e(TAG, "Error closing input stream", e)
        }
        
        try {
            outputStream?.close()
            outputStream = null
        } catch (e: IOException) {
            Log.e(TAG, "Error closing output stream", e)
        }
        
        serialPort = null
    }

    /**
     * Reading thread (same as IMinApiTest)
     */
    private inner class ReadThread : Thread() {
        override fun run() {
            val buffer = ByteArray(BUFFER_SIZE)
            
            while (isReading && !isInterrupted) {
                try {
                    Thread.sleep(50)
                    
                    val stream = inputStream
                    if (stream == null) {
                        Log.d(TAG, "Input stream is null, stopping read thread")
                        break
                    }
                    
                    if (stream.available() > 0) {
                        val size = stream.read(buffer)
                        if (size > 0) {
                            val data = buffer.copyOf(size)
                            
                            // Send data to Flutter via EventChannel
                            eventSink?.success(mapOf(
                                "event" to "data",
                                "data" to data.toList(),
                                "timestamp" to System.currentTimeMillis()
                            ))
                            
                            Log.d(TAG, "Read $size bytes from serial port")
                        }
                    } else {
                        Thread.sleep(1000)
                    }
                } catch (e: InterruptedException) {
                    Log.d(TAG, "Read thread interrupted")
                    break
                } catch (e: IOException) {
                    Log.e(TAG, "IO exception reading from serial port", e)
                    eventSink?.error("READ_ERROR", e.message, null)
                    break
                } catch (e: Exception) {
                    Log.e(TAG, "Error reading from serial port", e)
                    break
                }
            }
            
            Log.d(TAG, "Read thread stopped")
        }
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "Event stream listener attached")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d(TAG, "Event stream listener detached")
    }

    fun cleanup() {
        try {
            closePortInternal()
            eventChannel.setStreamHandler(null)
            eventSink = null
            Log.d(TAG, "SerialHandler cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}

