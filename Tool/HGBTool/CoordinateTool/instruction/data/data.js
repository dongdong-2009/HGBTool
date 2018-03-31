/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"地理坐标工具类",

        tools:[
            {
                name:"HGBCoordinateTool",
                prompt:"地理坐标工具类"


            }

        ],
        instruction:"WGS GCJ 百度坐标转换 经纬度间距离",
        librarys:["Foundation.framework","CoreLocation.framework"],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
