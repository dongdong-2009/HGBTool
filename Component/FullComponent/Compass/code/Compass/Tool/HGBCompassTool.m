//
//  HGBCompassTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/16.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBCompassTool.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



@interface HGBCompassTool()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;// 定位管理器
@property (nonatomic, strong) CLGeocoder *geocoder;// 地址编码

@end
@implementation HGBCompassTool

static HGBCompassTool *instance=nil;
static int flag_location = 0;
static int flag_head = 0;
#pragma mark init
/**
 单例

 @return 对象
 */
+(instancetype)shareInstanceWithDelegate:(id<HGBCompassToolDelegate>)delegate
{
    if (instance==nil) {
        instance=[[HGBCompassTool alloc]initWithDelegate:delegate];

    }
    instance.delegate=delegate;
    return instance;
}
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBCompassTool alloc]init];

    }
    return instance;
}
- (instancetype)initWithDelegate:(id<HGBCompassToolDelegate>)delegate
{
    self = [super init];
    if (self) {
        [self authoritySet];
        self.delegate=delegate;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self authoritySet];
    }
    return self;
}
#pragma mark func

/**
 开始定位
 */
- (void)startLocate
{
    flag_head = 0;
    flag_location = 0;
    // 设置代理
    self.locationManager.delegate = self;
    //设置精度(实时更新)
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 设定频率，即每隔多少米更新一次
    if(self.distance!=0){
        self.locationManager.distanceFilter = self.distance;
    }else{
        CLLocationDistance myDistance = 1.0;//一米定位一次
        self.locationManager.distanceFilter = myDistance;
    }

    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied||[CLLocationManager authorizationStatus] ==kCLAuthorizationStatusRestricted) {

        NSString *promptString=@"";
        promptString=@"定位失败:请到设置隐私中开启本程序定位权限";
        if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
            [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:promptString}];
        }

    }
}
/**
 结束定位
 */
-(void)stopLocate{
    if(self.locationManager){
        [self.locationManager stopUpdatingLocation];
        [self.locationManager stopUpdatingHeading];
    }
}
#pragma mark - 发送位置信息
-(void)postLocation:(CLLocation *)location{
    if(location){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didSucessWithLocation:)]){
            [self.delegate loaction:self didSucessWithLocation:location];
        }

        [self getLocationInfoWithLocation:location];
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
            [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:@"定位失败"}];
        }
    }
}

#pragma mark - 获取地理位置信息
/**
 地理位置转地理信息

 @param coordinate 地理位置
 */
-(void)getLocationInfoWithCoordinate:(CLLocationCoordinate2D )coordinate{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self getLocationInfoWithLocation:location];
}
/**
 地理位置转地理信息

 @param location 地理位置
 */
-(void)getLocationInfoWithLocation:(CLLocation *)location{
    NSMutableArray *locationMarks=[NSMutableArray array];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(placemarks.count==0){
        }else{
            for(CLPlacemark *mark in placemarks){

                [locationMarks addObject:[HGBCompassTool transPlaceMarkToLocationInfoDic:mark]];
            }
            [self.locationManager stopUpdatingLocation];
        }
        if(error){
            HGBLog(@"%@",error);
            if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
                [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:error.localizedDescription}];
            }
            return;
        }

        if(locationMarks.count==0){
            HGBLog(@"目标地址不存在");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
                [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:@"目标地址不存在"}];
            }
            return;
        }
        if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didSucessWithLocationInfo:)]){
            [self.delegate compass:self didSucessWithLocationInfo:[locationMarks lastObject]];
        }
    }];
}

#pragma mark - 转换地理位置信息为字典
+(NSDictionary *)transPlaceMarkToLocationInfoDic:(CLPlacemark *)mark{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    if(mark.locality){
        [dic setObject:mark.locality  forKey:@"city"];
    }
    NSArray *AddressArr=[mark.addressDictionary objectForKey:@"FormattedAddressLines"];

    NSString *str=[AddressArr firstObject];
    if(str){
        [dic setObject:str  forKey:@"address"];
    }

    [dic setValue:@(mark.location.coordinate.latitude).stringValue forKey:@"latitude"];
    [dic setValue:@(mark.location.coordinate.longitude).stringValue forKey:@"longitude"];
    [dic setValue:@(mark.location.altitude).stringValue forKey:@"altitude"];
    if(mark.country){
        [dic setValue:mark.country forKey:@"country"];
    }
    if(mark.postalCode){
        [dic setValue:mark.postalCode forKey:@"zipCode"];
    }
    if(mark.ISOcountryCode){
        [dic setValue:mark.ISOcountryCode forKey:@"countryCode"];
    }

    if(mark.ISOcountryCode){
        [dic setValue:mark.ISOcountryCode forKey:@"countryCode"];
    }
    if(mark.subLocality){
        [dic setValue:mark.subLocality forKey:@"subLocality"];
    }
    if(mark.administrativeArea){
        [dic setValue:mark.administrativeArea forKey:@"administrativeArea"];
    }
    if(mark.name){
        [dic setValue:mark.name forKey:@"name"];
    }







    return dic;
}

#pragma mark - CLLocationManagerDelegate
//定位更新
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    //经纬度
    [self postLocation:location];

    //维纬度
    NSString * latitudeStr = [NSString stringWithFormat:@"%3.2f",
                              location.coordinate.latitude];
    //经度
    NSString * longitudeStr  = [NSString stringWithFormat:@"%3.2f",
                                location.coordinate.longitude];
    //高度
    NSString * altitudeStr  = [NSString stringWithFormat:@"%3.2f",
                               location.altitude];

    HGBLog(@"纬度 %@  经度 %@  高度 %@", latitudeStr, longitudeStr, altitudeStr);

    if(self.latitudlongitudeLabel){
         self.latitudlongitudeLabel.text = [NSString stringWithFormat:@"纬度：%@  经度：%@  海拔：%@", latitudeStr, longitudeStr, altitudeStr];
    }

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {

                       if ([placemarks count] > 0) {

                           CLPlacemark *placemark = placemarks[0];

                           NSDictionary *addressDictionary =  placemark.addressDictionary;

                           NSString *street = [addressDictionary
                                               objectForKey:(NSString *)kABPersonAddressStreetKey];
                           street = street == nil ? @"": street;

                           NSString *country = placemark.country;

                           NSString * subLocality = placemark.subLocality;

                           NSString *city = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressCityKey];
                           city = city == nil ? @"": city;



                           if(self.positionLabel){
                                self.positionLabel.text = [NSString stringWithFormat:@" %@\n %@\n %@%@" ,country, city,subLocality ,street];

                           }
                       }

                   }];

}


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{

    UIDevice *device =[UIDevice currentDevice];

    //    判断磁力计是否有效,负数时为无效，越小越精确
    if (newHeading.headingAccuracy>0)
    {
        //地磁航向数据-》magneticHeading
        float magneticHeading =[self heading:newHeading.magneticHeading fromOrirntation:device.orientation];

        //地理航向数据-》trueHeading
        float trueHeading =[self heading:newHeading.trueHeading fromOrirntation:device.orientation];

        //地磁北方向
        float heading = -1.0f *M_PI *newHeading.magneticHeading /180.0f;
        NSString *orientation=[self turnHeadingToOritention:newHeading];

        NSDictionary *headerInfo=@{@"magneticHeading":@(magneticHeading).stringValue,@"trueHeading":@(trueHeading).stringValue,@"orientation":orientation,@"heading":@(heading).stringValue};
        if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didSucessWithHeaderInfo:)]){
            [self.delegate compass:self didSucessWithHeaderInfo:headerInfo];
        }
        if(self.angleLabel){
            self.angleLabel.text = [NSString stringWithFormat:@"%3.1f°",magneticHeading];
        }

        //旋转变换
        if(self.compassView){
             [self.compassView resetDirection:heading];
        }
        if(self.directionLabel){
            self.directionLabel.text = orientation;
        }



    }else{
        HGBLog(@"磁力计失效");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
            [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:@"磁力计失效"}];
        }
    }


}


-(float)heading:(float)heading fromOrirntation:(UIDeviceOrientation)orientation{

    float realHeading =heading;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            realHeading=heading-180.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            realHeading=heading+90.0f;
            break;
        case UIDeviceOrientationLandscapeRight:
            realHeading=heading-90.0f;
            break;
        default:
            break;
    }
    if (realHeading>360.0f)
    {
        realHeading-=360.0f;
    }
    else if (realHeading<0.0f)
    {
        realHeading+=360.0f;
    }
    return  realHeading;
}
/**
 将heading转化为方向

 @param newHeading heading
 @return 方向
 */
- (NSString *)turnHeadingToOritention:(CLHeading *)newHeading{
    NSString *heading=@"北";
    CLLocationDirection  theHeading = ((newHeading.magneticHeading > 0) ?
                                       newHeading.magneticHeading : newHeading.trueHeading);

    int angle = (int)theHeading;

    switch (angle) {
        case 0:
            heading = @"北";
            break;
        case 90:
            heading= @"东";
            break;
        case 180:
            heading= @"南";
            break;
        case 270:
            heading = @"西";
            break;

        default:
            break;
    }
    if (angle > 0 && angle < 90) {
        heading= @"东北";
    }else if (angle > 90 && angle < 180){
        heading = @"东南";
    }else if (angle > 180 && angle < 270){
        heading = @"西南";
    }else if (angle > 270 ){
        heading = @"西北";
    }
    return heading;
}
//探测位置失败
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

    NSString *promptString=@"";
    switch([error code]) {
        case kCLErrorDenied:{

            promptString=@"定位失败:请到设置隐私中开启本程序定位权限";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
                [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:promptString}];
            }

        }
            break;
        case kCLErrorLocationUnknown:{
            promptString=@"定位失败，请刷新数据";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
                [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:promptString}];
            }
        }
            break;
        default:{
            promptString=@"定位失败，请刷新数据";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(compass:didFailedWithError:)]){
                [self.delegate compass:self didFailedWithError:@{ReslutCode:@(HGBCompassToolErrorTypeLocationError).stringValue,ReslutMessage:promptString}];
            }
        }
            break;
    }

    [self.locationManager stopUpdatingLocation];
}

// IOS8 新增方法,授权状态改变
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
    }
}
#pragma mark 权限申请
-(void)authoritySet{
    float version=[[[UIDevice currentDevice] systemVersion]floatValue];
    if(self.allowBackGroundLocation){
        //权限
        if(version>=9.0){
            //9.0之前仅打开capabilities-backgroundmode-location即可
            self.locationManager.allowsBackgroundLocationUpdates=YES;
            //位置管理对象中有requestAlwaysAuthorization这个行为NSLocationAlwaysUsageDescription
            if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){//位置管理对象中有requestAlwaysAuthorization这个行为
                [self.locationManager requestAlwaysAuthorization];
            }
        }
    }
    //    定位
    if(version>=8.0){

        //NSLocationWhenInUseUsageDescription
        [self.locationManager requestWhenInUseAuthorization];
    }
}
#pragma mark getter
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

@end
