/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"系统分享",

        tools:[
            {
                name:"HGBShareTool",
                prompt:"系统分享"


            }
        ],
        instruction:"系统分享",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "AssetsLibrary.framework",
                  "SafariServices.framework",
                  "Social.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
