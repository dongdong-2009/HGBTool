/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"浏览器工具类",

        tools:[
            {
                name:"HGBUIWebController",
                prompt:"UIWebView浏览器"


            },{
                name:"HGBWKWebController",
                prompt:"UIWebView浏览器"


            }
        ],
        instruction:"浏览器工具类:支持打开url路径及工程内url，沙盒url，沙盒document url路径简化输入 支持加载html字符串,oc调用js",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "WebKit.framework",
            "JavaScriptCore.framework"
        ],
        infoPlist:[{
            key:"NSAppTransportSecurity-NSAllowsArbitraryLoads",
            value:"YES"
        }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
