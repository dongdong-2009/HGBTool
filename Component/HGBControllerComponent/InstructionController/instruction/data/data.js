/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"说明",

        tools:[
            {
                name:"HGBInstructionController",
                prompt:"说明"


            }
        ],
        instruction:"用于快捷说明文档:有标题，副标题，内容",
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
