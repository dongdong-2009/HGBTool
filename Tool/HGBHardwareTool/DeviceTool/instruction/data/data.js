/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"设备小功能",

        tools:[
            {
                name:"HGBDeviceTool",
                prompt:"设备小功能"


            }
        ],
        instruction:"设备小功能",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
            "AudioToolbox.framework",
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
