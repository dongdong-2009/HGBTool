//
//  HGBClientUSBTool.h
//  测试
//
//  Created by huangguangbao on 2018/4/13.
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
typedef enum HGBClientUSBToolError
{
    HGBClientUSBToolErrorTypeParams=0,//参数错误
    HGBClientUSBToolErrorTypeDevice=10,//设备错误
    HGBClientUSBToolErrorTypeConnect=32,//链接失效
    HGBClientUSBToolErrorTypeMesssage=33,//消息发送失败
    HGBClientUSBToolErrorTypeFailed=99//接口监听失败

}HGBClientUSBToolError;

/**
 数据类型
 */
typedef enum HGBClientUSBToolDataType
{
    HGBClientUSBToolDataTypeData,//二进制数据
    HGBClientUSBToolDataTypeFile,//文件
    HGBClientUSBToolDataTypeImage,//图片
    HGBClientUSBToolDataTypeDictionary,//字典
    HGBClientUSBToolDataTypeArray,//数组
    HGBClientUSBToolDataTypeString,//字符串
    HGBClientUSBToolDataTypeNumber//数字
}HGBClientUSBToolDataType;



@class HGBClientUSBTool;
@protocol HGBClientUSBToolDelegate <NSObject>
@optional

/**
 监听接口成功

 @param USBTool USB工具
 @param ip ip地址
 @param port 端口号
 */
- (void)USBTool:(HGBClientUSBTool*)USBTool didSucessedListenServiceOnIp:(NSString *)ip andWithPort:(NSString *)port;

/**
 监听链接成功

 @param USBTool USB工具
 @param ip ip地址
 @param port 端口号
 */
- (void)USBTool:(HGBClientUSBTool*)USBTool didSucessedToConnectOnIp:(NSString *)ip andWithPort:(NSString *)port;

/**
 监听接口失败
 @param USBTool USB工具
 @param errorInfo 错误信息
 */
- (void)USBTool:(HGBClientUSBTool*)USBTool didFailedOnListenServiceWithError:(NSDictionary *)errorInfo;


/**
 错误
 @param USBTool USB工具
 @param errorInfo 错误信息
 */
- (void)USBTool:(HGBClientUSBTool*)USBTool didFailedWithError:(NSDictionary *)errorInfo;
/**
 发送设备信息成功
 @param USBTool USB工具
 */
- (void)USBToolDidSucessSendDeviceInfo:(HGBClientUSBTool*)USBTool;
/**
 发送信息成功
 @param USBTool USB工具
 */
- (void)USBToolDidSucessSendMessage:(HGBClientUSBTool*)USBTool;

/**
 链接关闭
 @param USBTool USB工具
 @param Info 信息
 */
- (void)USBTool:(HGBClientUSBTool*)USBTool didClosedWithInfo:(NSDictionary *)Info;

/**
 收到消息
 @param USBTool USB工具
 @param message 信息
 @param messageType 数据类型
 */
- (void)USBTool:(HGBClientUSBTool*)USBTool didReciveMessage:(id )message andWithMessageType:(HGBClientUSBToolDataType )messageType;

@end



@interface HGBClientUSBTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBClientUSBToolDelegate>delegate;

#pragma mark init

/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;

#pragma mark 客户端

/**
 监听接口
 */
-(void)listenService;
/**
 发送消息

 @param source 数据源
 */
- (void)sendSource:(id)source;
@end
