/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"app内文件外部打开工具类",

        tools:[
            {
                name:"HGBOutAppOpenFileTool",
                prompt:"app内文件外部打开工具类"


            }

        ],
        instruction:"使用外部app打开app内文件",
         librarys:[
            "Foundation.framework",
             "UIKit.framework",
             "QuickLook.framework",
             "SafariServices.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};