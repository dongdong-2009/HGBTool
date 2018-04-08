/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"相机",

        tools:[
            {
                name:"HGBCommonCameraController",
                prompt:"相机"


            },{
                name:"HGBCommonCameraStyle",
                prompt:"样式"


            }
        ],
        instruction:"相机",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "AssetsLibrary.framework",
            "CoreLocation.framework",
            "AVFoundation.framework",
            "AssetsLibrary.framework"
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
