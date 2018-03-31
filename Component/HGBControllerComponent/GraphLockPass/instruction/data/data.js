/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"九宫格密码锁",

        tools:[
            {
                name:"HGBSetLockController",
                prompt:"设置界面-需要导航栏控制器"


            },
            {
                name:"HGBUnlockController",
                prompt:"解锁界面-需要导航栏控制器"


            },
            {
                name:"HGBLockPassStyle",
                prompt:"weex浏览器"


            }
        ],
        instruction:"九宫格密码解锁或设置",
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
