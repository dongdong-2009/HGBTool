//
//  HGB3DTouchTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/1/28.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGB3DTouchTool.h"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation HGB3DTouchTool
static  NSMutableArray *monitorResluts=nil;
#pragma mark 单例
static HGB3DTouchTool *instance=nil;
/**
 单例

 @return 单例
 */
+(instancetype)shareInstance
{

    if (instance==nil) {
        instance=[[HGB3DTouchTool alloc]init];
    }
    return instance;
}
#pragma mark 功能
/**
 创建3DTouch

 @param dataSource 数据源
 */
-(BOOL)create3DTouchWithData:(NSArray <HGBAppIcon3DTouchModel *>*)dataSource{
    if (TARGET_IPHONE_SIMULATOR) {
        HGBLog(@"设备不支持");
        return NO;
    }
    NSMutableArray *items=[NSMutableArray array];
    for(HGBAppIcon3DTouchModel *model in dataSource){
        if(model.title==nil||model.type==nil){
            return NO;
        }
        UIApplicationShortcutIcon *icon;
        if(model.icon&&model.icon.length!=0){
            icon= [UIApplicationShortcutIcon iconWithTemplateImageName:model.icon];
        }else{
            icon= [UIApplicationShortcutIcon iconWithType:model.systemIcon];
        }
        UIApplicationShortcutItem *item= [[UIApplicationShortcutItem alloc]initWithType:model.type localizedTitle:model.title localizedSubtitle:model.subtitle icon:icon userInfo:model.userInfo];
        [items addObject:item];
    }
     [UIApplication sharedApplication].shortcutItems =items;
    return YES;
}

#pragma mark 功能

/**
 发送3DTouch信息

 @param touchType  3DTocuh类型
 @param title 标题
 @param subTitle 副标题
 @param type 3DTocuh自定义类型
 @param userInfo 3DTocuh信息
 */
-(void)sendAppIcon3DTocuhMessageWith3DTouchType:(HGB3DTouchType )touchType andWithTitle:(NSString *)title andWithSubTitle:(NSString *)subTitle andWithType:(NSString *)type andWithUserInfo:(NSDictionary *)userInfo{

    for(HGBAppIcon3DTouchMonitorReslutBlock monitorReslut in monitorResluts){
        if(monitorReslut){
             monitorReslut(touchType,title,subTitle,type,userInfo);
        }
    }
}

#pragma mark set
-(void)setMonitorReslut:(HGBAppIcon3DTouchMonitorReslutBlock)monitorReslut{
    if(monitorResluts==nil){
        monitorResluts=[NSMutableArray array];
    }
    [monitorResluts addObject:monitorReslut];
}

@end
