/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"颜色工具类",

        tools:[
            {
                name:"HGBColorTool",
                prompt:"颜色工具类"


            },{
                name:"UIColor+HexString",
                prompt:"颜色工具类"


            }

        ],
        instruction:"颜色工具类",
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