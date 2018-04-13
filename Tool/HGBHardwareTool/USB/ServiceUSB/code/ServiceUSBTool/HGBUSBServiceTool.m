//
//  HGBUSBServiceTool.m
//  测试
//
//  Created by huangguangbao on 2018/4/12.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBUSBServiceTool.h"

#import "PTUSBHub.h"
#import "PTExampleProtocol.h"
#import <QuartzCore/QuartzCore.h>
#import "PTChannel.h"

static const NSTimeInterval PTAppReconnectDelay = 1.0;

#define ReslutCode @"reslutCode"
#define ReslutMessage @"reslutMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif
@interface HGBUSBServiceTool()<PTChannelDelegate>{
    // If the remote connection is over USB transport...
    NSNumber *connectingToDeviceID_;
    NSNumber *connectedDeviceID_;
    NSDictionary *connectedDeviceProperties_;
    NSDictionary *remoteDeviceInfo_;
    dispatch_queue_t notConnectedQueue_;
    BOOL notConnectedQueueSuspended_;
    PTChannel *connectedChannel_;
    NSDictionary *consoleTextAttributes_;
    NSDictionary *consoleStatusTextAttributes_;
    NSMutableDictionary *pings_;
}
@property (readonly) NSNumber *connectedDeviceID;
@property PTChannel *connectedChannel;

@end
@implementation HGBUSBServiceTool
#pragma mark init
static HGBUSBServiceTool *instance=nil;

/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBUSBServiceTool alloc]init];

    }
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        notConnectedQueue_ = dispatch_queue_create("HGBExample.notConnectedQueue", DISPATCH_QUEUE_SERIAL);
        [self startListeningForDevices];
        [self enqueueConnectToLocalIPv4Port];
        [self ping];
    }
    return self;
}

#pragma mark 消息
/**
 发送消息

 @param source 数据源
 */
- (void)sendSource:(id)source{
    if (source==nil) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeParams).stringValue,ReslutMessage:@"发送数据不能为空"}];
        }
        return;
    }
    if (!([source isKindOfClass:[NSString class]]||[source isKindOfClass:[NSArray<NSString *> class]]||[source isKindOfClass:[NSDictionary class]]||[source isKindOfClass:[NSNumber class]]||[source isKindOfClass:[NSData class]]||[source isKindOfClass:[NSImage class]])) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeParams).stringValue,ReslutMessage:@"发送格式错误"}];
        }
        return;
    }
    NSString *message=[HGBUSBServiceTool messageEncapsulation:source];
    if (connectedChannel_) {
        dispatch_data_t payload = PTExampleTextDispatchDataWithString(message);
        [connectedChannel_ sendFrameOfType:PTExampleFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
            if (error) {
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                    [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeMesssage).stringValue,ReslutMessage:@"消息发送失败"}];
                }
            }else{
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBToolDidSucessSendMessage:)]) {
                    [self.delegate USBToolDidSucessSendMessage:self];
                }
            }
        }];
    }


}
#pragma mark func
- (PTChannel*)connectedChannel {
    return connectedChannel_;
}

- (void)setConnectedChannel:(PTChannel*)connectedChannel {
    connectedChannel_ = connectedChannel;

    // Toggle the notConnectedQueue_ depending on if we are connected or not
    if (!connectedChannel_ && notConnectedQueueSuspended_) {
        dispatch_resume(notConnectedQueue_);
        notConnectedQueueSuspended_ = NO;
    } else if (connectedChannel_ && !notConnectedQueueSuspended_) {
        dispatch_suspend(notConnectedQueue_);
        notConnectedQueueSuspended_ = YES;
    }

    if (!connectedChannel_ && connectingToDeviceID_) {
        [self enqueueConnectToUSBDevice];
    }
}


#pragma mark - Ping


- (void)pongWithTag:(uint32_t)tagno error:(NSError*)error {
    NSNumber *tag = [NSNumber numberWithUnsignedInt:tagno];
    NSMutableDictionary *pingInfo = [pings_ objectForKey:tag];
    if (pingInfo) {
        NSDate *now = [NSDate date];
        [pingInfo setObject:now forKey:@"date ended"];
        [pings_ removeObjectForKey:tag];
        NSLog(@"Ping total roundtrip time: %.3f ms", [now timeIntervalSinceDate:[pingInfo objectForKey:@"date created"]]*1000.0);
    }
}


- (void)ping {
    if (connectedChannel_) {
        if (!pings_) {
            pings_ = [NSMutableDictionary dictionary];
        }
        uint32_t tagno = [connectedChannel_.protocol newTag];
        NSNumber *tag = [NSNumber numberWithUnsignedInt:tagno];
        NSMutableDictionary *pingInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"date created", nil];
        [pings_ setObject:pingInfo forKey:tag];
        [connectedChannel_ sendFrameOfType:PTExampleFrameTypePing tag:tagno withPayload:nil callback:^(NSError *error) {
            [self performSelector:@selector(ping) withObject:nil afterDelay:1.0];
            [pingInfo setObject:[NSDate date] forKey:@"date sent"];
            if (error) {
                [pings_ removeObjectForKey:tag];
            }
        }];
    } else {
        [self performSelector:@selector(ping) withObject:nil afterDelay:1.0];
    }
}


#pragma mark - PTChannelDelegate


- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (   type != PTExampleFrameTypeDeviceInfo
        && type != PTExampleFrameTypeTextMessage
        && type != PTExampleFrameTypePing
        && type != PTExampleFrameTypePong
        && type != PTFrameTypeEndOfStream) {
        NSLog(@"Unexpected frame of type %u", type);
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload {
    //NSLog(@"received %@, %u, %u, %@", channel, type, tag, payload);
    if (type == PTExampleFrameTypeDeviceInfo) {
        NSDictionary *deviceInfo = [NSDictionary dictionaryWithContentsOfDispatchData:payload.dispatchData];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didSucessReciveDeviceInfo:)]) {
            [self.delegate USBTool:self didSucessReciveDeviceInfo:deviceInfo];
        }
    } else if (type == PTExampleFrameTypeTextMessage) {
        PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.data;
        textFrame->length = ntohl(textFrame->length);
        NSString *string = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];

        id message=[HGBUSBServiceTool messageAnalysis:string];
        HGBUSBServiceToolDataType type=[HGBUSBServiceTool messageAnalysisToType:string];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didReciveMessage:andWithMessageType:)]) {
            [self.delegate USBTool:self didReciveMessage:message andWithMessageType:type];
        }
    } else if (type == PTExampleFrameTypePong) {
        [self pongWithTag:tag error:nil];
    }
}

- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (connectedDeviceID_ && [connectedDeviceID_ isEqualToNumber:channel.userInfo]) {
        [self didDisconnectFromDevice:connectedDeviceID_];
    }

    if (connectedChannel_ == channel) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didClosedWithInfo:)]) {
            [self.delegate USBTool:self didClosedWithInfo:channel.userInfo];
        }
        self.connectedChannel = nil;
    }
}


#pragma mark - Wired device connections


/**
 监听设备
 */
- (void)startListeningForDevices {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserverForName:PTUSBDeviceDidAttachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        //NSLog(@"PTUSBDeviceDidAttachNotification: %@", note.userInfo);
        HGBLog(@"PTUSBDeviceDidAttachNotification: %@", deviceID);

        dispatch_async(notConnectedQueue_, ^{
            if (!connectingToDeviceID_ || ![deviceID isEqualToNumber:connectingToDeviceID_]) {
                [self disconnectFromCurrentChannel];
                connectingToDeviceID_ = deviceID;
                connectedDeviceProperties_ = [note.userInfo objectForKey:@"Properties"];
                [self enqueueConnectToUSBDevice];
            }
        });
    }];

    [nc addObserverForName:PTUSBDeviceDidDetachNotification object:PTUSBHub.sharedHub queue:nil usingBlock:^(NSNotification *note) {
        NSNumber *deviceID = [note.userInfo objectForKey:@"DeviceID"];
        HGBLog(@"PTUSBDeviceDidDetachNotification: %@", deviceID);

        if ([connectingToDeviceID_ isEqualToNumber:deviceID]) {
            connectedDeviceProperties_ = nil;
            connectingToDeviceID_ = nil;
            if (connectedChannel_) {
                [connectedChannel_ close];
            }
        }
    }];
}


/**
 移除设备

 @param deviceID 设备id
 */
- (void)didDisconnectFromDevice:(NSNumber*)deviceID {
    NSLog(@"Disconnected from device");
    if ([connectedDeviceID_ isEqualToNumber:deviceID]) {
        [self willChangeValueForKey:@"connectedDeviceID"];
        connectedDeviceID_ = nil;
        [self didChangeValueForKey:@"connectedDeviceID"];
    }
}


/**
 移除当前设备
 */
- (void)disconnectFromCurrentChannel {
    if (connectedDeviceID_ && connectedChannel_) {
        [connectedChannel_ close];
        self.connectedChannel = nil;
    }
}


- (void)enqueueConnectToLocalIPv4Port {
    dispatch_async(notConnectedQueue_, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToLocalIPv4Port];
        });
    });
}


- (void)connectToLocalIPv4Port {
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    channel.userInfo = [NSString stringWithFormat:@"127.0.0.1:%d", PTExampleProtocolIPv4PortNumber];
    [channel connectToPort:PTExampleProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error, PTAddress *address) {
        if (error) {
            if (error.domain == NSPOSIXErrorDomain && (error.code == ECONNREFUSED || error.code == ETIMEDOUT)) {
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                    [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeConnect).stringValue,ReslutMessage:error.localizedDescription}];
                }
                // this is an expected state
            } else {
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                    [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeConnect).stringValue,ReslutMessage:error.localizedDescription}];
                }
            }
        } else {
            [self disconnectFromCurrentChannel];
            self.connectedChannel = channel;
            channel.userInfo = address;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didSucessedToConnectOnIp:andWithPort:)]) {
                [self.delegate USBTool:self didSucessedToConnectOnIp:address.name andWithPort:@(address.port).stringValue];
            }
        }
        [self performSelector:@selector(enqueueConnectToLocalIPv4Port) withObject:nil afterDelay:PTAppReconnectDelay];
    }];
}


- (void)enqueueConnectToUSBDevice {
    dispatch_async(notConnectedQueue_, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connectToUSBDevice];
        });
    });
}


- (void)connectToUSBDevice {
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    channel.userInfo = connectingToDeviceID_;
    channel.delegate = self;

    [channel connectToPort:PTExampleProtocolIPv4PortNumber overUSBHub:PTUSBHub.sharedHub deviceID:connectingToDeviceID_ callback:^(NSError *error) {
        if (error) {
            if (error.domain == PTUSBHubErrorDomain && error.code == PTUSBHubErrorConnectionRefused) {
                HGBLog(@"Failed to connect to device #%@: %@", channel.userInfo, error);
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                    [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeConnect).stringValue,ReslutMessage:error.localizedDescription}];
                }
            } else {
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                    [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBUSBServiceToolErrorTypeConnect).stringValue,ReslutMessage:error.localizedDescription}];
                }
                HGBLog(@"Failed to connect to device #%@: %@", channel.userInfo, error);
            }
            if (channel.userInfo == connectingToDeviceID_) {
                [self performSelector:@selector(enqueueConnectToUSBDevice) withObject:nil afterDelay:PTAppReconnectDelay];
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didAttachWithDeviceId:)]) {
                    [self.delegate USBTool:self didAttachWithDeviceId:connectingToDeviceID_];
                }
            }
        } else {
            connectedDeviceID_ = connectingToDeviceID_;
            self.connectedChannel = channel;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didAttachWithDeviceId:)]) {
                [self.delegate USBTool:self didAttachWithDeviceId:connectingToDeviceID_];
            }

        }
    }];
}
#pragma mark 数据格式转换
/**
 数据编码

 @param message 数据
 @return data
 */
+(NSString *)messageEncapsulation:(id)message{
    NSString *string;
    if([message isKindOfClass:[NSData class]]){
        NSData *encodeData =message;
        NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
        string=[NSString stringWithFormat:@"data://%@",base64String];
    }else if([message isKindOfClass:[NSString class]]){
        NSString *url=message;
        if([HGBUSBServiceTool isURL:url]){
            url=[HGBUSBServiceTool urlAnalysis:url];
            NSData *encodeData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
            NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
            string=[NSString stringWithFormat:@"file://{name:%@,data:%@}",[url pathExtension],base64String];
        }else{
            message=[message stringByReplacingOccurrencesOfString:@"string://" withString:@""];
            string=message;
        }
    }else if([message isKindOfClass:[NSArray class]]){
        message=[HGBUSBServiceTool ObjectToJSONString:message];
        message=[@"array://" stringByAppendingString:message];
        string=message;
    }else if([message isKindOfClass:[NSDictionary class]]){
        message=[HGBUSBServiceTool ObjectToJSONString:message];
        message=[@"dictionary://" stringByAppendingString:message];
        string=message;
    }else if([message isKindOfClass:[NSImage class]]){
        NSImage *image=message;
        NSData *encodeData= [image TIFFRepresentation];
        NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
        string=[NSString stringWithFormat:@"image://%@",base64String];
    }else if([message isKindOfClass:[NSNumber class]]){
        message=[NSString stringWithFormat:@"number://%@",message];
        string=message;
    }
    return string;
}
/**
 数据解码

 @param string 数据
 @return 解码后数据
 */
+(id)messageAnalysis:(NSString *)string{
    id message;
    HGBUSBServiceToolDataType type;
    if([string hasPrefix:@"string://"]){
        string=[string stringByReplacingOccurrencesOfString:@"string://" withString:@""];
        message=string;
        type=HGBUSBServiceToolDataTypeString;
    }else if([string hasPrefix:@"array://"]){
        string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
        message=[HGBUSBServiceTool JSONStringToObject:string];
        type=HGBUSBServiceToolDataTypeArray;
    }else if ([string hasPrefix:@"dictionary://"]){
        string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
        message=[HGBUSBServiceTool JSONStringToObject:string];
        type=HGBUSBServiceToolDataTypeDictionary;
    }else if ([string hasPrefix:@"number://"]){
        type=HGBUSBServiceToolDataTypeNumber;
        string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
        message=[[NSNumber alloc]initWithFloat:string.floatValue];
    }else if ([string hasPrefix:@"data://"]){
        type=HGBUSBServiceToolDataTypeData;
        string=[string stringByReplacingOccurrencesOfString:@"data://" withString:@""];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        message=decodedData;
    }else if ([string hasPrefix:@"file://"]){
        type=HGBUSBServiceToolDataTypeFile;
        string=[string stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSDictionary *fileInfo=[HGBUSBServiceTool JSONStringToObject:string];
        NSString *fileString=[fileInfo objectForKey:@"data"];
        NSString *fileName=[fileInfo objectForKey:@"name"];
        NSString *filePath=@"";
        if(fileName==nil||fileName.length==0){
            filePath=[NSString stringWithFormat:@"document://%@",[HGBUSBServiceTool getSecondTimeStringSince1970]];
        }else{
            filePath=[NSString stringWithFormat:@"document://%@",fileName];

            if ([HGBUSBServiceTool urlExistCheck:filePath]) {
                filePath=[NSString stringWithFormat:@"document://%@.%@",[HGBUSBServiceTool getSecondTimeStringSince1970],[fileName pathExtension]];
            }
        }
        NSString *fullPath=[HGBUSBServiceTool urlAnalysis:filePath];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fileString options:0];
        [decodedData writeToFile:fullPath atomically:YES];
        message=filePath;
    }else if ([string hasPrefix:@"image://"]){
        type=HGBUSBServiceToolDataTypeImage;
        string=[string stringByReplacingOccurrencesOfString:@"image://" withString:@""];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        NSImage *image=[[NSImage alloc]initWithDataIgnoringOrientation:decodedData];
        message=image;
    }else{
        type=HGBUSBServiceToolDataTypeString;
        message=string;
    }
    return message;

}
/**
 数据解密后类型

 @param string 数据
 @return 解码后数据
 */
+(HGBUSBServiceToolDataType )messageAnalysisToType:(NSString *)string{
    HGBUSBServiceToolDataType type;
    if([string hasPrefix:@"string://"]){
        type=HGBUSBServiceToolDataTypeString;
    }else if([string hasPrefix:@"array://"]){
        type=HGBUSBServiceToolDataTypeArray;
    }else if ([string hasPrefix:@"dictionary://"]){
        type=HGBUSBServiceToolDataTypeDictionary;
    }else if ([string hasPrefix:@"number://"]){
        type=HGBUSBServiceToolDataTypeNumber;
    }else if ([string hasPrefix:@"data://"]){
        type=HGBUSBServiceToolDataTypeData;
    }else if ([string hasPrefix:@"file://"]){
        type=HGBUSBServiceToolDataTypeFile;

    }else if ([string hasPrefix:@"image://"]){
        type=HGBUSBServiceToolDataTypeImage;
    }else{
        type=HGBUSBServiceToolDataTypeString;
    }
    return type;

}
#pragma mark file
/**
 文档是否存在

 @param filePath 文件路径
 @return 结果
 */
+(BOOL)isExitAtFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return NO;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    return isExit;
}
#pragma mark 获取时间
/**
 获取时间戳-秒级

 @return 秒级时间戳
 */
+ (NSString *)getSecondTimeStringSince1970
{
    NSDate* date = [NSDate date];
    NSTimeInterval interval=[date timeIntervalSince1970];  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%f", interval]; //转为字符型
    NSString *timeStr = [NSString stringWithFormat:@"%lf",[timeString doubleValue]*1000000];

    if(timeStr.length>=16){
        return [timeStr substringToIndex:16];
    }else{
        return timeStr;
    }
}
#pragma mark json
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
    jsonString=[HGBUSBServiceTool jsonStringHandle:jsonString];
    //    NSLog(@"%@",jsonString);
    NSError *error = nil;
    NSData  *data=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"{"]){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            NSLog(@"%@",error);
            return jsonString;
        }else{
            return dic;
        }
    }else if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"["]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            NSLog(@"%@",error);
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
#pragma mark url
/**
 判断路径是否是URL

 @param url url路径
 @return 结果
 */
+(BOOL)isURL:(NSString*)url{
    if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"/User"]||[url hasPrefix:@"/var"]||[url hasPrefix:@"http://"]||[url hasPrefix:@"https://"]||[url hasPrefix:@"file://"]){
        return YES;
    }else{
        return NO;
    }
}
/**
 url校验存在

 @param url url
 @return 是否存在
 */
+(BOOL)urlExistCheck:(NSString *)url{
    if(url==nil||url.length==0){
        return NO;
    }
    if(![HGBUSBServiceTool isURL:url]){
        return NO;
    }
    url=[HGBUSBServiceTool urlAnalysis:url];
    if(![url containsString:@"://"]){
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    if([url hasPrefix:@"file://"]){
        NSString *filePath=[[NSURL URLWithString:url]path];
        if(filePath==nil||filePath.length==0){
            return NO;
        }
        NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
        return [filemanage fileExistsAtPath:filePath];
    }else{


        return YES;

    }
}
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysisToPath:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if([HGBUSBServiceTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBUSBServiceTool urlAnalysis:url];
    return [[NSURL URLWithString:urlstr]path];
}
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysis:(NSString *)url{
    if(url==nil){
        return nil;
    }
    if([HGBUSBServiceTool isURL:url]){
        return nil;
    }
    if([url containsString:@"://"]){
        //project://工程包内
        //home://沙盒路径
        //http:// https://网络路径
        //document://沙盒Documents文件夹
        //caches://沙盒Caches
        //tmp://沙盒Tmp文件夹
        if([url hasPrefix:@"project://"]||[url hasPrefix:@"home://"]||[url hasPrefix:@"document://"]||[url hasPrefix:@"defaults://"]||[url hasPrefix:@"caches://"]||[url hasPrefix:@"tmp://"]){
            if([url hasPrefix:@"project://"]){
                url=[url stringByReplacingOccurrencesOfString:@"project://" withString:@""];
                NSString *projectPath=[[NSBundle mainBundle]resourcePath];
                url=[projectPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"home://"]){
                url=[url stringByReplacingOccurrencesOfString:@"home://" withString:@""];
                NSString *homePath=NSHomeDirectory();
                url=[homePath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"document://"]){
                url=[url stringByReplacingOccurrencesOfString:@"document://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"defaults://"]){
                url=[url stringByReplacingOccurrencesOfString:@"defaults://" withString:@""];
                NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
                url=[documentPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"caches://"]){
                url=[url stringByReplacingOccurrencesOfString:@"caches://" withString:@""];
                NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
                url=[cachesPath stringByAppendingPathComponent:url];
            }else if([url hasPrefix:@"tmp://"]){
                url=[url stringByReplacingOccurrencesOfString:@"tmp://" withString:@""];
                NSString *tmpPath =NSTemporaryDirectory();
                url=[tmpPath stringByAppendingPathComponent:url];
            }
            url=[[NSURL fileURLWithPath:url]absoluteString];

        }else{

        }
    }else {
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
/**
 url封装

 @return 封装后url
 */
+(NSString *)urlEncapsulation:(NSString *)url{
    if([HGBUSBServiceTool isURL:url]){
        return nil;
    }
    NSString *homePath=NSHomeDirectory();
    NSString  *documentPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString  *cachesPath =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
    NSString *projectPath=[[NSBundle mainBundle]resourcePath];
    NSString *tmpPath =NSTemporaryDirectory();

    if([url hasPrefix:@"file://"]){
        url=[url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    if([url hasPrefix:projectPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",projectPath] withString:@"project://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",projectPath] withString:@"project://"];
    }else if([url hasPrefix:documentPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",documentPath] withString:@"defaults://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",documentPath] withString:@"defaults://"];
    }else if([url hasPrefix:cachesPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",cachesPath] withString:@"caches://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",cachesPath] withString:@"caches://"];
    }else if([url hasPrefix:tmpPath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",tmpPath] withString:@"tmp://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",tmpPath] withString:@"tmp://"];
    }else if([url hasPrefix:homePath]){
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",homePath] withString:@"home://"];
        url=[url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",homePath] withString:@"home://"];
    }else if([url containsString:@"://"]){

    }else{
        url=[[NSURL fileURLWithPath:url]absoluteString];
    }
    return url;
}
@end
