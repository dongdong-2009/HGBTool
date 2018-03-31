/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"陀螺仪",

        tools:[
            {
                name:"HGBGyroscopeTool",
                prompt:"陀螺仪"


            }
        ],
        instruction:"陀螺仪",
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
