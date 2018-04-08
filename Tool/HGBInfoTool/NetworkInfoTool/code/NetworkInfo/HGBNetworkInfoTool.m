//
//  HGBNetworkInfoTool.m
//  测试
//
//  Created by huangguangbao on 2018/1/12.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBNetworkInfoTool.h"
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBNetworkInfoTool
/**
 获取网络类型

 @return 网络类型
 */
+(HGBNetworkType )getNetworkType
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    HGBNetworkType type=HGBNetworkTypeNone;
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType) {
                case 0:
                    type=HGBNetworkTypeNone;
                    break;
                case 1:
                    type=HGBNetworkType2G;
                    break;
                case 2:
                    type=HGBNetworkType3G;
                    break;
                case 3:
                    type=HGBNetworkType4G;
                    break;
                case 5:
                {
                    type=HGBNetworkTypeWIFI;
                }
                    break;
                default:
                    type=HGBNetworkTypeOther;
                    break;
            }
        }
    }
    return type;
}
/**
 获取网络信号强度

 @return 获取网络信号强度
 */
+(int)getSignalStrength{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;

    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    return signalStrength;
}


/**
 获取流量

 @param isTransUnit 是否进行单位转换 YES会转换为最高单位并带单位符号B KB MB GB NO 直接返回字节大小
  @return 流量字典
 */
+ (NSDictionary *)getFlowIOBytesWithUnitType:(BOOL)isTransUnit
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;

    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WiFiFlow=0;
    int WWANSent = 0;
    int WWANReceived = 0;
    int WWANFlow=0;
    int NetworkFlow=0;

    NSString *name=[[NSString alloc]init];
    NSString *changeTime=[NSString stringWithFormat:@"%s",ctime(&time)];

    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN

            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                }

                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }

            cursor = cursor->ifa_next;
        }

        freeifaddrs(addrs);
    }
    WiFiFlow=WiFiSent+WiFiReceived;
    WWANFlow=WWANSent+WWANReceived;
    NetworkFlow=WiFiFlow+WWANFlow;
    NSString *WiFiSentString=@"";
    NSString * WiFiReceivedString=@"";
    NSString * WWANSentString=@"";
    NSString * WWANReceivedString=@"";
    NSString * WWANFlowString=@"";
    NSString * WiFiFlowString=@"";
    NSString * NetworkFlowString=@"";

    WWANReceived=abs(WWANReceived);
    WiFiReceived=abs(WiFiReceived);
    if(isTransUnit){
        WiFiSentString=[self transBytesUnitWithBytes:WiFiSent];
        WiFiReceivedString=[NSString stringWithFormat:@"-%@",[self transBytesUnitWithBytes:WiFiReceived]];
        WWANSentString=[self transBytesUnitWithBytes:WWANSent];
        WWANReceivedString=[NSString stringWithFormat:@"-%@",[self transBytesUnitWithBytes:WWANReceived]];

         WWANFlowString=[NSString stringWithFormat:@"-%@",[self transBytesUnitWithBytes:WWANFlow]];
         WiFiFlowString=[NSString stringWithFormat:@"-%@",[self transBytesUnitWithBytes:WiFiFlow]];
         NetworkFlowString=[NSString stringWithFormat:@"-%@",[self transBytesUnitWithBytes:NetworkFlow]];

    }else{
        WiFiSentString=[NSString stringWithFormat:@"%d",WiFiSent];
        WiFiReceivedString=[NSString stringWithFormat:@"%d",WiFiReceived];
        WWANSentString=[NSString stringWithFormat:@"%d",WWANSent];
        WWANReceivedString=[NSString stringWithFormat:@"%d",WWANReceived];
        WWANFlowString=[NSString stringWithFormat:@"%d",WWANFlow];
        WiFiFlowString=[NSString stringWithFormat:@"%d",WiFiFlow];
        NetworkFlowString=[NSString stringWithFormat:@"%d",NetworkFlow];


    }
    NSDictionary *dic=@{@"WiFiSent":WiFiSentString,@"WiFiReceived":WiFiReceivedString,@"WWANSent":WWANSentString,@"WWANReceived":WWANReceivedString,@"WWANFlow":WWANFlowString,@"WiFiFlow":WiFiFlowString,@"NetworkFlow":NetworkFlowString,@"changeTime":changeTime};

    return dic;
}
/**
 获取3G或者GPRS的流量

 @param isTransUnit 是否进行单位转换 YES会转换为最高单位并带单位符号B KB MB GB NO 直接返回字节大小

 @return 3G或者GPRS的流量
 */
+ (NSString *)getGprs3GFlowIOBytesWithUnitType:(BOOL)isTransUnit
{

    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }

    uint32_t iBytes = 0;
    uint32_t oBytes = 0;

    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;

        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;

        if (ifa->ifa_data == 0)
            continue;

        //3G或者GPRS
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;

            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }


    freeifaddrs(ifa_list);

    uint32_t bytes = 0;

    bytes = iBytes + oBytes;


    if(isTransUnit){
        return [HGBNetworkInfoTool transBytesUnitWithBytes:bytes];
    }else{
        return [NSString stringWithFormat:@"%d",bytes];
    }

}
/**
 获取Wifi流量

 @param isTransUnit 是否进行单位转换 YES会转换为最高单位并带单位符号B KB MB GB NO 直接返回字节大小

 @return Wifi流量
 */
+ (NSString *)getGprsWifiFlowIOBytesWithUnitType:(BOOL)isTransUnit
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return 0;
    }
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;

        //Wifi
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }

    freeifaddrs(ifa_list);

    uint32_t bytes = 0;

    bytes = iBytes+oBytes;

    if(isTransUnit){
        return [HGBNetworkInfoTool transBytesUnitWithBytes:bytes];
    }else{
        return [NSString stringWithFormat:@"%d",bytes];
    }


}
/**
 将byte转化为最高等级单位

 @param bytes byte
 @return 结果
 */
+(NSString *)transBytesUnitWithBytes:(int)bytes{
    //将bytes单位转换
    if(bytes < 1024)        // B
    {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024)    // KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)    // MB
    {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}
@end
