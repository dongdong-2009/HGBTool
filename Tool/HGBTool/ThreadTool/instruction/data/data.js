/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"线程工具",

        tools:[
            {
                name:"HGBThreadTool",
                prompt:"线程工具"


            }

        ],
        instruction:"提供基础线程功能",
        librarys:["Foundation.framework"],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};