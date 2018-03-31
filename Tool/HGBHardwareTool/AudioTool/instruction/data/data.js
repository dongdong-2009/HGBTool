/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"音频功能",

        tools:[
            {
                name:"HGBAudioTool",
                prompt:"音频功能"


            }
        ],
        instruction:"音频功能",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "AVFoundation.framework",
            "AVKit.framework",
            "AssetsLibrary.framework",
            "AudioToolbox.framework"
        ],
        infoPlist:[{
            key:"NSMicrophoneUsageDescription",
            value:"$(PRODUCT_NAME)想要访问麦克风"
        }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
