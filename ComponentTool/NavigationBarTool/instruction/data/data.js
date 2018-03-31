/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"导航栏工具",

        tools:[
            {
                name:"HGBNavigationBarTool",
                prompt:"导航栏工具"


               },{
               name:"UIViewController+HGBNavigationSet",
               prompt:"导航栏工具"


               }
        ],
instruction:"导航栏显示隐藏 ;导航栏背景颜色;导航栏快捷创建 ",
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
