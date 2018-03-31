//
//  HGBLocation.m
//  测试
//
//  Created by huangguangbao on 2017/8/10.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBLocation.h"
#import <UIKit/UIKit.h>
#import "HGBLocationPromgressHud.h"

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



@interface HGBLocation()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;// 定位管理器
@property (nonatomic, strong) CLGeocoder *geocoder;// 地址编码
/**
 是否重复
 */
@property(assign,nonatomic)BOOL isRepeat;
@end
@implementation HGBLocation
static HGBLocation *instance=nil;
static int flag_location = 0;
static int flag_head = 0;
#pragma mark init
/**
 单例

 @return 对象
 */
+(instancetype)shareInstanceWithDelegate:(id<HGBLocationDelegate>)delegate
{
    if (instance==nil) {
        instance=[[HGBLocation alloc]initWithDelegate:delegate];

    }
    instance.delegate=delegate;
    return instance;
}
+(instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBLocation alloc]init];

    }
    return instance;
}
- (instancetype)initWithDelegate:(id<HGBLocationDelegate>)delegate
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
 @param type 定位类型
 @param isRepeat 是否重复
 */
- (void)startLocateWithType:(HGBLocationType)type andWithReapeat:(BOOL)isRepeat
{
    self.isRepeat=isRepeat;
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

    if(type==HGBLocationTypeLocation){
        // 启动自动跟踪定位
        [self.locationManager startUpdatingLocation];
        if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied||[CLLocationManager authorizationStatus] ==kCLAuthorizationStatusRestricted) {

            NSString *promptString=@"";
            promptString=@"定位失败:请到设置隐私中开启本程序定位权限";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeAuthority).stringValue,ReslutMessage:promptString}];
            }

        }
    }else if(type==HGBLocationTypeHeader){
        // 启动自动跟踪定位方向
        [self.locationManager startUpdatingHeading];
    }else{
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied||[CLLocationManager authorizationStatus] ==kCLAuthorizationStatusRestricted) {

            NSString *promptString=@"";
            promptString=@"定位失败:请到设置隐私中开启本程序定位权限";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeAuthority).stringValue,ReslutMessage:promptString}];
            }

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
        if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
            [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeLocationError).stringValue,ReslutMessage:@"定位失败"}];
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

                [locationMarks addObject:[HGBLocation transPlaceMarkToLocationInfoDic:mark]];
            }
            [self.locationManager stopUpdatingLocation];
        }
        if(error){
            HGBLog(@"%@",error);
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeLocationError).stringValue,ReslutMessage:error.localizedDescription}];
            }
            return;
        }

        if(locationMarks.count==0){
            HGBLog(@"目标地址不存在");
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeLocationError).stringValue,ReslutMessage:@"目标地址不存在"}];
            }
            return;
        }
        if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didSucessWithLocationInfo:)]){
            [self.delegate loaction:self didSucessWithLocationInfo:[locationMarks lastObject]];
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
    if(self.isRepeat){
        [self postLocation:location];
    }else{
        if(flag_location == 0){
            [self postLocation:location];
        }
        flag_location++;
        [self.locationManager stopUpdatingLocation];
    }

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
        if(self.isRepeat){
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didSucessWithHeaderInfo:)]){
                [self.delegate loaction:self didSucessWithHeaderInfo:headerInfo];
            }
        }else{
            if(flag_head == 0){
                if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didSucessWithHeaderInfo:)]){
                    [self.delegate loaction:self didSucessWithHeaderInfo:headerInfo];
                }
            }
            flag_head++;
            [self.locationManager startUpdatingHeading];
        }



    }else{
        HGBLog(@"磁力计失效");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
            [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeLocationError).stringValue,ReslutMessage:@"磁力计失效"}];
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
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeAuthority).stringValue,ReslutMessage:promptString}];
            }
            [self jumpToSet];

        }
            break;
        case kCLErrorLocationUnknown:{
           promptString=@"定位失败，请刷新数据";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeLocationError).stringValue,ReslutMessage:promptString}];
            }
             [HGBLocationPromgressHud  showHUDResult:promptString ToView:[UIApplication sharedApplication].keyWindow];
        }
            break;
        default:{
           promptString=@"定位失败，请刷新数据";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(loaction:didFailedWithError:)]){
                [self.delegate loaction:self didFailedWithError:@{ReslutCode:@(HGBLocationErrorTypeLocationError).stringValue,ReslutMessage:promptString}];
            }
             [HGBLocationPromgressHud  showHUDResult:promptString ToView:[UIApplication sharedApplication].keyWindow];
        }
            break;
    }
    HGBLog(@"探测失败:%@-%@",promptString,error);


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
#pragma mark --set
-(void)jumpToSet{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"定位访问权限受限" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alert addAction:action1];
    UIAlertAction *action2=[UIAlertAction actionWithTitle:@"去设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if([[UIApplication sharedApplication] canOpenURL:url]) {

            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];

        }

    }];
    [alert addAction:action2];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
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
#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
- (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}
/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
- (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [self findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
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
