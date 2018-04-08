/**
 * Created by huangguangbao on 2017/12/9.
 */
var component=
{
        prompt:"签名画板",

        tools:[
            {
                name:"HGBSignDrawer",
                prompt:"签名画板弹窗"


            },
            {
                name:"HGBSignDrawView",
                prompt:"签名画板"


            }
        ],
        instruction:"签名画板",
        librarys:[
            "Foundation.framework",
            "UIKit.framework",
                   "AVFoundation.framework",
                   "AssetsLibrary.framework",
                   "Photos.framework",
                  "CoreLocation.framework"
        ],
infoPlist:[{
           key:"NSPhotoLibraryUsageDescription",
           value:"$(PRODUCT_NAME)需要您的同意,才能访问相册"
           },{
           key:"NSPhotoLibraryAddUsageDescription",
           value:"$(PRODUCT_NAME)需要您的同意,才能添加相册"
           }],
        buildSetting:null,
        other:null,
       framework:"lipo -create Release/Debug-iphoneos/库名.framework/库名  Release/Debug-iphonesimulator/库名.framework/库名 -output Release/Debug-iphoneos/库名.framework/库名",
       a:"lipo -create Release/Debug-iphoneos/库名.a  Release/Debug-iphonesimulator/库名.a -output Release/Debug-iphoneos/库名.a"
};
