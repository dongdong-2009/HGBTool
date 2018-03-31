/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"下载管理工具",

        tools:[
            {
                name:"HGBNetworkRequest",
                prompt:"网络请求框架-基于AFN"


            },{
                name:"HGBDownLoadTool",
                prompt:"下载管理工具"


            }

        ],
        instruction:"下载管理工具",
        librarys:[
            "Foundation.framework",
            "Security.framework",
            "UIKit.framework"
        ],
        infoPlist:[{
           key:"App Transport Security Settings-Allow Arbitrary Loads ",
                   value:"YES"
        }],
        buildSetting:null,
       other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
