package com.imin.scan;

import android.Manifest;
import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.view.PreviewView;
import androidx.fragment.app.FragmentActivity;

import com.imin.hardware.R;
import com.imin.scan.util.LogUtils;
import com.imin.scan.util.PermissionUtils;
@SuppressLint("NewApi")
public class CaptureActivity extends FragmentActivity implements CameraScan.OnScanResultCallback{

    private static final int CAMERA_PERMISSION_REQUEST_CODE = 0X86;
    protected PreviewView previewView;
    protected ViewfinderView viewfinderView;
    protected View ivFlashlight;

    private CameraScan mCameraScan;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(isContentView()){
            setContentView(getLayoutId());
        }
        initUI();
    }

    /**
     * 初始化
     */

    public void initUI(){
        previewView = findViewById(getPreviewViewId());
//        previewView.setScaleType();
//        mSurfaceHolder.setKeepScreenOn(true);
//        previewView.setZOrderMediaOverlay(true);
//        mSurfaceHolder.setFormat(PixelFormat.TRANSLUCENT);
        int viewfinderViewId = getViewfinderViewId();
        if(viewfinderViewId != 0){
            viewfinderView = findViewById(viewfinderViewId);
        }
        int ivFlashlightId = getFlashlightId();
        if(ivFlashlightId != 0){
            ivFlashlight = findViewById(ivFlashlightId);
            if(ivFlashlight != null){
                ivFlashlight.setOnClickListener(v -> onClickFlashlight());
            }
        }
        initCameraScan();
        startCamera();
    }

    /**
     * 点击手电筒
     */
    protected void onClickFlashlight(){
        toggleTorchState();
    }

    /**
     * 初始化CameraScan
     */
    public void initCameraScan(){
        mCameraScan = new DefaultCameraScan(this,previewView);
        mCameraScan.setOnScanResultCallback(this);
    }


    /**
     * 启动相机预览
     */
    public void startCamera(){
        if(mCameraScan != null){
            if(PermissionUtils.checkPermission(this, Manifest.permission.CAMERA)){
                mCameraScan.startCamera();
            }else{
                LogUtils.d("checkPermissionResult != PERMISSION_GRANTED");
                PermissionUtils.requestPermission(this,Manifest.permission.CAMERA,CAMERA_PERMISSION_REQUEST_CODE);
            }
        }
    }


    /**
     * 释放相机
     */
    private void releaseCamera(){
        if(mCameraScan != null){
            mCameraScan.release();
        }
    }

    /**
     * 切换闪光灯状态（开启/关闭）
     */
    protected void toggleTorchState(){
        if(mCameraScan != null){
            boolean isTorch = mCameraScan.isTorchEnabled();
            mCameraScan.enableTorch(!isTorch);
            if(ivFlashlight != null){
                ivFlashlight.setSelected(!isTorch);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if(requestCode == CAMERA_PERMISSION_REQUEST_CODE){
            requestCameraPermissionResult(permissions,grantResults);
        }
    }

    /**
     * 请求Camera权限回调结果
     * @param permissions
     * @param grantResults
     */
    public void requestCameraPermissionResult(@NonNull String[] permissions, @NonNull int[] grantResults){
        if(PermissionUtils.requestPermissionsResult(Manifest.permission.CAMERA,permissions,grantResults)){
            startCamera();
        }else{
            finish();
        }
    }

    @Override
    protected void onDestroy() {
        releaseCamera();
        super.onDestroy();
    }

    /**
     * 返回true时会自动初始化{@link #setContentView(int)}，返回为false是需自己去初始化{@link #setContentView(int)}
     * @return 默认返回true
     */
    public boolean isContentView(){
        return true;
    }

    /**
     * 布局id
     * @return
     */
    public int getLayoutId(){
        return R.layout.capture;
    }

    /**
     * {@link #viewfinderView} 的 ID
     * @return 默认返回{@code R.id.viewfinderView}, 如果不需要扫码框可以返回0
     */
    public int getViewfinderViewId(){
        return R.id.viewfinderView;
    }


    /**
     * 预览界面{@link #previewView} 的ID
     * @return
     */
    public int getPreviewViewId(){
        return R.id.previewView;
    }

    /**
     * 获取 {@link #ivFlashlight} 的ID
     * @return  默认返回{@code R.id.ivFlashlight}, 如果不需要手电筒按钮可以返回0
     */
    public int getFlashlightId(){
        return R.id.ivFlashlight;
    }

    /**
     * Get {@link CameraScan}
     * @return {@link #mCameraScan}
     */
    public CameraScan getCameraScan(){
        return mCameraScan;
    }

    /**
     * 接收扫码结果回调
     * @param result 扫码结果
     * @return 返回true表示拦截，将不自动执行后续逻辑，为false表示不拦截，默认不拦截
     */
    @Override
    public boolean onScanResultCallback(Result result) {
        return false;
    }
}
