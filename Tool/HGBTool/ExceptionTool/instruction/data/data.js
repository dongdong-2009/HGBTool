/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"错误崩溃工具",

        tools:[
            {
                name:"HGBExceptionTool",
                prompt:"错误崩溃工具"


            }

        ],
        instruction:"收集错误信息并保存",
        librarys:["Foundation.framework","UIKit.framework","Security.framework"],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};