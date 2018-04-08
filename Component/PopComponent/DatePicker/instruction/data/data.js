/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"日期选择器",

        tools:[
            {
                name:"HGBDatePicker",
                prompt:"日期选择器"


            }
        ],
        instruction:"过去日期 未来日期-可设置年限 日期段  有默认",
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
