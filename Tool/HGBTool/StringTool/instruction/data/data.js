/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"字符串工具类",

        tools:[
            {
                name:"HGBStringTool",
                prompt:"字符串工具类全"


            },{
                name:"NSString+HGBString",
                prompt:"字符串基本处理"


            },{
                name:"NSString+HGBStringCheck",
                prompt:"字符串校验"


            },{
                name:" NSString+HGBStringTransForm",
                prompt:"字符串转化"

            },{
                name:"NSString+HGBStringTypeCheck",
                prompt:"字符串类型校验"

            }

        ],
        instruction:"1.字符串基本处理：空格处理，拼音转换 2.字符串类型校验：数字，字母，汉字 3.字符串校验:身份证，手机号，性别，邮箱，邮编等 4.字符串转换 16进制，身份证获取出生日期等",
        librarys:["Foundation.framework"],
        infoPlist:null,
        buildSetting:[{
            key:"Other Linker Flags",
            value:"ObjC"
        }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};