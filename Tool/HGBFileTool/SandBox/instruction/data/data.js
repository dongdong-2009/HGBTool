/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"获取沙盒路径",

        tools:[
            {
                name:"HGBSandBoxTool",
                prompt:"获取沙盒路径"


            }

        ],
        instruction:"获取沙盒路径",
        librarys:[
            "Foundation.framework"
        ],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};