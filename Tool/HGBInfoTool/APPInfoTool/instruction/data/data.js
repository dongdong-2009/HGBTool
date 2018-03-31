/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"应用信息工具类",

        tools:[{
            name:"HGBAPPInfoTool",
            prompt:"应用信息工具类"


        }

        ],
        instruction:"获取应用信息-版本号，应用名称，bundelid,图标，图片，info",
         librarys:[
            "Foundation.framework",
             "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};