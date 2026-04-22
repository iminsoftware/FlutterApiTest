package com.imin.scan.analyze;

import androidx.annotation.Nullable;

import com.imin.scan.DecodeConfig;
import com.imin.scan.Result;
import com.imin.scan.util.LogUtils;
import com.imin.zxing.BinaryBitmap;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.LuminanceSource;
import com.imin.zxing.MultiFormatReader;
import com.imin.zxing.PlanarYUVLuminanceSource;
import com.imin.zxing.common.GlobalHistogramBinarizer;
import com.imin.zxing.common.HybridBinarizer;

import java.util.Map;

public class MultiFormatAnalyzer extends AreaRectAnalyzer {

    MultiFormatReader mReader;

    public MultiFormatAnalyzer(){
        this((DecodeConfig)null);
    }

    public MultiFormatAnalyzer(@Nullable Map<DecodeHintType,Object> hints){
        this(new DecodeConfig().setHints(hints));
    }

    public MultiFormatAnalyzer(@Nullable DecodeConfig config) {
        super(config);
        initReader();
    }

    private void initReader(){
        mReader = new MultiFormatReader();
        // setHints只在初始化时调用一次，避免每帧重建所有Reader对象
        mReader.setHints(mHints);
    }

    @Nullable
    @Override
    public Result analyze(byte[] data, int dataWidth, int dataHeight, int left, int top, int width, int height) {
        Result rawResult = null;
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

                if(rawResult == null && mDecodeConfig.isSupportLuminanceInvert()){
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
        return rawResult;
    }


    private Result decodeInternal(LuminanceSource source, boolean isMultiDecode){
        Result result = null;
        try{
            try{
                //采用HybridBinarizer解析
                result = mReader.decodeWithState(new BinaryBitmap(new HybridBinarizer(source)));
            }catch (Exception e){

            }
            if(isMultiDecode && result == null){
                //如果没有解析成功，再采用GlobalHistogramBinarizer解析一次
                result = mReader.decodeWithState(new BinaryBitmap(new GlobalHistogramBinarizer(source)));
            }
        }catch (Exception e){

        }
        return result;
    }
}
