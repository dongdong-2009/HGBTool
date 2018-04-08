/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"底部弹窗",

        tools:[
            {
                name:"HGBBottomSheet",
                prompt:"底部弹窗"


            },{
                name:"HGBTitleBottomSheet",
                prompt:"底部弹窗-带标题底部按钮"


            }
        ],
        instruction:"底部弹窗",
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
