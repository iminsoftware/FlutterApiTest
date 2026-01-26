# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
#指定代码的压缩级别
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# The remainder of this file is identical to the non-optimized version
# of the Proguard configuration file (except that the other file has
# flags to turn off optimization).
#包明不混合大小写
-dontusemixedcaseclassnames
#不去忽略非公共的库类
-dontskipnonpubliclibraryclasses
-verbose

-keepattributes *Annotation*
-keep public class com.google.vending.licensing.ILicensingService
-keep public class com.android.vending.licensing.ILicensingService


#引入依赖包rt.jar（jdk路径）
#-libraryjars ../../rt.jar


#引入依赖包android.jar(android SDK路径)
#-libraryjars ../../android.jar
#保证是独立的jar,没有任何项目引用,如果不写就会认为我们所有的代码是无用的,从而把所有的代码压缩掉,导出一个空的jar
-dontshrink
#保护泛型
-keepattributes Signature

#保持 native 方法不被混淆
# For native methods, see http://proguard.sourceforge.net/manual/examples.html#native
-keepclasseswithmembernames class * {
    native <methods>;
}
#保持自定义控件类不被混淆
# keep setters in Views so that animations can still work.
# see http://proguard.sourceforge.net/manual/examples.html#beans
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
     public <init>(android.content.Context);
       public <init>(android.content.Context, android.util.AttributeSet);
       public <init>(android.content.Context, android.util.AttributeSet, int);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}
#保持自定义控件类不被混淆
# We want to keep methods in Activity that could be used in the XML attribute onClick
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}
#保持自定义控件类不被混淆
# We want to keep methods in Activity that could be used in the XML attribute onClick
-keepclassmembers class * extends androidx.appcompat.app.AppCompatActivity {
   public void *(android.view.View);
}
#保持自定义控件类不被混淆
# We want to keep methods in Activity that could be used in the XML attribute onClick
-keepclassmembers class * extends androidx.fragment.app.Fragment {
   public void *(android.view.View);
}
-keepclassmembers class * extends android.app.Fragment {
   public void *(android.view.View);
}

#保持 Serializable 不被混淆并且enum 类也不被混淆
# For enumeration classes, see http://proguard.sourceforge.net/manual/examples.html#enumerations
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
# *;
}
#保持 Parcelable 不被混淆
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}
#不混淆资源类
-keepclassmembers class **.R$* {
    public static <fields>;
}
#接口的属性不混淆
-keepclassmembers interface * {
 *;
}

# The support library contains references to newer platform versions.
# Don't warn about those in case this app is linking against an older
# platform version.  We know about them, and they are safe.
-dontwarn android.support.**

# Understand the @Keep support annotation.
-keep class android.support.annotation.Keep

-keep @android.support.annotation.Keep class * {*;}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <methods>;
}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <fields>;
}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <init>(...);
}
#以下是不需要混淆的文件
 -keep interface com.imin.scan.Symbol{
     *;
 }
 -keepnames class_specification
 -keep class com.imin.scan.ScanUtils{
      *;
  }
 -keep interface com.imin.scan.ICamera{
        *;
  }
 -keep class com.imin.scan.DefaultCameraScan{
            *;
  }
-keep class com.imin.scan.CameraScan$OnScanResultCallback{
              *;
    }
 -keep class com.imin.scan.DecodeFormatManager{
            *;
  }
-keep class com.imin.scan.DecodeConfig{
              *;
    }
-keep class com.imin.scan.CameraScan{
               *;
     }
-keep class com.imin.scan.util.*{
               *;
     }
-keep class com.imin.scan.decoding.RGBLuminanceSource{
               *;
     }
-keep class com.imin.scan.config.ResolutionCameraConfig{
               *;
     }
-keep class com.imin.scan.config.AspectRatioCameraConfig{
               *;
     }
-keep class com.imin.scan.analyze.MultiFormatAnalyzer{
               *;
     }
-keep class com.imin.scan.analyze.QRCodeAnalyzer{
               *;
     }
-keep class com.imin.scan.Result{
                    *;
     }
-keep class com.imin.scan.CaptureActivity{
                    *;
     }
-keep class com.imin.scan.CaptureFragment{
                         *;
     }
-keep class com.imin.scan.ViewfinderView{
                              *;
     }
-keep class com.imin.scan.ViewfinderView$FrameGravity{
                              *;
     }
-keep class com.imin.scan.ViewfinderView$LaserStyle{
                                                  *;
     }
-keep class com.imin.scan.ViewfinderView$TextLocation{
                                                  *;
     }
-keep class com.imin.scan.analyze.ImageAnalyzer{
                                                       *;
          }
-keep interface com.imin.scan.analyze.Analyzer{
                                                       *;
          }
-keep class com.imin.scan.analyze.QRCodeAnalyzer{
                                                       *;
          }
-keep class com.imin.scan.analyze.AreaRectAnalyzer{
                                                       *;
          }
-keep class com.imin.scan.config.CameraConfig{
                                                        *;
           }
-keep class com.imin.scan.decoding.Intents{
                                                        *;
           }
-keep class com.imin.scan.ICameraControl{
                                                        *;
           }


#-keep public interface com.imin.printerlib.util.CodeFormat
#保持异常不被混淆 保持内部类不被混淆
-keepattributes Exceptions,InnerClasses
#避免混淆泛型 如果混淆报错建议关掉 保持泛型不被混淆
-keepattributes Signature
#抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable
#. -keep class [packagename].A{ *; }
#-keep class [packagename].A$* { *; }
#添加内容
#-keep class com.zl.proguarddemo.MainActivity$Inner{
#
#    public <fields>;
#
#    public <methods>;
#
#}
#
#Inner为MainActivity的内部类(注意类路径名写全!!!)