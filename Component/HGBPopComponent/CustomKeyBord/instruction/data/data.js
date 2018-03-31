/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"键盘组件",

        tools:[
            {
                name:"HGBCustomKeyBord",
                prompt:"键盘组件"


            }
        ],
        instruction:"自定义键盘：数字，字母，数字字母，字母数字，数字字母标点，字母数字标点 无标题，有标题，文字，密码，支付密码 提供按键返回加密",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "AudioToolbox.framework",
            "Security.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
