/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"系统自带联系方式",

        tools:[
            {
                name:"HGBContactTool",
                prompt:"系统常用联系方式"


            }

        ],
        instruction:"打电话，发短信，发邮件",
        librarys:[
            "Foundation.framework",
                  "MessageUI.framework",
                  "UIKit.framework",
            "Messages.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
