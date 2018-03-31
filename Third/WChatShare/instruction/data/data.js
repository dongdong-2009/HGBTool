/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"微信分享",

        tools:[
            {
                name:"HGBWChatShareSheet",
                prompt:"微信分享弹窗"


            },{
                name:"HGBWChatShareTool",
                prompt:"微信分享工具类"


            }
        ],
        instruction:"微信分享",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
            "UMengAnalytics-NO-IDFA",
            "OpenSDK1.7.4"
        ],
        infoPlist:null,
        buildSetting:null,
        other:[{
            key:"Podfile",
            value:"pod 'UMengAnalytics-NO-IDFA'"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
