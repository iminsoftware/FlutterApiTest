package com.imin.hardware.camera

/**
 * Scan Result data class
 */
data class ScanResult(
    val text: String,
    val format: String,
    val rawBytes: ByteArray? = null
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as ScanResult

        if (text != other.text) return false
        if (format != other.format) return false
        if (rawBytes != null) {
            if (other.rawBytes == null) return false
            if (!rawBytes.contentEquals(other.rawBytes)) return false
        } else if (other.rawBytes != null) return false

        return true
    }

    override fun hashCode(): Int {
        var result = text.hashCode()
        result = 31 * result + format.hashCode()
        result = 31 * result + (rawBytes?.contentHashCode() ?: 0)
        return result
    }
}
