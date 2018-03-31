/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"app自检工具",

        tools:[
            {
                name:"HGBAppCheckTool",
                prompt:"app自检工具"


            }

        ],
        instruction:"app自检",
        librarys:[
            "Foundation.framework",
            "Security.framework",
            "CoreGraphics.framework",
            "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};