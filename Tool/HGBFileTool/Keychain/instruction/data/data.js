/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"钥匙串工具类",

        tools:[
            {
                name:"HGBKeychainTool",
                prompt:"钥匙串工具类"


            }

        ],
        instruction:"钥匙串保存",
        librarys:[
            "Foundation.framework",
                  "Security.framework",
                  "UIKit.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:[{
            key:"HGBFileTool.m-Compiler Flags",
            value:"-fno-objc-arc（文件使用了ARC机制而你的当前项目没有使用ARC:-fno-objc-arc）;使用ARC机制的代码不使用ARC机制，只需要输入 -fno-objc-arc;)"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
