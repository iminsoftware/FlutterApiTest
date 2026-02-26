package com.imin.scan.analyze;

import androidx.annotation.Nullable;

import com.imin.scan.DecodeConfig;
import com.imin.scan.Result;
import com.imin.scan.util.LogUtils;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.LuminanceSource;
import com.imin.zxing.PlanarYUVLuminanceSource;
import com.imin.zxing.Reader;
import com.imin.zxing.common.GlobalHistogramBinarizer;
import com.imin.zxing.common.HybridBinarizer;

import java.util.Map;

public abstract class BarcodeFormatAnalyzer extends AreaRectAnalyzer {

    private Reader mReader;

    public BarcodeFormatAnalyzer(@Nullable Map<DecodeHintType,Object> hints){
        this(new DecodeConfig().setHints(hints));
    }

    public BarcodeFormatAnalyzer(@Nullable DecodeConfig config) {
        super(config);
        initReader();
    }

    private void initReader(){
        mReader = createReader();
    }

    @Nullable
    @Override
    public Result analyze(byte[] data, int dataWidth, int dataHeight, int left, int top, int width, int height) {
        Result rawResult = null;
        if(mReader != null){
            try {
                long start = System.currentTimeMillis();
                PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(data,dataWidth,dataHeight,left,top,width,height,false);
                rawResult = decodeInternal(source,isMultiDecode);

                if(rawResult == null && mDecodeConfig != null){
                    if(rawResult == null && mDecodeConfig.isSupportVerticalCode()){
                        byte[] rotatedData = new byte[data.length];
                        for (int y = 0; y < dataHeight; y++) {
                            for (int x = 0; x < dataWidth; x++){
                                rotatedData[x * dataHeight + dataHeight - y - 1] = data[x + y * dataWidth];
                            }
                        }
                        rawResult = decodeInternal(new PlanarYUVLuminanceSource(rotatedData,dataHeight,dataWidth,top,left,height,width,false),mDecodeConfig.isSupportVerticalCodeMultiDecode());
                    }

                    if(mDecodeConfig.isSupportLuminanceInvert()){
                        rawResult = decodeInternal(source.invert(),mDecodeConfig.isSupportLuminanceInvertMultiDecode());
                    }
                }
                if(rawResult != null){
                    long end = System.currentTimeMillis();
                    LogUtils.d("Found barcode in " + (end - start) + " ms");
                }
            } catch (Exception e) {

            }finally {
                mReader.reset();
            }
        }
        return rawResult;
    }

    private Result decodeInternal(LuminanceSource source, boolean isMultiDecode){
        Result result = null;
        try{
            try{
                //采用HybridBinarizer解析
                result = mReader.decode(new BinaryBitmap(new HybridBinarizer(source)),mHints);
            }catch (Exception e){

            }
            if(isMultiDecode && result == null){
                //如果没有解析成功，再采用GlobalHistogramBinarizer解析一次
                result = mReader.decode(new BinaryBitmap(new GlobalHistogramBinarizer(source)),mHints);
            }
        }catch (Exception e){

        }
        return result;
    }

    public abstract Reader createReader();

}
