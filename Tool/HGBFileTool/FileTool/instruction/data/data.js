/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"文件工具",

        tools:[
            {
                name:"HGBFileTool",
                prompt:"文件工具"


            }

        ],
        instruction:"文件存读，文件加密存读，文件判断，文件复制粘贴删除，文件存读,文件夹创建，文件夹子路径获取等等",
        librarys:[
            "Foundation.framework",
            "Security.framework"
        ],
        infoPlist:null,
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};