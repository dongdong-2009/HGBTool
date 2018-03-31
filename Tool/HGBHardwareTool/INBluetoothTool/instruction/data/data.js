/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"苹果内部蓝牙",

        tools:[
            {
                name:"HGBINBluetoothTool",
                prompt:"苹果内部蓝牙"


            }
        ],
        instruction:"苹果内部蓝牙",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
                  "MultipeerConnectivity.framework"
        ],
infoPlist:[{
           key:"NSBluetoothPeripheralUsageDescription",
           value:"$(PRODUCT_NAME)需要您的同意,才能访问蓝牙"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
