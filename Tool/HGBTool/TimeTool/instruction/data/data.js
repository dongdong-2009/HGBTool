/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"时间工具类简介",

        tools:[
            {
                name:"HGBDateTool",
                prompt:"时间工具类"


            },{
                name:"HGBTimeTool",
                prompt:"时间工具类"


            },{
                name:"NSDate+HGBDate",
                prompt:"时间相关方法"


            },{
                name:" NSString+HGBTime",
                prompt:"时间字符串相关方法"

            }

        ],
        instruction:"获取时间搓 网络时间 时间字符串 时间字符串转换 时间判断",
        librarys:["Foundation.framework"],
        infoPlist:null,
        buildSetting:[{
            key:"Other Linker Flags",
            value:"ObjC"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
