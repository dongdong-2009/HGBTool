//
//  HGBGeoPositionTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/27.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBGeoPositionTool.h"
#import <CoreLocation/CoreLocation.h>

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBGeoPositionTool
#pragma mark - 获取地理位置信息
/**
 地理位置转地理信息

 @param coordinate 地理位置
 @param reslut 结果
 */
+(void)getLocationInfoWithCoordinate:(CLLocationCoordinate2D )coordinate andWithReslutBlock:(void(^)(BOOL status,NSDictionary *info,NSArray *infos,CLPlacemark *mark,NSArray *marks))reslut{
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [HGBGeoPositionTool getLocationInfoWithLocation:location andWithReslutBlock:reslut];
}

/**
 地理位置转地理信息

 @param location 地理位置
 @param reslut 结果
 */
+(void)getLocationInfoWithLocation:(CLLocation *)location andWithReslutBlock:(void(^)(BOOL status,NSDictionary *info,NSArray *infos,CLPlacemark *mark,NSArray *marks))reslut{

    if(location==nil){
        HGBLog(@"location不能为空");
         reslut(NO,nil,nil,nil,nil);
        return;
    }
    NSMutableArray *locationMarks=[NSMutableArray array];
     CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(placemarks.count==0){
        }else{
            for(CLPlacemark *mark in placemarks){

                [locationMarks addObject:[HGBGeoPositionTool transPlaceMarkToLocationInfoDic:mark]];
            }

        }
        if(error){
            reslut(NO,@{ReslutCode:@(error.code),ReslutMessage:error.localizedDescription},nil,nil,nil);
            HGBLog(@"地理编码出错:%@",error);
            return;
        }

        if(locationMarks.count==0){
            HGBLog(@"目标地址不存在");
            reslut(NO,@{ReslutCode:@(0),ReslutMessage:@"目标地址不存在"},nil,nil,nil);
        }else{
            NSDictionary *dic=[locationMarks lastObject];
            reslut(NO,dic,locationMarks,[placemarks lastObject],placemarks);
        }
        
    }];
}
/**
 地理位置转地理信息

 @param string 搜索信息
 @param reslut 结果
 */
+(void)getLocationInfoWithString:(NSString *)string andWithReslutBlock:(void(^)(BOOL status,NSDictionary *info,NSArray *infos,CLPlacemark *mark,NSArray *marks))reslut{
    if(string==nil||string.length==0){
        HGBLog(@"string不能为空");
        reslut(NO,nil,nil,nil,nil);
        return ;
    }
    NSMutableArray *locationMarks=[NSMutableArray array];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder geocodeAddressString:string completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(placemarks.count==0){
        }else{
            for(CLPlacemark *mark in placemarks){

                [locationMarks addObject:[HGBGeoPositionTool transPlaceMarkToLocationInfoDic:mark]];
            }

        }
        if(error){
           HGBLog(@"地理编码出错:%@",error); reslut(NO,@{ReslutCode:@(error.code),ReslutMessage:error.localizedDescription},nil,nil,nil);

            return;
        }

        if(locationMarks.count==0){
             HGBLog(@"目标地址不存在");
            reslut(NO,@{ReslutCode:@(0),ReslutMessage:@"目标地址不存在"},nil,nil,nil);
        }else{
            NSDictionary *dic=[locationMarks lastObject];
            reslut(NO,dic,locationMarks,[placemarks lastObject],placemarks);
        }
    }];

}
#pragma mark - 转换地理位置信息为字典
+(NSDictionary *)transPlaceMarkToLocationInfoDic:(CLPlacemark *)mark{
    if(mark==nil){
        HGBLog(@"地理位置不能为空");
        return nil;
    }
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
    return dic;
}

@end
