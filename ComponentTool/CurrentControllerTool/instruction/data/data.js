/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"获取当前控制器",

        tools:[
            {
                name:"HGBCurrentControllerTool",
                prompt:"获取当前控制器"


               },{
               name:"UIViewController+HGBCurrentController",
               prompt:"获取当前控制器"


               }
        ],
        instruction:"获取当前控制器",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:[{
            key:"Other Linker Flags",
            value:"-ObjC"
        }],
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
