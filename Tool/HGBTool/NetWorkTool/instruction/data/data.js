/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"网络请求",

        tools:[
            {
                name:"HGBNetworkRequest",
                prompt:"网络请求框架-基于AFN"


            },{
                name:"HGBNetWorkTool",
                prompt:"网络请求工具类-使用HGBNetworkRequest"


            }

        ],
        instruction:"网络请求",
        librarys:[
            "Foundation.framework",
            "Security.framework",
            "UIKit.framework",
            "AFNetworking"
        ],
        infoPlist:[{
           key:"App Transport Security Settings-Allow Arbitrary Loads ",
                   value:"YES"
        }],
        buildSetting:[{
            key:" Other Linker Flags",
            value:"-ObjC"
        },{
            key:" Other Linker Flags",
            value:"$(inherited)"
        }],
       other:[{
       key:"Podfile",
       value:"pod 'Cordova', '~> 3.9.1'"
       }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
