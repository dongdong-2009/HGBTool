/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"友盟统计",

        tools:[
            {
                name:"AppDelegate+HGBUMengAnalytics",
                prompt:"友盟统计"


            }
        ],
        instruction:"友盟统计",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
            "UMengAnalytics-NO-IDFA"
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
