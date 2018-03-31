/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"压缩解压",

        tools:[
            {
                name:"HGBCompressedFileTool",
                prompt:"压缩解压"


            }

        ],
        instruction:"压缩成zip文件 解压rar zip 7z文件",
         librarys:[
            "Foundation.framework",
             "libz.tbd",
             "libstdc++.tbd",
             "CoreGraphics.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:[{
            key:"libUnrar4iOS.a",
            value:"加入工程"
        },{
            key:"Unrar4iOS.framework",
            value:"不加入工程必须存在"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};