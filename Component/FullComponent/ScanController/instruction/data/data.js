/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"二维码条形码扫描",

        tools:[
            {
                name:"HGBCommonScanController",
                prompt:"二维码条形码扫描"


            },{
                name:"HGBCommonScanViewStyle",
                prompt:"样式"


            }
        ],
        instruction:"二维码条形码扫描",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "AssetsLibrary.framework",
            "CoreLocation.framework",
            "AVFoundation.framework",
            "AssetsLibrary.framework",
            "CoreMedia.framework",
            "CoreVideo.framework",
            "AudioToolbox.framework",
            "ImageIO.framework",
            "CoreGraphics.framework",
            "QuartzCore.framework",
            "CoreImage.framework"
        ],
        infoPlist:[{
            key:"NSCameraUsageDescription",
            value:"$(PRODUCT_NAME)想要访问相机"
        }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
