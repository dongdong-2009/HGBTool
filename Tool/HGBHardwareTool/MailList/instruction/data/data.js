/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"通讯录",

        tools:[
            {
                name:"HGBMailListTool",
                prompt:"通讯录"


            }
        ],
        instruction:"手电筒,相册，相机，录像，录音，图片展示，播放录音，播放视频",
        librarys:[
            "Foundation.framework",
                  "UIKit.framework",
            "AddressBook.framework",
            "AddressBookUI.framework",
            "Contacts.framework ",
            "ContactsUI.framework"
        ],
        infoPlist:[{
            key:"NSContactsUsageDescription",
            value:"$(PRODUCT_NAME)需要您的同意,才能访问通讯录"
        }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
