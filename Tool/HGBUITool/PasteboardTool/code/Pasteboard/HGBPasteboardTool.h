//
//  HGBPasteboardTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/25.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 数据格式
 */
typedef enum HGBPasteboardToolDataType
{
    HGBPasteboardToolDataTypeString,//字符串
    HGBPasteboardToolDataTypeStringArray,//字符串数组
    HGBPasteboardToolDataTypeURL,//url
    HGBPasteboardToolDataTypeURLArray,//url数组
    HGBPasteboardToolDataTypeImage,//图片
    HGBPasteboardToolDataTypeImageArray,//图片数组
    HGBPasteboardToolDataTypeColor,//颜色
    HGBPasteboardToolDataTypeColorArray,//颜色数组
}HGBPasteboardToolDataType;


@interface HGBPasteboardTool : NSObject
/**
 将数据放到粘贴板

 @param src 数据源
 @return 结果
 */
+(BOOL)pasteSource:(id)src;
/**
 获取粘贴板内容

 @return 粘贴板内容
 */
+(NSDictionary *)getPasteboardSource;
@end
