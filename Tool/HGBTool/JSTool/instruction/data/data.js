/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"JS工具类",

        tools:[
            {
                name:"HGBCallJSModel",
                prompt:"OC调用JS方法"


            }

        ],
        instruction:"OC调用JS方法",
        librarys:["Foundation.framework","UIKit.framework","JavaScriptCore.framework"],
        infoPlist:null,
        buildSetting:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};