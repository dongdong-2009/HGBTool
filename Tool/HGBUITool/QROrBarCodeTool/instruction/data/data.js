/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"二维码条形码生成二维码识别",

        tools:[{
            name:"HGBQROrBarCodeTool",
            prompt:"二维码条形码生成二维码识别"


        }

        ],
        instruction:"二维码条形码生成二维码识别",
         librarys:[
            "Foundation.framework",
             "UIKit.framework",
             "CoreImage.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};