//
//  HGBCompassTool.h
//  测试
//
//  Created by huangguangbao on 2018/1/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "HGBCompassView.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif


/**
 错误类型
 */
typedef enum HGBCompassToolErrorType
{
    HGBCompassToolErrorTypeLocationError=3,//定位失败
    HGBCompassToolErrorTypeAuthority=11//权限受限

}HGBCompassToolErrorType;

@class HGBCompassTool;
@protocol HGBCompassToolDelegate <NSObject>
@optional
/**
 定位成功返回地址

 @param compass 控件
 @param location 地址
 */
-(void)loaction:(HGBCompassTool *)compass didSucessWithLocation:(CLLocation *)location;
/**
 定位失败

 @param compass 控件
 */
-(void)compass:(HGBCompassTool *)compass didFailedWithError:(NSDictionary *)errorInfo;
/**
 定位成功返回地址

 @param compass 控件
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
-(void)compass:(HGBCompassTool *)compass didSucessWithLocationInfo:(NSDictionary *)locationInfo;
/**
 定位成功返回方向信息

 @param compass 控件
 @param headerInfo 方向信息--
 magneticHeading:地磁航向数据
 trueHeading:地理航向数据
 heading:地磁北方向
 orientation:方向
 */
-(void)compass:(HGBCompassTool *)compass didSucessWithHeaderInfo:(NSDictionary *)headerInfo;

@end

@interface HGBCompassTool : NSObject
/**
 代理
 */
@property(nonatomic,assign)id<HGBCompassToolDelegate>delegate;
/**
 是否允许后台定位
 */
@property(nonatomic,assign)BOOL allowBackGroundLocation;
/**
 定位精度
 */
@property(nonatomic,assign)CGFloat distance;

/**
 指南针界面
 */
@property(strong,nonatomic)HGBCompassView *compassView;
/**
 方向标签
 */
@property(strong,nonatomic)UILabel * directionLabel;
/**
 角度标签
 */
@property(strong,nonatomic)UILabel * angleLabel;
/**
 位置标签
 */
@property(strong,nonatomic)UILabel * positionLabel;
/**
 经纬度标签
 */
@property(strong,nonatomic)UILabel * latitudlongitudeLabel;

#pragma mark init
/**
 单例

 @return 对象
 */
+(instancetype)shareInstanceWithDelegate:(id<HGBCompassToolDelegate>)delegate;
/**
 单例

 @return 对象
 */
+(instancetype)shareInstance;
/**
 开始定位
 */
- (void)startLocate;
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

