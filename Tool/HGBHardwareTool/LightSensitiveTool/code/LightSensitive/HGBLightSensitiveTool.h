//
//  HGBLightSensitiveTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/15.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif



/**
 错误类型
 */
typedef enum HGBLightSensitiveToolErrorType
{
    HGBLightSensitiveToolErrorTypeAuthority=11,//权限受限
    HGBLightSensitiveToolErrorTypeDevice=10,//设备受限
    HGBLightSensitiveToolErrorTypeOther=99//其他

}HGBLightSensitiveToolErrorType;

@class HGBLightSensitiveTool;



@protocol HGBLightSensitiveToolDelegate<NSObject>
@optional
/**
 感光信息更新

 @param lightSensitive 感光工具
 @param brightness 光照强度
 */
- (void)lightSensitive:(HGBLightSensitiveTool*)lightSensitive didUpdatedWithBrightness:(CGFloat)brightness;
/**
 感光信息错误

 @param lightSensitive 感光工具
 @param errorInfo 错误信息
 */
- (void)lightSensitive:(HGBLightSensitiveTool*)lightSensitive didFailedWithError:(NSDictionary *)errorInfo;

@end

@interface HGBLightSensitiveTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBLightSensitiveToolDelegate>delegate;
/**
 是否重复
 */
@property(assign,nonatomic)BOOL isRepeat;
/**
 数据更新时间
 */
@property(assign,nonatomic)CGFloat timeInterval;
#pragma mark 初始化
+(instancetype)shareInstance;
/**
 开始监测光照强度
 @param isRepeat 是否重复
 */
-(void)startMonitLightSensitiveWithRepeat:(BOOL)isRepeat;
/**
 关闭光强传感器

 @return 结果
 */
-(BOOL)stopMonitLightSensitive;
@end
