/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"图表",

        tools:[
            {
                name:"HGBBarChat",
                prompt:"条形图"


            },
            {
                name:"HGBPieChat",
                prompt:"饼状图"


            },
            {
                name:"HGBBrokenLineChat",
                prompt:"折线图"


            }
        ],
        instruction:"图表",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
            "LocalAuthentication.framework",
            "AVFoundation.framework"
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
