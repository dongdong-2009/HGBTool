/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"日历",

        tools:[
            {
                name:"HGBCalenderPicker",
                prompt:"日历选择器"


            },{
                name:"HGBCalenderTextField",
                prompt:"日期输入"


            }
        ],
        instruction:"日历功能 样式可调",
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
