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
import com.imin.zxing.common.HybridBinarizer;

import java.io.IOException;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;
import java.util.Vector;

public class ScanUtils {

    private ScanUtils() {

    }

    public void destroy() {
        if (mediaPlayer != null){
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    public static class InnerHolder {
        public static final ScanUtils instance = new ScanUtils();
    }
    public static ScanUtils getInstance(Context context) {
        mContext = context;
        return InnerHolder.instance;
    }
    private boolean playBeep = false;//false 关闭声音  true开启声音
    private boolean vibrate;
    private static Context mContext;

    public boolean isPlayBeep() {
        return playBeep;
    }

    //获取扫描结果
    public ScanUtils setPlayBeep(boolean playBeep) {
        this.playBeep = playBeep;
        return this;
    }

    public boolean isVibrate() {
        return vibrate;
    }

    public ScanUtils setVibrate(boolean vibrate) {
        this.vibrate = vibrate;
        return this;
    }

    public String getCharacterSet() {
        return characterSet;
    }

    //设置编码格式
    public ScanUtils setCharacterSet(String characterSet) {
        this.characterSet = characterSet;
        return this;
    }
    static Map<Integer,BarcodeFormat> barcodeFormatMap;
    static {
        barcodeFormatMap = new HashMap<>();
        barcodeFormatMap.put(Symbol.AZTEC,BarcodeFormat.AZTEC);
        barcodeFormatMap.put(Symbol.CODABAR,BarcodeFormat.CODABAR);
        barcodeFormatMap.put(Symbol.CODE_39,BarcodeFormat.CODE_39);
        barcodeFormatMap.put(Symbol.CODE_93,BarcodeFormat.CODE_93);
        barcodeFormatMap.put(Symbol.CODE_128,BarcodeFormat.CODE_128);
        barcodeFormatMap.put(Symbol.DATA_MATRIX,BarcodeFormat.DATA_MATRIX);
        barcodeFormatMap.put(Symbol.EAN_8,BarcodeFormat.EAN_8);
        barcodeFormatMap.put(Symbol.EAN_13,BarcodeFormat.EAN_13);
        barcodeFormatMap.put(Symbol.ITF,BarcodeFormat.ITF);
        barcodeFormatMap.put(Symbol.MAXICODE,BarcodeFormat.MAXICODE);
        barcodeFormatMap.put(Symbol.PDF_417,BarcodeFormat.PDF_417);
        barcodeFormatMap.put(Symbol.QR_CODE,BarcodeFormat.QR_CODE);
        barcodeFormatMap.put(Symbol.RSS_14,BarcodeFormat.RSS_14);
        barcodeFormatMap.put(Symbol.RSS_EXPANDED,BarcodeFormat.RSS_EXPANDED);
        barcodeFormatMap.put(Symbol.UPC_A,BarcodeFormat.UPC_A);
        barcodeFormatMap.put(Symbol.UPC_E,BarcodeFormat.UPC_E);
        barcodeFormatMap.put(Symbol.UPC_EAN_EXTENSION,BarcodeFormat.UPC_EAN_EXTENSION);
    }

    public void setConfig(int config){
        if (decodeFormats == null || decodeFormats.isEmpty()) {
            decodeFormats = new Vector<>();
        }
        if (config == Symbol.ALL_FORMATS){
           decodeFormats.addAll(DecodeFormatManager.ALL_FORMATS);
        }
        if (config == Symbol.ONE_D_FORMATS){
            decodeFormats.addAll(DecodeFormatManager.ONE_D_FORMATS);
        }
        if (config == Symbol.QR_CODE_FORMATS){
            decodeFormats.addAll(DecodeFormatManager.QR_CODE_FORMATS);
        }
        if (config == Symbol.DATA_MATRIX_FORMATS){
            decodeFormats.addAll(DecodeFormatManager.DATA_MATRIX_FORMATS);
        }

        decodeFormats.add(barcodeFormatMap.get(config));
        initFormat();
    }
    public void initScan(){
        decode_count = 0;
    }
    private MultiFormatReader multiFormatReader;
    private Hashtable<DecodeHintType, Object> hints;
    private Vector<BarcodeFormat> decodeFormats;
    private String characterSet;
    //配置识别码类型
    private void initFormat() {
        hints = new Hashtable<DecodeHintType, Object>();

//        if (decodeFormats == null || decodeFormats.isEmpty()) {
//            decodeFormats = new Vector<BarcodeFormat>();
//            decodeFormats.addAll(DecodeFormatManager.ONE_D_FORMATS);
//            decodeFormats.addAll(DecodeFormatManager.QR_CODE_FORMATS);
//            decodeFormats.addAll(DecodeFormatManager.DATA_MATRIX_FORMATS);
//        }
        Log.i("ssssssss", "扫描结果-decodeFormats====》 :" + playBeep+"    "+decodeFormats.size());


        hints.put(DecodeHintType.POSSIBLE_FORMATS, decodeFormats);

        if (characterSet != null) {
            hints.put(DecodeHintType.CHARACTER_SET, characterSet);
        }
        multiFormatReader = new MultiFormatReader();
        multiFormatReader.setHints(hints);
        //hints.put(DecodeHintType.NEED_RESULT_POINT_CALLBACK, null);

    }
    public Result getScanResult(byte[] data,int width,int height){
        Result rawResult = null;
        LuminanceSource source;
        if (!Build.MODEL.equals("I22T01") && !Build.MODEL.equals("D1") && !Build.MODEL.equals("D1-Pro") && !Build.MODEL.equals("TF1-11")){
            //图片转换方向
            byte[] rotatedData = new byte[data.length];
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++)
                    rotatedData[x * height + height - y - 1] = data[x + y * width];
            }
            int tmp = width;
            width = height;
            height = tmp;
            data = rotatedData;
        }
        source = new PlanarYUVLuminanceSource(data, width, height, 0, 0, width, height, false);

        try {
            //二值化后的位图数据
            BinaryBitmap tempBitmap = new BinaryBitmap(new HybridBinarizer(source));
            startTimeMillis = System.currentTimeMillis();
            rawResult = multiFormatReader.decodeWithState(tempBitmap);
            if (rawResult != null){
                long endTimeMillis = System.currentTimeMillis();
                cost_time = endTimeMillis-startTimeMillis;
                decode_count++;
                nsyms = 1;
                playBeepSoundAndVibrate();//解码成功播放提示音
            }

        } catch (ReaderException re) {
//                    Log.i("ssssssss", "扫描结果====》 :" + re.getMessage());
        } finally {
            multiFormatReader.reset();
        }
        return rawResult;
    }

    int nsyms;//解码，返回值为0代表失败，>0表示成功
    long cost_time;//开始解码图片 到获取扫码结果的时间差
    int decode_count = 0;//目前扫码的次数

    public long getCost_time() {
        return cost_time;
    }

    public void setCost_time(long cost_time) {
        this.cost_time = cost_time;
    }

    public int getNsyms() {
        return nsyms;
    }

    public void setNsyms(int nsyms) {
        this.nsyms = nsyms;
    }

    public long getStartTimeMillis() {
        return startTimeMillis;
    }

    private long startTimeMillis;

    //开始执行扫描的时间
    public void setStartTimeMillis(long startTimeMillis) {
        this.startTimeMillis = startTimeMillis;
    }

    private MediaPlayer mediaPlayer;
    //初始化声音播放器
    public void initBeepSound(boolean isPlayBeep,int raw){
        this.playBeep = isPlayBeep;
        if (playBeep && mediaPlayer == null) {
            // The volume on STREAM_SYSTEM is not adjustable, and users found it
            // too loud,
            // so we now play on the music stream.
            mediaPlayer = new MediaPlayer();
            mediaPlayer.reset();
//            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mediaPlayer.setOnCompletionListener(beepListener);
            AssetFileDescriptor file = mContext.getResources().openRawResourceFd(
                    raw);
            try {
                mediaPlayer.setDataSource(file.getFileDescriptor(),
                        file.getStartOffset(), file.getLength());
                mediaPlayer.prepareAsync();
                file.close();
            } catch (IOException e) {
                mediaPlayer = null;

            }
        }
    }

    private static final long VIBRATE_DURATION = 200L;
    //开启播放声音
    public void playBeepSoundAndVibrate() {
        Log.i("ssssssss", "扫描结果-playBeepSoundAndVibrate====》 :" + playBeep+"    "+(mediaPlayer != null));
        if (playBeep && mediaPlayer != null) {
            mediaPlayer.start();
        }
        if (vibrate) {
            Vibrator vibrator = (Vibrator) mContext.getSystemService(VIBRATOR_SERVICE);
            vibrator.vibrate(VIBRATE_DURATION);
        }
    }
    /**
     * When the beep has finished playing, rewind to queue up another one.
     */
    private final MediaPlayer.OnCompletionListener beepListener = mediaPlayer -> mediaPlayer.seekTo(0);
}
