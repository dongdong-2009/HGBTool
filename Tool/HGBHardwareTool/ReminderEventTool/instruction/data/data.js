/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"事件提醒",

        tools:[
            {
                name:"HGBReminderEventTool",
                prompt:"事件提醒"


            }
        ],
        instruction:"事件提醒",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "EventKit.framework"
        ],
infoPlist:[{
           key:"NSRemindersUsageDescriptionApp",
           value:"$(PRODUCT_NAME)想要访问您的事件提醒"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
