package com.imin.scan.analyze;

import androidx.annotation.Nullable;

import com.imin.scan.DecodeConfig;
import com.imin.zxing.DecodeHintType;
import com.imin.zxing.Reader;
import com.imin.zxing.qrcode.QRCodeReader;

import java.util.Map;

public class QRCodeAnalyzer extends BarcodeFormatAnalyzer {

    public QRCodeAnalyzer() {
        this((DecodeConfig)null);
    }

    public QRCodeAnalyzer(@Nullable Map<DecodeHintType,Object> hints){
        this(new DecodeConfig().setHints(hints));
    }

    public QRCodeAnalyzer(@Nullable DecodeConfig config) {
        super(config);
    }

    @Override
    public Reader createReader() {
        return new QRCodeReader();
    }

}
