/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"提示弹窗",

        tools:[
            {
                name:"HGBAlertTool",
                prompt:"提示弹窗封装"


            },{
                name:"HGBHUD",
                prompt:"吐司封装"


            }
        ],
        instruction:"提示弹窗",
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
