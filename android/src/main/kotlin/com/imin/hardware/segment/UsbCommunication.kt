package com.imin.hardware.segment

import android.content.Context
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbManager
import android.text.TextUtils
import android.util.Log
import java.nio.ByteBuffer

class UsbCommunication(private val context: Context) {
    private val TAG = "UsbCommunication"
    
    companion object {
        private const val HEADER_BYTE_1: Byte = 0xFC.toByte()
        private const val HEADER_BYTE_2: Byte = 0xFC.toByte()
    }
    
    private var usbManager: UsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
    private var usbDevice: UsbDevice? = null
    private var connection: UsbDeviceConnection? = null
    private var endpointOut: UsbEndpoint? = null
    private var endpointIn: UsbEndpoint? = null
    private var isNeedRead = false
    
    fun connectToDevice(device: UsbDevice): Boolean {
        this.usbDevice = device
        
        // 获取设备接口
        val usbInterface = device.getInterface(0)
        
        // 打开连接
        connection = usbManager.openDevice(device)
        if (connection == null) {
            Log.e(TAG, "Failed to open device connection")
            return false
        }
        
        // 声明接口
        connection?.claimInterface(usbInterface, true)
        
        // 查找输入输出端点
        for (i in 0 until usbInterface.endpointCount) {
            val endpoint = usbInterface.getEndpoint(i)
            if (endpoint.direction == UsbConstants.USB_DIR_OUT) {
                endpointOut = endpoint
            } else if (endpoint.direction == UsbConstants.USB_DIR_IN) {
                endpointIn = endpoint
            }
        }
        
        return endpointOut != null && endpointIn != null
    }
    
    fun sendData(cmd: Byte, data: String): Boolean {
        if (connection == null || endpointOut == null) {
            Log.e(TAG, "Connection or endpoint not available")
            return false
        }
        
        val dataLength: Int
        val dataBytes: ByteArray
        
        if (TextUtils.isEmpty(data)) {
            dataLength = 2
            dataBytes = ByteArray(0)
        } else {
            // 数据长度检查，最多 9 个字符
            val trimmedData = if (data.length > 9) data.substring(0, 9) else data
            dataBytes = trimmedData.toByteArray()
            // 计算数据包长度：len = cmd + data + chk
            dataLength = 1 + dataBytes.size + 1
        }
        
        val len = dataLength.toByte()
        
        // 构建数据包
        val buffer = ByteBuffer.allocate(3 + dataLength) // header(2) + len(1) + dataLength
        buffer.put(HEADER_BYTE_1)
        buffer.put(HEADER_BYTE_2)
        buffer.put(len)
        buffer.put(cmd)
        buffer.put(dataBytes)
        
        // 计算校验和
        val checksum = calculateChecksum(len, cmd, dataBytes)
        buffer.put(checksum)
        
        // 发送数据
        val result = connection?.bulkTransfer(endpointOut, buffer.array(), buffer.array().size, 5000) ?: -1
        return result == buffer.array().size
    }
    
    fun receiveData(): ByteArray? {
        if (connection == null || endpointIn == null) {
            return null
        }
        
        val buffer = ByteArray(64)
        val received = connection?.bulkTransfer(endpointIn, buffer, buffer.size, 5000) ?: -1
        
        if (received > 0) {
            val result = ByteArray(received)
            System.arraycopy(buffer, 0, result, 0, received)
            if (result[0] != 5.toByte()) {
                Log.d(TAG, "Received data: ${result.contentToString()}")
            }
            return result
        }
        
        return null
    }
    
    private fun calculateChecksum(len: Byte, cmd: Byte, data: ByteArray): Byte {
        var sum = (len.toInt() and 0xFF) + (cmd.toInt() and 0xFF)
        
        for (b in data) {
            sum += (b.toInt() and 0xFF)
        }
        
        return (sum and 0xFF).toByte()
    }
    
    fun parseReceivedData(data: ByteArray): Boolean {
        if (data.size < 5) {
            return false
        }
        
        // 检查头部
        if (data[0] != HEADER_BYTE_1 || data[1] != HEADER_BYTE_2) {
            return false
        }
        
        // 获取长度
        val len = data[2]
        if (data.size != 3 + (len.toInt() and 0xFF)) {
            return false
        }
        
        // 获取命令
        val cmd = data[3]
        
        // 获取数据部分
        val dataLength = (len.toInt() and 0xFF) - 2 // 减去 cmd 和 chk
        val receivedData = ByteArray(dataLength)
        System.arraycopy(data, 4, receivedData, 0, dataLength)
        
        // 获取校验和
        val receivedChecksum = data[data.size - 1]
        
        // 计算校验和验证
        val calculatedChecksum = calculateChecksum(len, cmd, receivedData)
        
        return receivedChecksum == calculatedChecksum
    }
    
    fun startRead() {
        isNeedRead = true
        Thread {
            while (isNeedRead) {
                receiveData()
                try {
                    Thread.sleep(800)
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                }
            }
        }.start()
    }
    
    fun closeConnection() {
        isNeedRead = false
        connection?.close()
        connection = null
    }
}
