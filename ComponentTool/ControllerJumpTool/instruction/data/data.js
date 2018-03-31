/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"控制器跳转工具",

        tools:[
            {
                name:"HGBControllerJumpTool",
                prompt:"控制器跳转工具"


               },{
               name:"UIViewController+HGBPresentAndDismiss",
               prompt:"控制器模态跳转工具"


               },{
               name:"UIViewController+HGBPushAndPop",
               prompt:"控制器pushpop跳转工具"


               }
        ],
        instruction:"控制器跳转基本方法",
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
