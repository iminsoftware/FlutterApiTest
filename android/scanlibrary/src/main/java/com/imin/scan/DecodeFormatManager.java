package com.imin.scan;

import androidx.annotation.NonNull;

import com.imin.zxing.BarcodeFormat;
import com.imin.zxing.DecodeHintType;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;
import java.util.regex.Pattern;

public class DecodeFormatManager {
    /**
     * 所有的
     */
    public static final Map<DecodeHintType,Object> ALL_HINTS = new EnumMap<>(DecodeHintType.class);
    /**
     * CODE_128 (最常用的一维码)
     */
    public static final Map<DecodeHintType,Object> CODE_128_HINTS = createDecodeHint(BarcodeFormat.CODE_128);
    /**
     * QR_CODE (最常用的二维码)
     */
    public static final Map<DecodeHintType,Object> QR_CODE_HINTS = createDecodeHint(BarcodeFormat.QR_CODE);
    /**
     * 一维码
     */
    public static final Map<DecodeHintType,Object> ONE_DIMENSIONAL_HINTS = new EnumMap<>(DecodeHintType.class);
    /**
     * 二维码
     */
    public static final Map<DecodeHintType,Object> TWO_DIMENSIONAL_HINTS = new EnumMap<>(DecodeHintType.class);

    /**
     * 默认
     */
    public static final Map<DecodeHintType,Object> DEFAULT_HINTS = new EnumMap<>(DecodeHintType.class);

    static {
        //all hints
        addDecodeHintTypes(ALL_HINTS,getAllFormats());
        //one dimension
        addDecodeHintTypes(ONE_DIMENSIONAL_HINTS,getOneDimensionalFormats());
        //Two dimension
        addDecodeHintTypes(TWO_DIMENSIONAL_HINTS,getTwoDimensionalFormats());
        //default hints
        addDecodeHintTypes(DEFAULT_HINTS,getDefaultFormats());
    }

    /**
     * 所有支持的{@link BarcodeFormat}
     * @return
     */
    private static List<BarcodeFormat> getAllFormats(){
        List<BarcodeFormat> list = new ArrayList<>();
        list.add(BarcodeFormat.AZTEC);
        list.add(BarcodeFormat.CODABAR);
        list.add(BarcodeFormat.CODE_39);
        list.add(BarcodeFormat.CODE_93);
        list.add(BarcodeFormat.CODE_128);
        list.add(BarcodeFormat.DATA_MATRIX);
        list.add(BarcodeFormat.EAN_8);
        list.add(BarcodeFormat.EAN_13);
        list.add(BarcodeFormat.ITF);
        list.add(BarcodeFormat.MAXICODE);
        list.add(BarcodeFormat.PDF_417);
        list.add(BarcodeFormat.QR_CODE);
        list.add(BarcodeFormat.RSS_14);
        list.add(BarcodeFormat.RSS_EXPANDED);
        list.add(BarcodeFormat.UPC_A);
        list.add(BarcodeFormat.UPC_E);
        list.add(BarcodeFormat.UPC_EAN_EXTENSION);
        return list;
    }

    /**
     * 二维码
     * 包括如下几种格式：
     *  {@link BarcodeFormat#CODABAR}
     *  {@link BarcodeFormat#CODE_39}
     *  {@link BarcodeFormat#CODE_93}
     *  {@link BarcodeFormat#CODE_128}
     *  {@link BarcodeFormat#EAN_8}
     *  {@link BarcodeFormat#EAN_13}
     *  {@link BarcodeFormat#ITF}
     *  {@link BarcodeFormat#RSS_14}
     *  {@link BarcodeFormat#RSS_EXPANDED}
     *  {@link BarcodeFormat#UPC_A}
     *  {@link BarcodeFormat#UPC_E}
     *  {@link BarcodeFormat#UPC_EAN_EXTENSION}
     * @return
     */
    private static List<BarcodeFormat> getOneDimensionalFormats(){
        List<BarcodeFormat> list = new ArrayList<>();
        list.add(BarcodeFormat.CODABAR);
        list.add(BarcodeFormat.CODE_39);
        list.add(BarcodeFormat.CODE_93);
        list.add(BarcodeFormat.CODE_128);
        list.add(BarcodeFormat.EAN_8);
        list.add(BarcodeFormat.EAN_13);
        list.add(BarcodeFormat.ITF);
        list.add(BarcodeFormat.RSS_14);
        list.add(BarcodeFormat.RSS_EXPANDED);
        list.add(BarcodeFormat.UPC_A);
        list.add(BarcodeFormat.UPC_E);
        list.add(BarcodeFormat.UPC_EAN_EXTENSION);
        return list;
    }

    /**
     * 二维码
     * 包括如下几种格式：
     *  {@link BarcodeFormat#AZTEC}
     *  {@link BarcodeFormat#DATA_MATRIX}
     *  {@link BarcodeFormat#MAXICODE}
     *  {@link BarcodeFormat#PDF_417}
     *  {@link BarcodeFormat#QR_CODE}
     * @return
     */
    private static List<BarcodeFormat> getTwoDimensionalFormats(){
        List<BarcodeFormat> list = new ArrayList<>();
        list.add(BarcodeFormat.AZTEC);
        list.add(BarcodeFormat.DATA_MATRIX);
        list.add(BarcodeFormat.MAXICODE);
        list.add(BarcodeFormat.PDF_417);
        list.add(BarcodeFormat.QR_CODE);
        return list;
    }

    /**
     * 默认支持的格式
     * 包括如下几种格式：
     *  {@link BarcodeFormat#QR_CODE}
     *  {@link BarcodeFormat#UPC_A}
     *  {@link BarcodeFormat#EAN_13}
     *  {@link BarcodeFormat#CODE_128}
     * @return
     */
    private static List<BarcodeFormat> getDefaultFormats(){
        List<BarcodeFormat> list = new ArrayList<>();
        list.add(BarcodeFormat.QR_CODE);
        list.add(BarcodeFormat.UPC_A);
        list.add(BarcodeFormat.EAN_13);
        list.add(BarcodeFormat.CODE_128);
        return list;
    }

    private static <T> List<T> singletonList(T o){
        return Collections.singletonList(o);
    }

    /**
     * 支持解码的格式
     * @param barcodeFormats {@link BarcodeFormat}
     * @return
     */
    public static Map<DecodeHintType,Object> createDecodeHints(@NonNull BarcodeFormat... barcodeFormats){
        Map<DecodeHintType,Object> hints = new EnumMap<>(DecodeHintType.class);
        addDecodeHintTypes(hints, Arrays.asList(barcodeFormats));
        return hints;
    }

    /**
     * 支持解码的格式
     * @param barcodeFormat {@link BarcodeFormat}
     * @return
     */
    public static Map<DecodeHintType,Object> createDecodeHint(@NonNull BarcodeFormat barcodeFormat){
        Map<DecodeHintType,Object> hints = new EnumMap<>(DecodeHintType.class);
        addDecodeHintTypes(hints,singletonList(barcodeFormat));
        return hints;
    }

    /**
     *
     * @param hints
     * @param formats
     */
    private static void addDecodeHintTypes(Map<DecodeHintType,Object> hints,List<BarcodeFormat> formats){
        // Image is known to be of one of a few possible formats.
        hints.put(DecodeHintType.POSSIBLE_FORMATS, formats);
        // Spend more time to try to find a barcode; optimize for accuracy, not speed.
        hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
        // Specifies what character encoding to use when decoding, where applicable (type String)
        hints.put(DecodeHintType.CHARACTER_SET, "UTF-8");
    }

    private static final Pattern COMMA_PATTERN = Pattern.compile(",");

    //public static final Vector<BarcodeFormat> PRODUCT_FORMATS;
    public static final Vector<BarcodeFormat> ONE_D_FORMATS;
    public static final Vector<BarcodeFormat> QR_CODE_FORMATS;
    public static final Vector<BarcodeFormat> DATA_MATRIX_FORMATS;
    public static final Vector<BarcodeFormat> ALL_FORMATS;
    static {
        ALL_FORMATS = new Vector<>();
        for (int i=0;i<getAllFormats().size();i++){
            ALL_FORMATS.add(getAllFormats().get(i));
        }
        ONE_D_FORMATS = new Vector<BarcodeFormat>();
        for (int i=0;i<getOneDimensionalFormats().size();i++){
            ONE_D_FORMATS.add(getOneDimensionalFormats().get(i));
        }
        QR_CODE_FORMATS = new Vector<BarcodeFormat>(1);
        for (int i=0;i<getTwoDimensionalFormats().size();i++){
            QR_CODE_FORMATS.add(getTwoDimensionalFormats().get(i));
        }
        DATA_MATRIX_FORMATS = new Vector<BarcodeFormat>(1);
        DATA_MATRIX_FORMATS.add(BarcodeFormat.DATA_MATRIX);
    }

    private DecodeFormatManager() {}

//    static Vector<BarcodeFormat> parseDecodeFormats(Intent intent) {
//        List<String> scanFormats = null;
//        String scanFormatsString = intent.getStringExtra(Intents.Scan.SCAN_FORMATS);
//        if (scanFormatsString != null) {
//            scanFormats = Arrays.asList(COMMA_PATTERN.split(scanFormatsString));
//        }
//        return parseDecodeFormats(scanFormats, intent.getStringExtra(Intents.Scan.MODE));
//    }
//
//    static Vector<BarcodeFormat> parseDecodeFormats(Uri inputUri) {
//        List<String> formats = inputUri.getQueryParameters(Intents.Scan.SCAN_FORMATS);
//        if (formats != null && formats.size() == 1 && formats.get(0) != null){
//            formats = Arrays.asList(COMMA_PATTERN.split(formats.get(0)));
//        }
//        return parseDecodeFormats(formats, inputUri.getQueryParameter(Intents.Scan.MODE));
//    }

//    private static Vector<BarcodeFormat> parseDecodeFormats(Iterable<String> scanFormats,
//                                                            String decodeMode) {
//        if (scanFormats != null) {
//            Vector<BarcodeFormat> formats = new Vector<BarcodeFormat>();
//            try {
//                for (String format : scanFormats) {
//                    formats.add(BarcodeFormat.valueOf(format));
//                }
//                return formats;
//            } catch (IllegalArgumentException iae) {
//                // ignore it then
//            }
//        }
//        if (decodeMode != null) {
//            if (Intents.Scan.PRODUCT_MODE.equals(decodeMode)) {
//                return PRODUCT_FORMATS;
//            }
//            if (Intents.Scan.QR_CODE_MODE.equals(decodeMode)) {
//                return QR_CODE_FORMATS;
//            }
//            if (Intents.Scan.DATA_MATRIX_MODE.equals(decodeMode)) {
//                return DATA_MATRIX_FORMATS;
//            }
//            if (Intents.Scan.ONE_D_MODE.equals(decodeMode)) {
//                return ONE_D_FORMATS;
//            }
//        }
//        return null;
//    }
}
