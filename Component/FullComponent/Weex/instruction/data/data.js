/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"weex浏览器",

        tools:[
            {
                name:"HGBWeexController",
                prompt:"weex浏览器"


            }
        ],
        instruction:"weex浏览器 提供关闭按钮，按钮基础位置 拖动方式",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
            "WebKit.framework",
            "JavaScriptCore.framework",
            "WeexSDK"
        ],
        infoPlist:[{
            key:"NSAppTransportSecurity-NSAllowsArbitraryLoads",
            value:"YES"
        }],
        buildSetting:[{
            key:"Other Linker Flags",
            value:"-ObjC"
        },{
            key:"Other Linker Flags",
            value:"$(inherited)"
        }],
        other:[{
            key:" http: allow-intent",
            value:"allow-navigation"
        },{
            key:"https:allow-intent",
            value:"allow-navigation"
        },{
            key:"Podfile",
            value:"pod 'WeexSDK'"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
