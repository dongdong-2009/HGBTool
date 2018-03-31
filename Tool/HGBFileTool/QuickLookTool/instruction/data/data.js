/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"快速预览",

        tools:[
            {
                name:"HGBQuickLookTool",
                prompt:"快速预览"


            }

        ],
        instruction:"快速预览",
         librarys:[
            "Foundation.framework",
             "UIKit.framework",
             "QuickLook.framework",
             "QuartzCore.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};