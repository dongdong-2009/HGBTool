/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"tabbar角标工具",

        tools:[
            {
                name:"HGBTabBarBadgeTool",
                prompt:"tabbar角标工具"


            }
        ],
        instruction:"tabbar工具角标设置 ",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:[{
            key:"Other Linker Flags",
            value:"-ObjC"
        }],
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
