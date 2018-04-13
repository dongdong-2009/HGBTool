//
//  HGBUSBServiceTool.h
//  测试
//
//  Created by huangguangbao on 2018/4/12.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

/**
 错误类型
 */
typedef enum HGBUSBServiceToolError
{
    HGBUSBServiceToolErrorTypeParams=0,//参数错误
    HGBUSBServiceToolErrorTypeDevice=10,//设备错误
    HGBUSBServiceToolErrorTypeConnect=32,//链接失效
    HGBUSBServiceToolErrorTypeMesssage=33,//消息发送失败
    HGBUSBServiceToolErrorTypeFailed=99//接口监听失败

}HGBUSBServiceToolError;


/**
 数据类型
 */
typedef enum HGBUSBServiceToolDataType
{
    HGBUSBServiceToolDataTypeData,//二进制数据
    HGBUSBServiceToolDataTypeFile,//文件
    HGBUSBServiceToolDataTypeImage,//图片
    HGBUSBServiceToolDataTypeDictionary,//字典
    HGBUSBServiceToolDataTypeArray,//数组
    HGBUSBServiceToolDataTypeString,//字符串
    HGBUSBServiceToolDataTypeNumber//数字
}HGBUSBServiceToolDataType;


@class HGBUSBServiceTool;
@protocol HGBUSBServiceToolDelegate <NSObject>
@optional

/**
 链接设备成功

 @param USBTool USB工具
 @param deviceid 设备id
 */
- (void)USBTool:(HGBUSBServiceTool*)USBTool didAttachWithDeviceId:(NSNumber *)deviceid;
/**
 取消链接成功

 @param USBTool USB工具
 @param deviceid 设备id
 */
- (void)USBTool:(HGBUSBServiceTool*)USBTool didDetachWithDeviceId:(NSNumber *)deviceid;

/**
 链接链接成功

 @param USBTool USB工具
 @param ip ip地址
 @param port 端口号
 */
- (void)USBTool:(HGBUSBServiceTool*)USBTool didSucessedToConnectOnIp:(NSString *)ip andWithPort:(NSString *)port;



/**
 错误
 @param USBTool USB工具
 @param errorInfo 错误信息
 */
- (void)USBTool:(HGBUSBServiceTool*)USBTool didFailedWithError:(NSDictionary *)errorInfo;
/**
 发送设备信息成功
 @param USBTool USB工具
  @param info 设备信息
 */
- (void)USBTool:(HGBUSBServiceTool*)USBTool didSucessReciveDeviceInfo:(NSDictionary*)info;
/**
 发送信息成功
 @param USBTool USB工具
 */
- (void)USBToolDidSucessSendMessage:(HGBUSBServiceTool*)USBTool;

/**
 链接关闭
 @param USBTool USB工具
 @param Info 信息
 */
- (void)USBTool:(HGBUSBServiceTool*)USBTool didClosedWithInfo:(NSDictionary *)Info;

/**
 收到消息
 @param USBTool USB工具
 @param message 信息
 @param messageType 数据类型
 */
- (void)USBTool:(HGBUSBServiceTool *)USBTool didReciveMessage:(id )message andWithMessageType:(HGBUSBServiceToolDataType )messageType;

@end
@interface HGBUSBServiceTool : NSObject
/**
 代理
 */
@property(strong,nonatomic)id<HGBUSBServiceToolDelegate>delegate;
#pragma mark init

/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;

/**
 监听设备
 */
- (void)startListeningForDevices;

/**

取消链接设备
 @param deviceID 设备id
 */
- (void)didDisconnectFromDevice:(NSNumber*)deviceID;

/**
 发送消息

 @param source 数据源
 */
- (void)sendSource:(id)source;
@end
