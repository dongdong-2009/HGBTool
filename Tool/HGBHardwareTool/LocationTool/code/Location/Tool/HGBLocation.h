//
//  HGBLocation.h
//  测试
//
//  Created by huangguangbao on 2017/8/10.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif



/**
 定位类型
 */
typedef enum HGBLocationType
{
    HGBLocationTypeLocation,//定位类型获取位置信息
    HGBLocationTypeHeader,//获取方向信息
    HGBLocationTypeAll//获取位置信息和方向信息

}HGBLocationType;

/**
 错误类型
 */
typedef enum HGBLocationErrorType
{
    HGBLocationErrorTypeLocationError=99,//定位失败
    HGBLocationErrorTypeAuthority=10//权限受限

}HGBLocationErrorType;

@class HGBLocation;
@protocol HGBLocationDelegate <NSObject>
@optional
/**
 定位成功返回地址

 @param hgblocation 控件
 @param location 地址
 */
-(void)loaction:(HGBLocation *)hgblocation didSucessWithLocation:(CLLocation *)location;
/**
 定位失败

 @param hgblocation 控件
 */
-(void)loaction:(HGBLocation *)hgblocation didFailedWithError:(NSDictionary *)errorInfo;
/**
 定位成功返回地址

 @param hgblocation 控件
 @param locationInfo 地址信息--

 latitude      纬度
 longitude     经度
 altitude      海拔高度
 country       国家
 countryCode   国家编码
 city          城市
 subLocality   区域
 adress        地址
 zipCode       邮编
 */
-(void)loaction:(HGBLocation *)hgblocation didSucessWithLocationInfo:(NSDictionary *)locationInfo;
/**
 定位成功返回方向信息

 @param hgblocation 控件
 @param headerInfo 方向信息--
 magneticHeading:地磁航向数据
 trueHeading:地理航向数据
 heading:地磁北方向
 orientation:方向
 */
-(void)loaction:(HGBLocation *)hgblocation didSucessWithHeaderInfo:(NSDictionary *)headerInfo;

@end

@interface HGBLocation : NSObject
/**
 代理
 */
@property(nonatomic,assign)id<HGBLocationDelegate>delegate;
/**
 是否允许后台定位
 */
@property(nonatomic,assign)BOOL allowBackGroundLocation;
/**
 定位精度
 */
@property(nonatomic,assign)CGFloat distance;

#pragma mark init
/**
 单例

 @return 对象
 */
+(instancetype)shareInstanceWithDelegate:(id<HGBLocationDelegate>)delegate;
/**
 单例

 @return 对象
 */
+(instancetype)shareInstance;
/**
 开始定位
 @param type 定位类型
 @param isRepeat 是否重复
 */
- (void)startLocateWithType:(HGBLocationType)type andWithReapeat:(BOOL)isRepeat;
/**
 结束定位
 */
-(void)stopLocate;
#pragma mark - 获取地理位置信息
/**
 地理位置转地理信息

 @param location 地理位置
 */
-(void)getLocationInfoWithLocation:(CLLocation *)location;
/**
 地理位置转地理信息

 @param coordinate 地理位置
 */
-(void)getLocationInfoWithCoordinate:(CLLocationCoordinate2D )coordinate;
@end
