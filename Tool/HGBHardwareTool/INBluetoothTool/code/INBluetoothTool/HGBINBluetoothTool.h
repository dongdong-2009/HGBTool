//
//  HGBINBluetoothTool.h
//  测试
//
//  Created by huangguangbao on 2017/12/15.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */


@class HGBINBluetoothTool;

/**
 错误类型
 */
typedef enum HGBINBluetoothToolError
{
    HGBINBluetoothToolErrorTypeParams=0,//参数错误
    HGBINBluetoothToolErrorTypeDevice=10,//设备错误
    HGBINBluetoothToolErrorTypeConnectedFailed=31,//链接失败
    HGBINBluetoothToolErrorTypeNotConnected=32,//未链接
    HGBINBluetoothToolErrorTypeContact=33//通讯错误

}HGBINBluetoothToolError;

/**
 状态
 */
typedef enum HGBINBluetoothToolStatus
{
    HGBINBluetoothToolStatusNotConnected,//未链接
    HGBINBluetoothToolStatusConnecting,//正在链接
    HGBINBluetoothToolStatusConnected//已链接

}HGBINBluetoothToolStatus;


/**
 状态
 */
typedef enum HGBINBluetoothToolDataTransType
{
    HGBINBluetoothToolDataTransTypeTCP,//tcp方式
    HGBINBluetoothToolDataTransTypeUDP//udp方式
}HGBINBluetoothToolDataTransType;


/**
 数据类型
 */
typedef enum HGBINBluetoothToolDataType
{
    HGBINBluetoothToolDataTypeData,//二进制数据
    HGBINBluetoothToolDataTypeImage,//图片
    HGBINBluetoothToolDataTypeDictionary,//字典
    HGBINBluetoothToolDataTypeArray,//数组
    HGBINBluetoothToolDataTypeString,//字符串
    HGBINBluetoothToolDataTypeNumber//数字
}HGBINBluetoothToolDataType;

@protocol HGBINBluetoothToolDelegate <NSObject>

@optional
/**
 接收数据

 @param bluetooth 蓝牙工具
 @param data 数据
 @param userName 用户名
 */
- (void)inbluetooth:(HGBINBluetoothTool*)bluetooth didReciveData:(NSData *)data answithUserName:(NSString*)userName;
/**
 接收格式处理后数据

 @param bluetooth 蓝牙工具
 @param message 消息
 @param dataType 数据类型
 @param userName 用户名
 */
- (void)inbluetooth:(HGBINBluetoothTool*)bluetooth didReciveMessage:(id )message andWithMessageType:(HGBINBluetoothToolDataType)dataType answithUserName:(NSString*)userName;
/**
 完成蓝牙列表

 @param bluetooth 蓝牙工具
 */
- (void)inbluetoothDidFinishBluetoothList:(HGBINBluetoothTool*)bluetooth;
/**
 取消蓝牙列表

 @param bluetooth 蓝牙工具
 */
- (void)inbluetoothDidCancelBluetoothList:(HGBINBluetoothTool*)bluetooth;

/**
 蓝牙状态变化

 @param bluetooth 蓝牙工具
 @param status 状态
 @param statusInfo 状态信息
 */
- (void)inbluetooth:(HGBINBluetoothTool*)bluetooth didChangeStatus:(HGBINBluetoothToolStatus)status andWithStatusInfo:(NSDictionary *)statusInfo;

/**
 蓝牙出错

 @param bluetooth 蓝牙工具
 @param errorInfo 错误信息
 */
- (void)inbluetooth:(HGBINBluetoothTool*)bluetooth didFailedWithError:(NSDictionary *)errorInfo;
@end

@interface HGBINBluetoothTool : NSObject

/**
 代理
 */
@property(strong,nonatomic)id<HGBINBluetoothToolDelegate> delegate;

/**
 数据传输方式
 */
@property(assign,nonatomic)HGBINBluetoothToolDataTransType dataTransType;

/**
 单例-蓝牙服务名

 @param serviceName 蓝牙服务名
 @param bluetoothName 蓝牙名
 @return 单例
 */
+ (instancetype)shareInstanceWithServiceName:(NSString *)serviceName andWithBlueToothName:(NSString *)bluetoothName;
/**
 单例
 @return 单例
 */
+ (instancetype)shareInstance;
#pragma mark 设置
/**
 重设蓝牙配置

 @param serviceName 蓝牙服务名
 @param bluetoothName 蓝牙名
 */
-(void)resetServiceName:(NSString *)serviceName andWithBlueToothName:(NSString *)bluetoothName;

#pragma mark 功能

/**
 开启蓝牙广播模式
 @return 结果
 */
-(BOOL)startBroadCasting;
/**
开启蓝牙广播模式
@param serviceName 蓝牙服务名
@param bluetoothName 蓝牙名
@return 结果
*/
-(BOOL)startBroadCastingWithServiceName:(NSString *)serviceName andWithBlueToothName:(NSString *)bluetoothName;
/**
 关闭广播模式

 @return 结果
 */
-(BOOL)stopBroadCasting;
/**
 扫描蓝牙列表

 @return 结果
 */
-(BOOL)scanBlueToothList;
/**
  扫描蓝牙列表
  @param serviceName 蓝牙服务名
  @return 结果
*/
-(BOOL)scanBlueToothListWithServiceName:(NSString *)serviceName;
/**
 发送消息

 @param message 消息 支持 字符串，数字，数组(字符串，数字，数组，字典)，字典,二进制数据，图片
 @return 发送结果
 */
-(BOOL)sendMessage:(id)message;
/**
 发送消息

 @param message 消息 支持 字符串，数字，数组(字符串，数字，数组，字典)，字典,二进制数据，图片
 @param peerIDs 蓝牙设备
 @return 发送结果
 */
-(BOOL)sendMessage:(id)message toPeers:(NSArray<MCPeerID *> *)peerIDs;
/**
 获取已链接蓝牙

 @return 蓝牙设备
 */
-(NSArray<MCPeerID *> *)getConnectPeers;

@end
