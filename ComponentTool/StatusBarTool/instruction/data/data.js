/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"状态栏工具",

        tools:[
            {
                name:"HGBStatusBarTool",
                prompt:"状态栏工具"


            }
        ],
        instruction:"状态栏显示隐藏  状态栏样式改变 ",
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
