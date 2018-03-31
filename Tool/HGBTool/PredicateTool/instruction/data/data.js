/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"谓词快捷工具",

        tools:[
            {
                name:"HGBPredicateTool",
                prompt:"谓词快捷工具"


            }

        ],
        instruction:"谓词快捷工具,正则表达式",
        librarys:["Foundation.framework"],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};