/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"指纹识别",

        tools:[
            {
                name:"HGBTouchIDTool",
                prompt:"指纹识别"


            }

        ],
        instruction:"指纹识别",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "LocalAuthentication.framework "
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
