package com.imin.scan;

import android.util.Log;

import com.google.mlkit.vision.barcode.Barcode;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScannerOptions;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;
import com.imin.zxing.BarcodeFormat;

import java.util.ArrayList;
import java.util.List;

/**
 * ML Kit 解码器，纯异步回调方式。
 */
class MLKitDecoder {

    private static final String TAG = "MLKitDecoder";
    private BarcodeScanner scanner;
    private volatile boolean processing = false;

    MLKitDecoder() {
        BarcodeScannerOptions options = new BarcodeScannerOptions.Builder()
                .setBarcodeFormats(Barcode.FORMAT_ALL_FORMATS)
                .build();
        scanner = BarcodeScanning.getClient(options);
        Log.i(TAG, "ML Kit BarcodeScanner initialized");
    }

    boolean isProcessing() {
        return processing;
    }

    interface SingleCallback {
        void onResult(Result result, long costTime);
    }

    interface MultiCallback {
        void onResult(List<Result> results, long costTime);
    }

    /**
     * 异步解码单条码，结果通过回调返回（回调在主线程）
     */
    void decodeSingle(byte[] data, int width, int height, SingleCallback callback) {
        if (processing || scanner == null) return;
        processing = true;
        long startTime = System.currentTimeMillis();
        try {
            InputImage image = InputImage.fromByteArray(
                    data, width, height, 0, InputImage.IMAGE_FORMAT_NV21);
            scanner.process(image)
                    .addOnSuccessListener(barcodes -> {
                        processing = false;
                        if (barcodes != null && !barcodes.isEmpty()) {
                            long costTime = System.currentTimeMillis() - startTime;
                            callback.onResult(toResult(barcodes.get(0)), costTime);
                        }
                    })
                    .addOnFailureListener(e -> {
                        processing = false;
                        Log.w(TAG, "MLKit decode error: " + e.getMessage());
                    });
        } catch (Exception e) {
            processing = false;
            Log.w(TAG, "MLKit submit error: " + e.getMessage());
        }
    }

    /**
     * 异步解码多条码
     */
    void decodeMultiple(byte[] data, int width, int height, MultiCallback callback) {
        if (processing || scanner == null) return;
        processing = true;
        long startTime = System.currentTimeMillis();
        try {
            InputImage image = InputImage.fromByteArray(
                    data, width, height, 0, InputImage.IMAGE_FORMAT_NV21);
            scanner.process(image)
                    .addOnSuccessListener(barcodes -> {
                        processing = false;
                        if (barcodes != null && !barcodes.isEmpty()) {
                            long costTime = System.currentTimeMillis() - startTime;
                            List<Result> results = new ArrayList<>();
                            for (Barcode barcode : barcodes) {
                                Result r = toResult(barcode);
                                if (r != null) results.add(r);
                            }
                            callback.onResult(results, costTime);
                        }
                    })
                    .addOnFailureListener(e -> {
                        processing = false;
                        Log.w(TAG, "MLKit multi-decode error: " + e.getMessage());
                    });
        } catch (Exception e) {
            processing = false;
            Log.w(TAG, "MLKit submit error: " + e.getMessage());
        }
    }

    void close() {
        if (scanner != null) {
            scanner.close();
            scanner = null;
        }
    }

    private Result toResult(Barcode barcode) {
        String text = barcode.getRawValue() != null ? barcode.getRawValue() : "";
        byte[] rawBytes = barcode.getRawBytes();
        BarcodeFormat format = mapFormat(barcode.getFormat());
        return new Result(text, rawBytes, null, format);
    }

    private BarcodeFormat mapFormat(int f) {
        switch (f) {
            case Barcode.FORMAT_QR_CODE: return BarcodeFormat.QR_CODE;
            case Barcode.FORMAT_AZTEC: return BarcodeFormat.AZTEC;
            case Barcode.FORMAT_CODABAR: return BarcodeFormat.CODABAR;
            case Barcode.FORMAT_CODE_39: return BarcodeFormat.CODE_39;
            case Barcode.FORMAT_CODE_93: return BarcodeFormat.CODE_93;
            case Barcode.FORMAT_CODE_128: return BarcodeFormat.CODE_128;
            case Barcode.FORMAT_DATA_MATRIX: return BarcodeFormat.DATA_MATRIX;
            case Barcode.FORMAT_EAN_8: return BarcodeFormat.EAN_8;
            case Barcode.FORMAT_EAN_13: return BarcodeFormat.EAN_13;
            case Barcode.FORMAT_ITF: return BarcodeFormat.ITF;
            case Barcode.FORMAT_PDF417: return BarcodeFormat.PDF_417;
            case Barcode.FORMAT_UPC_A: return BarcodeFormat.UPC_A;
            case Barcode.FORMAT_UPC_E: return BarcodeFormat.UPC_E;
            default: return BarcodeFormat.QR_CODE;
        }
    }
}
