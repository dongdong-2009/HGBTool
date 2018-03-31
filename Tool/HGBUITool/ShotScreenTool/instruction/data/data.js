/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"截屏",

        tools:[{
            name:"HGBScreenShotTool",
            prompt:"截屏"


        }

        ],
        instruction:"普通截屏 网页截屏-全部",
         librarys:[
            "Foundation.framework",
             "UIKit.framework"
        ],
infoPlist:[{
           key:"NSAppTransportSecurity-NSAllowsArbitraryLoads",
           value:"YES"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
