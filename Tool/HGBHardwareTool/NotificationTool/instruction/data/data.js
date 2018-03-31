/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"原生推送工具类",

        tools:[
            {
                name:"HGBNotificationTool",
                prompt:"消息推送取消 通知发送监听取消"


            },{
                name:"AppDelegate+Push",
                prompt:"本地远程推送权限，获取等"


            },{
                name:"HGBPushTool",
                prompt:"本地远程推送权限，获取等"


            }

        ],
        instruction:"原生推送工具类",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
        ],
        infoPlist:null,
        buildSetting:null,
       other:[{
         key:"Capablities Push Notification ",
         value:"打开"
              },{
              key:"Capablities Background Modes Remote Notification ",
              value:"打开"
              }],
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
