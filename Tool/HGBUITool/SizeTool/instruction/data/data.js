/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"尺寸工具",

        tools:[
            {
                name:"HGBSizeTool",
                prompt:"尺寸工具-根据字体条件计算字体字体高度或宽度"


            },{
                name:"UIView+Size",
                prompt:"控件位置"


            }

        ],
        instruction:"根据字体条件计算字体字体高度或宽度,条转控件位置",
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