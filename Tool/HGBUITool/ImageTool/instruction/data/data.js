/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"图片工具类",

        tools:[{
            name:"HGBImageTool",
            prompt:"图片工具类"


        },
            {
                name:"UIImage+HGBImageTool",
                prompt:"图片工具类"


            }

        ],
        instruction:"图片剪切，尺寸变换，旋转",
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