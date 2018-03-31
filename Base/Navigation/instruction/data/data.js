/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"导航栏相关基类",

        tools:[
            {
                name:"HGBNavigationController",
                prompt:"NavigationController"


            },{
                name:" UINavigationBar+HGBNavigationBar",
                prompt:"NavigationBar"

               }

        ],
        instruction:"导航栏相关基类",
        librarys:["Foundation.framework","UIKit.framework"],
        infoPlist:null,
        buildSetting:[{
            key:"Other Linker Flags",
            value:"ObjC"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
