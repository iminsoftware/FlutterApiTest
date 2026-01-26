package com.imin.scan;

public interface Symbol {
    int ALL_FORMATS = 0;//所有 都支持
    int ONE_D_FORMATS = 20; //一维码
    int QR_CODE_FORMATS = 21;//二维码
    int DATA_MATRIX_FORMATS = 22;//DATA_MATRIX
    int PRODUCT_FORMATS = 23;//PRODUCT
    /** Aztec 2D barcode format. */
    int AZTEC = 1;

    /** CODABAR 1D format. */
    int CODABAR = 2;

    /** Code 39 1D format. */
    int CODE_39 = 3;

    /** Code 93 1D format. */
    int CODE_93 = 4;

    /** Code 128 1D format. */
    int CODE_128 = 5;

    /** Data Matrix 2D barcode format. */
    int DATA_MATRIX = 6;

    /** EAN-8 1D format. */
    int EAN_8 = 7;

    /** EAN-13 1D format. */
    int EAN_13 = 8;

    /** ITF (Interleaved Two of Five) 1D format. */
    int ITF = 9;

    /** MaxiCode 2D barcode format. */
    int MAXICODE = 10;

    /** PDF417 format. */
    int PDF_417 = 11;

    /** QR Code 2D barcode format. */
    int QR_CODE = 12;

    /** RSS 14 */
    int RSS_14 = 13;

    /** RSS EXPANDED */
    int RSS_EXPANDED = 14;

    /** UPC-A 1D format. */
    int UPC_A = 15;

    /** UPC-E 1D format. */
    int UPC_E = 16;

    /** UPC/EAN extension format. Not a stand-alone format. */
    int UPC_EAN_EXTENSION = 17;


}
