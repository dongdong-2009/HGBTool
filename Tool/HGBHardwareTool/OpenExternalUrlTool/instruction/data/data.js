/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"打开外部url",

        tools:[
            {
                name:"HGBOpenExternalUrlTool",
                prompt:"打开外部url"


            }

        ],
        instruction:"打开外部url:可打开外部app 浏览器  设置界面 及打电话",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
