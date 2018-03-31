/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"文件管理",

        tools:[
            {
                name:"HGBFileManage",
                prompt:"文件管理便捷方法"


            },{
                name:"HGBFileManageController",
                prompt:"文件管理控制器"


            }

        ],
        instruction:"文件管理",
         librarys:[
            "Foundation.framework",
             "UIKit.framework",
             "QuickLook.framework",
             "QuartzCore.framework",
             "SafariServices.framework",
             "CoreImage.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};