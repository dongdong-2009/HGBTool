/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"数据库-自加密",

        tools:[
            {
                name:"HGBSEDataBaseTool",
                prompt:"数据库-自加密"


            }

        ],
        instruction:"数据库基本功能",
         librarys:[
            "Foundation.framework",
            "libsqlite3.tbd"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};