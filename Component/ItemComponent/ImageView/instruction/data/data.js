/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"图片显示组件",

        tools:[
            {
                name:"HGBImageView",
                prompt:"图片显示组件"


            }
        ],
        instruction:"图片复制粘贴删除复制文字功能 点击事件功能",
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
