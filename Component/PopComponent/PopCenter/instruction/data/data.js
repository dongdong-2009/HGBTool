/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"中间弹窗",

        tools:[
            {
                name:"HGBCenterPop",
                prompt:"中间弹窗"


            }
        ],
        instruction:"中间弹窗",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
