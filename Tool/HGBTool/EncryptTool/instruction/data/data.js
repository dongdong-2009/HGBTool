/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"加密工具",

        tools:[
            {
                name:"HGBEncryptTool",
                prompt:"加密快捷工具"


            },{
                name:"HGBCustomEncryptTool",
                prompt:"加密快捷快捷快捷工具"


            }

        ],
        instruction:"加密",
        librarys:[
            "Foundation.framework",
            "Security.framework",
            "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:[{
            key:" Other Linker Flags",
            value:"-ObjC"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};