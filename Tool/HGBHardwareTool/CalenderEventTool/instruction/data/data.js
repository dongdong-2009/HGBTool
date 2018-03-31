/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"日历事件",

        tools:[
            {
                name:"HGBCalenderEventTool",
                prompt:"日历事件"


            }
        ],
        instruction:"日历事件",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "EventKit.framework"
        ],
infoPlist:[{
           key:"NSCalendarsUsageDescriptionApp",
           value:"$(PRODUCT_NAME)想要访问您的日历"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
