/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"html转pdf",

        tools:[
            {
                name:"HGBHTMLtoPDF",
                prompt:"html转pdf"


            },{
                name:"HGBHTMLToPDFTool",
                prompt:"html转pdf快捷工具"


            }

        ],
        instruction:"html转pdf",
         librarys:[
            "Foundation.framework",
             "UIKit.framework",
             "CoreGraphics.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};