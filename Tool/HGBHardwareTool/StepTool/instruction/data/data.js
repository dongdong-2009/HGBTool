/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"计步器",

        tools:[
            {
                name:"HGBStepTool",
                prompt:"计步器"


            }
        ],
        instruction:"计步器",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "CoreMotion.framework"
        ],
infoPlist:[{
           key:"NSMotionUsageDescription",
           value:"$(PRODUCT_NAME)想要访问您的运动传感器"
           },{
           key:"NSHealthUpdateUsageDescription",
           value:"$(PRODUCT_NAME)需要您的同意,才能访问健康更新"
           },{
           key:"NSHealthShareUsageDescription",
           value:"$(PRODUCT_NAME)需要您的同意,才能访问健康分享"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
