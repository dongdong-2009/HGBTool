/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"原生地图",

        tools:[
            {
                name:"HGBMapView",
                prompt:"原生地图"


            }
        ],
        instruction:"原生地图",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "MapKit.framework",
            "CoreLocation.framework"
        ],
        infoPlist:[{
            key:"NSLocationUsageDescription",
            value:"$(PRODUCT_NAME)想要访问您的位置"
        },{
            key:"NSLocationWhenInUseUsageDescription",
            value:"$(PRODUCT_NAME)想要访问您的位置"
        },{
            key:"NSLocationAlwaysUsageDescription",
            value:"$(PRODUCT_NAME)想要访问您的位置"
        }],
        buildSetting:null,
        other:[{
            key:"Capablities Background Modes location updates ",
            value:"打开"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
