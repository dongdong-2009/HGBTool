/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"加速度计",

        tools:[
            {
                name:"HGBAccelerometerTool",
                prompt:"加速度计"


            }
        ],
        instruction:"加速度计",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "CoreMotion.framework"
        ],
infoPlist:[{
           key:"NSMotionUsageDescription",
           value:"$(PRODUCT_NAME)想要访问您的运动传感器"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
