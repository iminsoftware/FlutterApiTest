package com.imin.scan;

import static android.content.Context.VIBRATOR_SERVICE;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Vibrator;
import android.util.Log;

import com.imin.zxing.BarcodeFormat;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.LuminanceSource;
import com.imin.zxing.MultiFormatReader;
import com.imin.zxing.PlanarYUVLuminanceSource;
import com.imin.zxing.ReaderException;
import com.imin.zxing.common.GlobalHistogramBinarizer;
import com.imin.zxing.common.HybridBinarizer;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Vector;

public class ScanUtils {

    private static final String TAG = "ScanUtils";

    /** 解码引擎：ZXing（默认，纯本地，兼容性最好） */
    public static final int ENGINE_ZXING = 0;
    /** 解码引擎：ML Kit（任意角度/多条码/速度快，需要客户额外引入ML Kit依赖） */
    public static final int ENGINE_MLKIT = 1;

    /** ML Kit 运行时可用性缓存 */
    private static Boolean sMLKitAvailable;

    private ScanUtils() {
    }

    public void destroy() {
        if (mediaPlayer != null) {
            mediaPlayer.release();
            mediaPlayer = null;
        }
        if (mlkitDecoder != null) {
            mlkitDecoder.close();
            mlkitDecoder = null;
        }
    }

    public static class InnerHolder {
        public static final ScanUtils instance = new ScanUtils();
    }

    public static ScanUtils getInstance(Context context) {
        mContext = context;
        return InnerHolder.instance;
    }

    // ==================== ML Kit 运行时可用性检测 ====================

    /**
     * 检测 ML Kit 是否在运行时可用
     * 通过尝试加载关键类来判断，结果缓存
     */
    public static boolean isMLKitAvailable() {
        if (sMLKitAvailable != null) return sMLKitAvailable;
        try {
            Class.forName("com.google.mlkit.vision.barcode.BarcodeScanning");
            sMLKitAvailable = true;
        } catch (ClassNotFoundException e) {
            sMLKitAvailable = false;
            Log.w(TAG, "ML Kit not available. Add: implementation 'com.google.mlkit:barcode-scanning:17.0.0'");
        }
        return sMLKitAvailable;
    }

    private boolean shouldUseMLKit() {
        return decodeEngine == ENGINE_MLKIT && isMLKitAvailable();
    }

    // ==================== 属性 ====================
    private boolean playBeep = false;
    private boolean vibrate;
    private static Context mContext;

    private int decodeEngine = ENGINE_ZXING;
    private boolean supportVerticalCode = false;
    private boolean supportMultiAngle = false;
    private boolean supportMultiBarcode = false;
    private float areaRectRatio = 0.8f;
    private boolean fullAreaScan = true;
    private volatile boolean isDecoding = false;

    /** ML Kit 解码器，独立类隔离依赖，只在 ML Kit 可用时才加载 */
    private MLKitDecoder mlkitDecoder;

    // ==================== getter/setter ====================

    public boolean isPlayBeep() { return playBeep; }
    public ScanUtils setPlayBeep(boolean playBeep) { this.playBeep = playBeep; return this; }
    public boolean isVibrate() { return vibrate; }
    public ScanUtils setVibrate(boolean vibrate) { this.vibrate = vibrate; return this; }
    public String getCharacterSet() { return characterSet; }
    public ScanUtils setCharacterSet(String characterSet) { this.characterSet = characterSet; return this; }

    /**
     * 设置解码引擎
     * 如果设置为 ENGINE_MLKIT 但客户未引入 ML Kit 依赖，会自动降级为 ZXing
     */
    public ScanUtils setDecodeEngine(int engine) {
        if (engine == ENGINE_MLKIT) {
            if (isMLKitAvailable()) {
                this.decodeEngine = engine;
                ensureMLKitDecoder();
            } else {
                Log.w(TAG, "ML Kit not available, falling back to ZXing");
                this.decodeEngine = ENGINE_ZXING;
            }
        } else {
            this.decodeEngine = engine;
        }
        return this;
    }

    public int getDecodeEngine() { return decodeEngine; }

    public boolean isSupportVerticalCode() { return supportVerticalCode; }
    public ScanUtils setSupportVerticalCode(boolean v) { this.supportVerticalCode = v; return this; }

    public boolean isSupportMultiAngle() { return supportMultiAngle; }
    /**
     * 开启多角度识别，ML Kit 可用时自动切换引擎
     */
    public ScanUtils setSupportMultiAngle(boolean v) {
        this.supportMultiAngle = v;
        if (v) autoSwitchToMLKit();
        return this;
    }

    public boolean isSupportMultiBarcode() { return supportMultiBarcode; }
    /**
     * 开启多条码识别，ML Kit 可用时自动切换引擎
     */
    public ScanUtils setSupportMultiBarcode(boolean v) {
        this.supportMultiBarcode = v;
        if (v) autoSwitchToMLKit();
        return this;
    }

    public float getAreaRectRatio() { return areaRectRatio; }
    public ScanUtils setAreaRectRatio(float r) {
        this.areaRectRatio = Math.max(0.5f, Math.min(1.0f, r)); return this;
    }
    public boolean isFullAreaScan() { return fullAreaScan; }
    public ScanUtils setFullAreaScan(boolean v) { this.fullAreaScan = v; return this; }
    public boolean isDecoding() { return isDecoding; }

    private void autoSwitchToMLKit() {
        if (decodeEngine != ENGINE_MLKIT && isMLKitAvailable()) {
            Log.i(TAG, "Auto-switching to ML Kit engine");
            this.decodeEngine = ENGINE_MLKIT;
            ensureMLKitDecoder();
        }
    }

    private void ensureMLKitDecoder() {
        if (mlkitDecoder == null && isMLKitAvailable()) {
            try {
                mlkitDecoder = new MLKitDecoder();
            } catch (NoClassDefFoundError e) {
                Log.e(TAG, "Failed to load MLKitDecoder: " + e.getMessage());
                sMLKitAvailable = false;
                decodeEngine = ENGINE_ZXING;
            }
        }
    }

    // ==================== ZXing 格式映射与初始化 ====================

    static Map<Integer, BarcodeFormat> barcodeFormatMap;
    static {
        barcodeFormatMap = new HashMap<>();
        barcodeFormatMap.put(Symbol.AZTEC, BarcodeFormat.AZTEC);
        barcodeFormatMap.put(Symbol.CODABAR, BarcodeFormat.CODABAR);
        barcodeFormatMap.put(Symbol.CODE_39, BarcodeFormat.CODE_39);
        barcodeFormatMap.put(Symbol.CODE_93, BarcodeFormat.CODE_93);
        barcodeFormatMap.put(Symbol.CODE_128, BarcodeFormat.CODE_128);
        barcodeFormatMap.put(Symbol.DATA_MATRIX, BarcodeFormat.DATA_MATRIX);
        barcodeFormatMap.put(Symbol.EAN_8, BarcodeFormat.EAN_8);
        barcodeFormatMap.put(Symbol.EAN_13, BarcodeFormat.EAN_13);
        barcodeFormatMap.put(Symbol.ITF, BarcodeFormat.ITF);
        barcodeFormatMap.put(Symbol.MAXICODE, BarcodeFormat.MAXICODE);
        barcodeFormatMap.put(Symbol.PDF_417, BarcodeFormat.PDF_417);
        barcodeFormatMap.put(Symbol.QR_CODE, BarcodeFormat.QR_CODE);
        barcodeFormatMap.put(Symbol.RSS_14, BarcodeFormat.RSS_14);
        barcodeFormatMap.put(Symbol.RSS_EXPANDED, BarcodeFormat.RSS_EXPANDED);
        barcodeFormatMap.put(Symbol.UPC_A, BarcodeFormat.UPC_A);
        barcodeFormatMap.put(Symbol.UPC_E, BarcodeFormat.UPC_E);
        barcodeFormatMap.put(Symbol.UPC_EAN_EXTENSION, BarcodeFormat.UPC_EAN_EXTENSION);
    }

    public void setConfig(int config) {
        if (decodeFormats == null || decodeFormats.isEmpty()) {
            decodeFormats = new Vector<>();
        }
        if (config == Symbol.ALL_FORMATS) decodeFormats.addAll(DecodeFormatManager.ALL_FORMATS);
        if (config == Symbol.ONE_D_FORMATS) decodeFormats.addAll(DecodeFormatManager.ONE_D_FORMATS);
        if (config == Symbol.QR_CODE_FORMATS) decodeFormats.addAll(DecodeFormatManager.QR_CODE_FORMATS);
        if (config == Symbol.DATA_MATRIX_FORMATS) decodeFormats.addAll(DecodeFormatManager.DATA_MATRIX_FORMATS);
        decodeFormats.add(barcodeFormatMap.get(config));
        initFormat();
    }

    public void initScan() { decode_count = 0; }

    private MultiFormatReader multiFormatReader;
    private Hashtable<DecodeHintType, Object> hints;
    private Vector<BarcodeFormat> decodeFormats;
    private String characterSet;

    private void initFormat() {
        hints = new Hashtable<>();
        hints.put(DecodeHintType.POSSIBLE_FORMATS, decodeFormats);
        hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
        hints.put(DecodeHintType.CHARACTER_SET, characterSet != null ? characterSet : "UTF-8");
        multiFormatReader = new MultiFormatReader();
        multiFormatReader.setHints(hints);
    }

    // ==================== 核心解码方法（ZXing 同步，保持原有行为） ====================

    /**
     * 获取扫码结果（单条码，同步，ZXing引擎）
     * 方法签名与原版完全一致，客户零改动
     */
    public Result getScanResult(byte[] data, int width, int height) {
        if (isDecoding) return null;
        isDecoding = true;
        try {
            return getScanResultZxing(data, width, height);
        } finally {
            isDecoding = false;
        }
    }

    /**
     * 获取扫码结果（多条码，同步，ZXing引擎）
     */
    public List<Result> getScanResults(byte[] data, int width, int height) {
        List<Result> results = new ArrayList<>();
        if (!supportMultiBarcode) {
            Result single = getScanResult(data, width, height);
            if (single != null) results.add(single);
            return results;
        }
        if (isDecoding) return results;
        isDecoding = true;
        try {
            data = rotateForDevice(data, width, height);
            if (deviceNeedsRotate()) { int t = width; width = height; height = t; }
            startTimeMillis = System.currentTimeMillis();
            try {
                com.imin.zxing.multi.GenericMultipleBarcodeReader multiReader =
                        new com.imin.zxing.multi.GenericMultipleBarcodeReader(multiFormatReader);
                LuminanceSource source = new PlanarYUVLuminanceSource(data, width, height, 0, 0, width, height, false);
                BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
                Result[] multiResults = multiReader.decodeMultiple(bitmap, hints);
                if (multiResults != null) for (Result r : multiResults) results.add(r);
            } catch (Exception e) { } finally { multiFormatReader.reset(); }
            if (results.isEmpty()) {
                Result single = decodeFull(data, width, height);
                if (single != null) results.add(single);
            }
            if (!results.isEmpty()) {
                cost_time = System.currentTimeMillis() - startTimeMillis;
                decode_count++; nsyms = results.size(); playBeepSoundAndVibrate();
            }
        } finally { isDecoding = false; }
        return results;
    }

    // ==================== ML Kit 异步解码方法（新增） ====================

    /**
     * 扫码结果回调接口
     */
    public interface OnScanResultListener {
        void onResult(Result result, long costTime);
    }

    /**
     * 多条码扫码结果回调接口
     */
    public interface OnScanResultsListener {
        void onResult(List<Result> results, long costTime);
    }

    /** 上次扫码结果文本，用于去重 */
    private String lastScanText = "";
    /** 上次扫码结果时间 */
    private long lastScanTime = 0;
    /** 同一个码的去重间隔（毫秒），默认2秒 */
    private long deduplicateInterval = 2000;

    /**
     * 设置同一个码的去重间隔（毫秒）
     * 在此间隔内扫到相同内容的码不会重复触发回调和声音
     * 设置为0则不去重（每次都触发）
     */
    public ScanUtils setDeduplicateInterval(long ms) {
        this.deduplicateInterval = ms;
        return this;
    }

    private boolean isDuplicate(String text) {
        if (deduplicateInterval <= 0) return false;
        long now = System.currentTimeMillis();
        if (text != null && text.equals(lastScanText) && (now - lastScanTime) < deduplicateInterval) {
            return true;
        }
        lastScanText = text;
        lastScanTime = now;
        return false;
    }

    /**
     * 多条码去重：将所有码内容排序拼接后做判断
     * 这样即使码的顺序不同，只要内容一样就认为是重复
     */
    private boolean isDuplicateMulti(List<Result> results) {
        if (deduplicateInterval <= 0) return false;
        StringBuilder key = new StringBuilder();
        List<String> texts = new ArrayList<>();
        for (Result r : results) {
            texts.add(r.getText() != null ? r.getText() : "");
        }
        java.util.Collections.sort(texts);
        for (String t : texts) {
            key.append(t).append("|");
        }
        return isDuplicate(key.toString());
    }

    /**
     * ML Kit 异步解码单条码（推荐用于需要多角度识别的场景）
     *
     * 回调在主线程执行，可直接更新UI。
     * 同一个码在 deduplicateInterval 内不会重复触发。
     * 如果 ML Kit 不可用，自动降级为 ZXing 同步解码并回调。
     *
     * 用法示例：
     * scanUtils.scanAsync(data, width, height, (result, costTime) -> {
     *     textView.setText(result.toString());
     * });
     */
    public void scanAsync(byte[] data, int width, int height, OnScanResultListener listener) {
        if (listener == null) return;
        ensureMLKitDecoder();
        if (mlkitDecoder != null && !mlkitDecoder.isProcessing()) {
            mlkitDecoder.decodeSingle(data, width, height, (result, costTime) -> {
                if (isDuplicate(result.getText())) return;
                cost_time = costTime;
                decode_count++; nsyms = 1; playBeepSoundAndVibrate();
                listener.onResult(result, costTime);
            });
        } else if (mlkitDecoder == null) {
            // ML Kit 不可用，降级 ZXing
            Result result = getScanResult(data, width, height);
            if (result != null && !isDuplicate(result.getText())) {
                listener.onResult(result, cost_time);
            }
        }
    }

    /**
     * ML Kit 异步解码多条码
     *
     * 用法示例：
     * scanUtils.scanMultiAsync(data, width, height, (results, costTime) -> {
     *     for (Result r : results) { ... }
     * });
     */
    public void scanMultiAsync(byte[] data, int width, int height, OnScanResultsListener listener) {
        if (listener == null) return;
        ensureMLKitDecoder();
        if (mlkitDecoder != null && !mlkitDecoder.isProcessing()) {
            mlkitDecoder.decodeMultiple(data, width, height, (results, costTime) -> {
                if (isDuplicateMulti(results)) return;
                cost_time = costTime;
                decode_count++; nsyms = results.size(); playBeepSoundAndVibrate();
                listener.onResult(results, costTime);
            });
        } else if (mlkitDecoder == null) {
            List<Result> results = getScanResults(data, width, height);
            if (!results.isEmpty() && !isDuplicateMulti(results)) {
                listener.onResult(results, cost_time);
            }
        }
    }

    // ==================== ZXing 引擎 ====================

    private boolean deviceNeedsRotate() {
        return !Build.MODEL.equals("I22T01") && !Build.MODEL.equals("D1")
                && !Build.MODEL.equals("D1-Pro") && !Build.MODEL.equals("TF1-11");
    }

    private byte[] rotateForDevice(byte[] data, int width, int height) {
        if (deviceNeedsRotate()) {
            return rotateData90(data, width, height);
        }
        return data;
    }

    private Result getScanResultZxing(byte[] data, int width, int height) {
        Result rawResult = null;
        data = rotateForDevice(data, width, height);
        if (deviceNeedsRotate()) { int t = width; width = height; height = t; }

        startTimeMillis = System.currentTimeMillis();
        rawResult = decodeWithArea(data, width, height);

        if (rawResult == null && supportMultiAngle) {
            byte[] r90 = rotateData90(data, width, height);
            rawResult = decodeWithArea(r90, height, width);
            if (rawResult == null) {
                byte[] r180 = rotateData180(data, width, height);
                rawResult = decodeWithArea(r180, width, height);
            }
            if (rawResult == null) {
                byte[] r270 = rotateData270(data, width, height);
                rawResult = decodeWithArea(r270, height, width);
            }
        } else if (rawResult == null && supportVerticalCode) {
            byte[] r90 = rotateData90(data, width, height);
            rawResult = decodeWithArea(r90, height, width);
        }

        if (rawResult != null) {
            cost_time = System.currentTimeMillis() - startTimeMillis;
            decode_count++; nsyms = 1; playBeepSoundAndVibrate();
        }
        return rawResult;
    }

    private Result decodeWithArea(byte[] data, int width, int height) {
        if (fullAreaScan || areaRectRatio >= 1.0f) return decodeFull(data, width, height);
        int size = (int) (Math.min(width, height) * areaRectRatio);
        int left = (width - size) / 2;
        int top = (height - size) / 2;
        Result result = decodeRegion(data, width, height, left, top, size, size);
        if (result == null) result = decodeFull(data, width, height);
        return result;
    }

    private Result decodeFull(byte[] data, int width, int height) {
        return decodeRegion(data, width, height, 0, 0, width, height);
    }

    private Result decodeRegion(byte[] data, int dataWidth, int dataHeight,
                                int left, int top, int width, int height) {
        Result rawResult = null;
        try {
            PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(
                    data, dataWidth, dataHeight, left, top, width, height, false);
            try {
                rawResult = multiFormatReader.decodeWithState(new BinaryBitmap(new HybridBinarizer(source)));
            } catch (ReaderException re) { } finally { multiFormatReader.reset(); }
            if (rawResult == null) {
                try {
                    rawResult = multiFormatReader.decodeWithState(new BinaryBitmap(new GlobalHistogramBinarizer(source)));
                } catch (ReaderException re) { } finally { multiFormatReader.reset(); }
            }
        } catch (Exception e) { }
        return rawResult;
    }

    // ==================== 旋转工具方法 ====================

    private byte[] rotateData90(byte[] data, int width, int height) {
        byte[] rotated = new byte[width * height];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                rotated[x * height + height - y - 1] = data[x + y * width];
        return rotated;
    }

    private byte[] rotateData180(byte[] data, int width, int height) {
        byte[] rotated = new byte[width * height];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                rotated[(height - 1 - y) * width + (width - 1 - x)] = data[y * width + x];
        return rotated;
    }

    private byte[] rotateData270(byte[] data, int width, int height) {
        byte[] rotated = new byte[width * height];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                rotated[(width - 1 - x) * height + y] = data[x + y * width];
        return rotated;
    }

    // ==================== 统计字段 ====================

    int nsyms;
    long cost_time;
    int decode_count = 0;
    private long startTimeMillis;

    public long getCost_time() { return cost_time; }
    public void setCost_time(long v) { this.cost_time = v; }
    public int getNsyms() { return nsyms; }
    public void setNsyms(int v) { this.nsyms = v; }
    public long getStartTimeMillis() { return startTimeMillis; }
    public void setStartTimeMillis(long v) { this.startTimeMillis = v; }

    // ==================== 音频与震动 ====================

    private MediaPlayer mediaPlayer;
    private static final long VIBRATE_DURATION = 200L;

    public void initBeepSound(boolean isPlayBeep, int raw) {
        this.playBeep = isPlayBeep;
        if (playBeep && mediaPlayer == null) {
            mediaPlayer = new MediaPlayer();
            mediaPlayer.reset();
            mediaPlayer.setOnCompletionListener(beepListener);
            AssetFileDescriptor file = mContext.getResources().openRawResourceFd(raw);
            try {
                mediaPlayer.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
                mediaPlayer.prepareAsync();
                file.close();
            } catch (IOException e) { mediaPlayer = null; }
        }
    }

    public void playBeepSoundAndVibrate() {
        if (playBeep && mediaPlayer != null) mediaPlayer.start();
        if (vibrate) {
            Vibrator v = (Vibrator) mContext.getSystemService(VIBRATOR_SERVICE);
            v.vibrate(VIBRATE_DURATION);
        }
    }

    private final MediaPlayer.OnCompletionListener beepListener = mp -> mp.seekTo(0);
}
