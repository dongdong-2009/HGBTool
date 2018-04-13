//
//  HGBINBluetoothTool.m
//  测试
//
//  Created by huangguangbao on 2017/12/15.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBINBluetoothTool.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBINBluetoothTool()<MCSessionDelegate,MCBrowserViewControllerDelegate>


/**
 广播端服务名
 */
@property(strong,nonatomic)NSString *serviceName;
/**
 广播端蓝牙名
 */
@property(strong,nonatomic)NSString *bluetoothName;


/**
 广播端两台设备之间的会话－链接就是路
 */
@property(strong,nonatomic)MCSession *session;

/**
 广播端蓝牙助手
 */
@property(strong,nonatomic)MCAdvertiserAssistant *assistant;
/**
 广播端蓝牙身份
 */
@property(strong,nonatomic)MCPeerID *peer;

/**
 蓝牙操作表
 */
@property(strong,nonatomic)MCBrowserViewController *browser;



@end
@implementation HGBINBluetoothTool
static HGBINBluetoothTool*instance=nil;
#pragma mark init
/**
 单例-蓝牙服务名

 @param serviceName 蓝牙服务名
 @param bluetoothName 蓝牙名
 @return 单例
 */
+ (instancetype)shareInstanceWithServiceName:(NSString *)serviceName andWithBlueToothName:(NSString *)bluetoothName
{
    if (instance==nil) {
        instance=[[HGBINBluetoothTool alloc]init];
    }
    instance.serviceName=serviceName;
    instance.bluetoothName=bluetoothName;
    instance.peer=[[MCPeerID alloc]initWithDisplayName:instance.bluetoothName];
    instance.session=[[MCSession alloc]initWithPeer:instance.peer];
    instance.session.delegate=instance;
    return instance;
}
/**
 单例
 @return 单例
 */
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBINBluetoothTool alloc]init];
    }

    return instance;
}
#pragma mark 设置
/**
 重设蓝牙配置

 @param serviceName 蓝牙服务名
 @param bluetoothName 蓝牙名
 */
-(void)resetServiceName:(NSString *)serviceName andWithBlueToothName:(NSString *)bluetoothName{
    self.serviceName=serviceName;
    self.bluetoothName=bluetoothName;
    self.peer=[[MCPeerID alloc]initWithDisplayName:self.bluetoothName];
    self.session=[[MCSession alloc]initWithPeer:self.peer];
}

#pragma mark 功能
/**
 开启蓝牙广播模式
 @return 结果
 */
-(BOOL)startBroadCasting{
    if(self.serviceName==nil||self.serviceName.length==0){
        HGBLog(@"服务名不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"服务名不能为空"}];
        }
        return NO;
    }
    if(self.bluetoothName==nil||self.bluetoothName.length==0){
        HGBLog(@"蓝牙名不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"蓝牙名不能为空"}];
        }
        return NO;
    }
    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return NO;
    }
    //广播端
    //获取系统当前的蓝牙设备,并设置显示在对方view的名字
    self.assistant=[[MCAdvertiserAssistant alloc]initWithServiceType:self.serviceName discoveryInfo:nil session:self.session];
    //开始广播
    [self.assistant start];
    return YES;
}
/**
  开启蓝牙广播模式
 @param serviceName 蓝牙服务名
 @param bluetoothName 蓝牙名
 @return 结果
*/
-(BOOL)startBroadCastingWithServiceName:(NSString *)serviceName andWithBlueToothName:(NSString *)bluetoothName{
    self.serviceName=serviceName;
    self.bluetoothName=bluetoothName;
    self.peer=[[MCPeerID alloc]initWithDisplayName:self.bluetoothName];
    self.session=[[MCSession alloc]initWithPeer:self.peer];
    if(self.serviceName==nil||self.serviceName.length==0){
        HGBLog(@"服务名不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"服务名不能为空"}];
        }
        return NO;
    }
    if(self.bluetoothName==nil||self.bluetoothName.length==0){
        HGBLog(@"蓝牙名不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"蓝牙名不能为空"}];
        }
        return NO;
    }
    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return NO;
    }
    //广播端
    //获取系统当前的蓝牙设备,并设置显示在对方view的名字
    self.assistant=[[MCAdvertiserAssistant alloc]initWithServiceType:self.serviceName discoveryInfo:nil session:self.session];
    //开始广播
    [self.assistant start];
    return YES;
}
/**
 关闭蓝牙广播模式

 @return 结果
 */
-(BOOL)stopBroadCasting{
    if(self.assistant){
        [self.assistant stop];
    }else{
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeDevice).stringValue,ReslutMessage:@"蓝牙未开启"}];
        }
        return NO;
    }
    return YES;
}
/**
 扫描蓝牙列表

 @return 结果
 */
-(BOOL)scanBlueToothList{
    if(self.serviceName==nil||self.serviceName.length==0){
        HGBLog(@"服务名不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"服务名不能为空"}];
        }
        return NO;
    }

    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return NO;
    }

    if(self.browser==nil){
        self.browser=[[MCBrowserViewController alloc]initWithServiceType:self.serviceName session:self.session];
    }
    self.browser.delegate=self;
    [[HGBINBluetoothTool currentViewController] presentViewController:self.browser animated:YES completion:nil];
    return YES;
}
/**
扫描蓝牙列表
@param serviceName 蓝牙服务名
@return 结果
*/
-(BOOL)scanBlueToothListWithServiceName:(NSString *)serviceName{
    self.serviceName=serviceName;

    if(self.serviceName==nil||self.serviceName.length==0){
        HGBLog(@"服务名不能为空");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"服务名不能为空"}];
        }
        return NO;
    }
    
    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return NO;
    }

    if(self.browser==nil){
        self.browser=[[MCBrowserViewController alloc]initWithServiceType:self.serviceName session:self.session];
    }
    self.browser.delegate=self;
    [[HGBINBluetoothTool currentViewController] presentViewController:self.browser animated:YES completion:nil];
    return YES;

}
/**
 获取已链接蓝牙

 @return 蓝牙设备
 */
-(NSArray<MCPeerID *> *)getConnectPeers{

    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return nil;
    }
    return self.session.connectedPeers;

}
/**
 发送消息

 @param message 消息 支持 字符串，数字，数组(字符串，数字，数组，字典,)，字典,二进制数据，图片
 @return 发送结果
 */
-(BOOL)sendMessage:(id)message{

    NSData *data=[HGBINBluetoothTool messageEncapsulation:message];
    if(!data){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"参数错误"}];
        }
        HGBLog(@"参数错误");
        return NO;
    }
    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return NO;
    }
   return [self sendMessage:message toPeers:self.session.connectedPeers];

}
/**
 发送消息

 @param message 消息 支持 字符串，数字，数组(字符串，数字，数组，字典,)，字典,二进制数据，图片
 @param peerIDs 蓝牙设备
 @return 发送结果
 */
-(BOOL)sendMessage:(id)message toPeers:(NSArray<MCPeerID *> *)peerIDs{

    if(peerIDs==nil){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"参数错误"}];
        }
        HGBLog(@"参数错误");
        return NO;
    }
    NSData *data=[HGBINBluetoothTool messageEncapsulation:message];
    if(!data){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeParams).stringValue,ReslutMessage:@"参数错误"}];
        }
        HGBLog(@"参数错误");
        return NO;
    }
    if(self.session==nil){
        HGBLog(@"初始化失败");
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"初始化失败"}];
        }
        return NO;
    }
    //tcp:transport control protocol传输控制协议
    //在两台设备传输数据之前要进行三次握手,可以100%保证传输到对方设备中,但效率低
    //udp:user diagram protocol用户数据报协议
    //不可以100%保证传输到对方设备中,但效率高
    //MCSessionSendDataReliable-tcp
    //MCSessionSendDataUnReliable-udp

    MCSessionSendDataMode type;
    if(self.dataTransType==HGBINBluetoothToolDataTransTypeTCP){
        type=MCSessionSendDataReliable;
    }else{
        type=MCSessionSendDataUnreliable;
    }
    //得到其他设备
    NSError *error;
    BOOL flag=[self.session sendData:data toPeers:peerIDs withMode:type error:&error];
    if(flag==NO){
        if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
            [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeContact).stringValue,ReslutMessage:@"数据发送错误"}];
        }
        HGBLog(@"%@",error);
    }
    return flag;
}
#pragma mark browser
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{

    if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetoothDidFinishBluetoothList:)]){
        [self.delegate inbluetoothDidFinishBluetoothList:self];
    }
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetoothDidCancelBluetoothList:)]){
        [self.delegate inbluetoothDidCancelBluetoothList:self];
    }
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark sessiondelegate
//监听两台设备之间状态的变化
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    HGBINBluetoothToolStatus status;
    NSString *prompt;
    switch (state) {
        case MCSessionStateConnected:
            status=HGBINBluetoothToolStatusConnected;
            prompt=@"已链接";
            break;
        case MCSessionStateNotConnected:
            status=HGBINBluetoothToolStatusNotConnected;
            prompt=@"未链接或链接失败";
            if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didFailedWithError:)]){
                [self.delegate inbluetooth:self didFailedWithError:@{ReslutCode:@(HGBINBluetoothToolErrorTypeConnectedFailed).stringValue,ReslutMessage:@"未链接或链接失败"}];
            }
            HGBLog(@"未链接或链接失败");
            break;
        case MCSessionStateConnecting:
            status=HGBINBluetoothToolStatusConnecting;
            prompt=@"正在链接";
            break;
        default:
            break;
    }
    if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didChangeStatus:andWithStatusInfo:)]){
        [self.delegate inbluetooth:self didChangeStatus:status andWithStatusInfo:@{@"status":@(status),@"description":prompt}];
    }

}

// 收到对方传递的信息
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didReciveData:answithUserName:)]){
        [self.delegate inbluetooth:self didReciveData:data answithUserName:peerID.displayName];
    }

    id message=[HGBINBluetoothTool messageAnalysis:data];
    HGBINBluetoothToolDataType type=[HGBINBluetoothTool messageAnalysisToType:data];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(inbluetooth:didReciveMessage:andWithMessageType:answithUserName:)]){
        [self.delegate inbluetooth:self didReciveMessage:message andWithMessageType:type answithUserName:peerID.displayName];
    }



}

// Received a byte stream from remote peer.
- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID{

}

// Start receiving a resource from remote peer.
- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress{

}

// Finished receiving a resource from remote peer and saved the content
// in a temporary location - the app is responsible for moving the file
// to a permanent location within its sandbox.
- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error{

}
#pragma mark 数据格式转换
/**
 数据编码

 @param message 数据
 @return data
 */
+(NSData *)messageEncapsulation:(id)message{
    NSData *data;
    if([message isKindOfClass:[NSData class]]){
        data=message;
    }else if([message isKindOfClass:[NSString class]]){
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[NSArray class]]){
        message=[HGBINBluetoothTool ObjectToJSONString:message];
        message=[@"array://" stringByAppendingString:message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[NSDictionary class]]){
        message=[HGBINBluetoothTool ObjectToJSONString:message];
        message=[@"dictionary://" stringByAppendingString:message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }else if([message isKindOfClass:[UIImage class]]){
        data=UIImagePNGRepresentation(message);
    }else if([message isKindOfClass:[NSNumber class]]){
        message=[NSString stringWithFormat:@"number://%@",message];
        data=[message dataUsingEncoding:NSUTF8StringEncoding];
    }
    return data;
}
/**
 数据解码

 @param data 数据
 @return 解码后数据
 */
+(id)messageAnalysis:(NSData *)data{
    id message;
    HGBINBluetoothToolDataType type;
    NSString *string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(string){
        if([string hasPrefix:@"array://"]){
            string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
            message=[HGBINBluetoothTool JSONStringToObject:string];
             type=HGBINBluetoothToolDataTypeArray;
        }else if ([string hasPrefix:@"dictionary://"]){
            string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
            message=[HGBINBluetoothTool JSONStringToObject:string];
            type=HGBINBluetoothToolDataTypeDictionary;
        }else if ([string hasPrefix:@"number://"]){
            type=HGBINBluetoothToolDataTypeNumber;
            string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
            message=[[NSNumber alloc]initWithFloat:string.floatValue];
        }else{
            type=HGBINBluetoothToolDataTypeString;
            message=string;
        }
    }else{
        UIImage *image=[UIImage imageWithData:data];
        if(image){
             type=HGBINBluetoothToolDataTypeImage;
            message=image;
        }else{
            type=HGBINBluetoothToolDataTypeData;
            message=data;
        }
    }
    return message;

}
/**
 数据解密后类型

 @param data 数据
 @return 解码后数据
 */
+(HGBINBluetoothToolDataType)messageAnalysisToType:(NSData *)data{
    id message;
    HGBINBluetoothToolDataType type;
    NSString *string=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(string){
        if([string hasPrefix:@"array://"]){
            string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
            message=[HGBINBluetoothTool JSONStringToObject:string];
            type=HGBINBluetoothToolDataTypeArray;
        }else if ([string hasPrefix:@"dictionary://"]){
            string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
            message=[HGBINBluetoothTool JSONStringToObject:string];
            type=HGBINBluetoothToolDataTypeDictionary;
        }else if ([string hasPrefix:@"number://"]){
            type=HGBINBluetoothToolDataTypeNumber;
            string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
            message=[[NSNumber alloc]initWithFloat:string.floatValue];
        }else{
            type=HGBINBluetoothToolDataTypeString;
            message=string;
        }
    }else{
        UIImage *image=[UIImage imageWithData:data];
        if(image){
            type=HGBINBluetoothToolDataTypeImage;
            message=image;
        }else{
            type=HGBINBluetoothToolDataTypeData;
            message=data;
        }
    }
    return type;

}
#pragma mark JSON
/**
 把Json对象转化成json字符串

 @param object json对象
 @return json字符串
 */
+ (NSString *)ObjectToJSONString:(id)object
{
    if(!([object isKindOfClass:[NSDictionary class]]||[object isKindOfClass:[NSArray class]]||[object isKindOfClass:[NSString class]])){
        return nil;
    }
    if([object isKindOfClass:[NSString class]]){
        return object;
    }
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}
/**
 把Json字符串转化成json对象

 @param jsonString json字符串
 @return json字符串
 */
+ (id)JSONStringToObject:(NSString *)jsonString{
    if(![jsonString isKindOfClass:[NSString class]]){
        return nil;
    }
    jsonString=[HGBINBluetoothTool jsonStringHandle:jsonString];
    //    HGBLog(@"%@",jsonString);
    NSError *error = nil;
    NSData  *data=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"{"]){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            HGBLog(@"%@",error);
            return jsonString;
        }else{
            return dic;
        }
    }else if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"["]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            HGBLog(@"%@",error);
            return jsonString;
        }else{
            return array;
        }
    }else{
        return jsonString;
    }


}
/**
 json字符串处理

 @param jsonString 字符串处理
 @return 处理后字符串
 */
+(NSString *)jsonStringHandle:(NSString *)jsonString{
    NSString *string=jsonString;
    //大括号

    //中括号
    while ([string containsString:@"【"]) {
        string=[string stringByReplacingOccurrencesOfString:@"【" withString:@"]"];
    }
    while ([string containsString:@"】"]) {
        string=[string stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
    }

    //小括弧
    while ([string containsString:@"（"]) {
        string=[string stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    }

    while ([string containsString:@"）"]) {
        string=[string stringByReplacingOccurrencesOfString:@"）" withString:@")"];
    }


    while ([string containsString:@"("]) {
        string=[string stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    }

    while ([string containsString:@")"]) {
        string=[string stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    }


    //逗号
    while ([string containsString:@"，"]) {
        string=[string stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    while ([string containsString:@";"]) {
        string=[string stringByReplacingOccurrencesOfString:@";" withString:@","];
    }
    while ([string containsString:@"；"]) {
        string=[string stringByReplacingOccurrencesOfString:@"；" withString:@","];
    }
    //引号
    while ([string containsString:@"“"]) {
        string=[string stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    }
    while ([string containsString:@"”"]) {
        string=[string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    }
    while ([string containsString:@"‘"]) {
        string=[string stringByReplacingOccurrencesOfString:@"‘" withString:@"\""];
    }
    while ([string containsString:@"'"]) {
        string=[string stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    }
    //冒号
    while ([string containsString:@"："]) {
        string=[string stringByReplacingOccurrencesOfString:@"：" withString:@":"];
    }
    //等号
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    return string;

}
#pragma mark 获取当前控制器
/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBINBluetoothTool findBestViewController:viewController];
}
/**
 寻找上层控制器

 @param vc 控制器
 @return 上层控制器
 */
+ (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController) {
        // Return presented view controller
        return [HGBINBluetoothTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBINBluetoothTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBINBluetoothTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBINBluetoothTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}


@end

