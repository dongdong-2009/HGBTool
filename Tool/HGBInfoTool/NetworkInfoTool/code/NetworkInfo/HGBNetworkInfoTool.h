//
//  HGBNetworkInfoTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/12.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

/**
 网络类型
 */
typedef enum HGBNetworkType
{
    HGBNetworkTypeNone,//无网络
    HGBNetworkType2G,//2G
    HGBNetworkType3G,//3G
    HGBNetworkType4G,//4G
    HGBNetworkTypeWIFI,//WIFI
    HGBNetworkTypeOther//其他

}HGBNetworkType;
@interface HGBNetworkInfoTool : NSObject
/**
 获取网络类型

 @return 网络类型
 */
+(HGBNetworkType )getNetworkType;
/**
 获取网络信号强度

 @return 获取网络信号强度
 */
+(int)getSignalStrength;

/**
 获取流量 

 @param isTransUnit 是否进行单位转换 YES会转换为最高单位并带单位符号B KB MB GB NO 直接返回字节大小
 @return 流量字典
 */
+ (NSDictionary *)getFlowIOBytesWithUnitType:(BOOL)isTransUnit;
/**
 获取3G或者GPRS的流量

 @param isTransUnit 是否进行单位转换 YES会转换为最高单位并带单位符号B KB MB GB NO 直接返回字节大小

 @return 3G或者GPRS的流量
 */
+ (NSString *)getGprs3GFlowIOBytesWithUnitType:(BOOL)isTransUnit;
/**
 获取Wifi流量

 @param isTransUnit 是否进行单位转换 YES会转换为最高单位并带单位符号B KB MB GB NO 直接返回字节大小

 @return Wifi流量
 */
+ (NSString *)getGprsWifiFlowIOBytesWithUnitType:(BOOL)isTransUnit;
@end
