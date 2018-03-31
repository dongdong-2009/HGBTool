/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"百度地图",

        tools:[
            {
                name:"HGBBaiduMapView",
                prompt:"百度地图"


            }
        ],
        instruction:"百度地图",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
            "BaiduMapKit"
        ],
        infoPlist:null,
        buildSetting:null,
        other:[{
            key:"Podfile",
            value:"pod 'BaiduMapKit'"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
