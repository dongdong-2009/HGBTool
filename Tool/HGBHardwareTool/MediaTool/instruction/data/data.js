/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"媒体基础功能",

        tools:[
            {
                name:"HGBMediaTool",
                prompt:"媒体基础功能"


            }
        ],
        instruction:"手电筒,相册，相机，录像，录音，图片展示，播放录音，播放视频",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "CoreImage.framework",
            "AVFoundation.framework",
            "CoreLocation.framework",
            "QuartzCore.framework",
            "QuartzCore.framework",
            "QuickLook.framework",
            "MobileCoreServices.framework",
            "AVKit.framework",
            "AssetsLibrary.framework",
            "AudioToolbox.framework"
        ],
        infoPlist:[{
            key:"NSPhotoLibraryUsageDescription",
            value:"$(PRODUCT_NAME)需要您的同意,才能访问相册"
                   },{
                   key:"NSPhotoLibraryAddUsageDescription",
                   value:"$(PRODUCT_NAME)需要您的同意,才能访问添加相册"
                   }
                   ,{
            key:"NSCameraUsageDescription",
            value:"$(PRODUCT_NAME)想要访问相机"
        },{
            key:"NSMicrophoneUsageDescription",
            value:"$(PRODUCT_NAME)想要访问麦克风"
        }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
