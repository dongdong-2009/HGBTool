/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"组件复制工具",

        tools:[
            {
                name:"HGBCopyViewTool",
                prompt:"组件复制工具"


            }
        ],
        instruction:"组件复制",
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
