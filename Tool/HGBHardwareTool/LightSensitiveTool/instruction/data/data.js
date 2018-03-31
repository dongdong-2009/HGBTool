/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"光照强度工具",

        tools:[
            {
                name:"HGBLightSensitiveTool",
                prompt:"光照强度工具"


            }
        ],
        instruction:"光照强度工具",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "AssetsLibrary.framework",
                  "AVFoundation.framework",
                  "ImageIO.framework",
                  "AVKit.framework",
                  "MobileCoreServices.framework"
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
