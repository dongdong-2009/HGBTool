//
//  HGBClientUSBTool.m
//  测试
//
//  Created by huangguangbao on 2018/4/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBClientUSBTool.h"
#import "PTChannel.h"
#import "PTExampleProtocol.h"


#define ReslutCode @"reslutCode"
#define ReslutMessage @"reslutMessage"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBClientUSBTool()<PTChannelDelegate>
{
    __weak PTChannel *serverChannel_;
    __weak PTChannel *peerChannel_;
}

@end
@implementation HGBClientUSBTool
#pragma mark init
static HGBClientUSBTool *instance=nil;

/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBClientUSBTool alloc]init];
        [instance listenService];
    }
    return instance;
}
#pragma mark 功能
/**
 监听接口
 */
-(void)listenService{
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    [channel listenOnPort:PTExampleProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
        if (error) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedOnListenServiceWithError:)]) {
                [self.delegate USBTool:self didFailedOnListenServiceWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeFailed).stringValue,ReslutMessage:@"接口监听失败"}];
            }
        } else {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didSucessedListenServiceOnIp:andWithPort:)]) {
                [self.delegate USBTool:self didSucessedListenServiceOnIp:@"127.0.0.1" andWithPort:@(PTExampleProtocolIPv4PortNumber).stringValue];
            }
            serverChannel_ = channel;
        }
    }];
}
/**
 发送消息

 @param source 数据源
 */
- (void)sendSource:(id)source{
    if (source==nil) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeParams).stringValue,ReslutMessage:@"发送数据不能为空"}];
        }
        return;
    }
    if (!([source isKindOfClass:[NSString class]]||[source isKindOfClass:[NSArray<NSString *> class]]||[source isKindOfClass:[NSDictionary class]]||[source isKindOfClass:[NSNumber class]]||[source isKindOfClass:[NSData class]]||[source isKindOfClass:[UIImage class]])) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeParams).stringValue,ReslutMessage:@"发送格式错误"}];
        }
        return;
    }
    NSString *message=[HGBClientUSBTool messageEncapsulation:source];
    if (peerChannel_) {
        dispatch_data_t payload = PTExampleTextDispatchDataWithString(message);
        [peerChannel_ sendFrameOfType:PTExampleFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
            if (error) {
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                    [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeMesssage).stringValue,ReslutMessage:@"消息发送失败"}];
                }
            }else{
                if (self.delegate&&[self.delegate respondsToSelector:@selector(USBToolDidSucessSendMessage:)]) {
                    [self.delegate USBToolDidSucessSendMessage:self];
                }
            }
        }];

    } else {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeConnect).stringValue,ReslutMessage:@"设备链接失效"}];
        }
    }
}

#pragma mark - Communicating

- (void)sendDeviceInfo {
    if (!peerChannel_) {
        return;
    }


    UIScreen *screen = [UIScreen mainScreen];
    CGSize screenSize = screen.bounds.size;
    NSDictionary *screenSizeDict = (__bridge_transfer NSDictionary*)CGSizeCreateDictionaryRepresentation(screenSize);
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          device.localizedModel, @"localizedModel",
                          [NSNumber numberWithBool:device.multitaskingSupported], @"multitaskingSupported",
                          device.name, @"name",
                          (UIDeviceOrientationIsLandscape(device.orientation) ? @"landscape" : @"portrait"), @"orientation",
                          device.systemName, @"systemName",
                          device.systemVersion, @"systemVersion",
                          screenSizeDict, @"screenSize",
                          [NSNumber numberWithDouble:screen.scale], @"screenScale",
                          nil];
    dispatch_data_t payload = [info createReferencingDispatchData];
    [peerChannel_ sendFrameOfType:PTExampleFrameTypeDeviceInfo tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
        if (error) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
                [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeFailed).stringValue,ReslutMessage:@"设备信息发送失败"}];



            }
            HGBLog(@"Failed to send PTExampleFrameTypeDeviceInfo: %@", error);
        }else{
            if (self.delegate&&[self.delegate respondsToSelector:@selector(USBToolDidSucessSendDeviceInfo:)]) {
                [self.delegate USBToolDidSucessSendDeviceInfo:self];
            }
        }
    }];
}
#pragma mark - PTChannelDelegate
// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (channel != peerChannel_) {
        // A previous channel that has been canceled but not yet ended. Ignore.
        return NO;
    } else if (type != PTExampleFrameTypeTextMessage && type != PTExampleFrameTypePing) {
        HGBLog(@"Unexpected frame of type %u", type);
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeFailed).stringValue,ReslutMessage:@"信息类型不支持"}];
        }
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload {
    //HGBLog(@"didReceiveFrameOfType: %u, %u, %@", type, tag, payload);
    if (type == PTExampleFrameTypeTextMessage) {
        PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.data;
        textFrame->length = ntohl(textFrame->length);
        NSString *string = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
        id message=[HGBClientUSBTool messageAnalysis:string];
        HGBClientUSBToolDataType type=[HGBClientUSBTool messageAnalysisToType:string];
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didReciveMessage:andWithMessageType:)]) {
            [self.delegate USBTool:self didReciveMessage:message andWithMessageType:type];
        }
    } else if (type == PTExampleFrameTypePing && peerChannel_) {
        [peerChannel_ sendFrameOfType:PTExampleFrameTypePong tag:tag withPayload:nil callback:nil];
    }
}

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (error) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didFailedWithError:)]) {
            [self.delegate USBTool:self didFailedWithError:@{ReslutCode:@(HGBClientUSBToolErrorTypeFailed).stringValue,ReslutMessage:error.localizedDescription}];
        }
    } else {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didClosedWithInfo:)]) {
            [self.delegate USBTool:self didClosedWithInfo:channel.userInfo];
        }
    }
}

// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address {
    // Cancel any other connection. We are FIFO, so the last connection
    // established will cancel any previous connection and "take its place".
    if (peerChannel_) {
        [peerChannel_ cancel];
    }

    // Weak pointer to current connection. Connection objects live by themselves
    // (owned by its parent dispatch queue) until they are closed.
    peerChannel_ = otherChannel;
    peerChannel_.userInfo = address;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(USBTool:didSucessedListenServiceOnIp:andWithPort:)]) {
        [self.delegate USBTool:self didSucessedListenServiceOnIp:address.name andWithPort:@(address.port).stringValue];
    }

    // Send some information about ourselves to the other end
    [self sendDeviceInfo];
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
        if([HGBClientUSBTool isURL:url]){
            url=[HGBClientUSBTool urlAnalysis:url];
            NSData *encodeData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
            NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
            string=[NSString stringWithFormat:@"file://{name:%@,data:%@}",[url pathExtension],base64String];
        }else{
            message=[message stringByReplacingOccurrencesOfString:@"string://" withString:@""];
            string=message;
        }
    }else if([message isKindOfClass:[NSArray class]]){
        message=[HGBClientUSBTool ObjectToJSONString:message];
        message=[@"array://" stringByAppendingString:message];
        string=message;
    }else if([message isKindOfClass:[NSDictionary class]]){
        message=[HGBClientUSBTool ObjectToJSONString:message];
        message=[@"dictionary://" stringByAppendingString:message];
        string=message;
    }else if([message isKindOfClass:[UIImage class]]){
        NSData *encodeData=UIImagePNGRepresentation(message);
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
    HGBClientUSBToolDataType type;
    if([string hasPrefix:@"string://"]){
        string=[string stringByReplacingOccurrencesOfString:@"string://" withString:@""];
        message=string;
        type=HGBClientUSBToolDataTypeString;
    }else if([string hasPrefix:@"array://"]){
        string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
        message=[HGBClientUSBTool JSONStringToObject:string];
        type=HGBClientUSBToolDataTypeArray;
    }else if ([string hasPrefix:@"dictionary://"]){
        string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
        message=[HGBClientUSBTool JSONStringToObject:string];
        type=HGBClientUSBToolDataTypeDictionary;
    }else if ([string hasPrefix:@"number://"]){
        type=HGBClientUSBToolDataTypeNumber;
        string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
        message=[[NSNumber alloc]initWithFloat:string.floatValue];
    }else if ([string hasPrefix:@"data://"]){
        type=HGBClientUSBToolDataTypeData;
        string=[string stringByReplacingOccurrencesOfString:@"data://" withString:@""];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        message=decodedData;
    }else if ([string hasPrefix:@"file://"]){
        type=HGBClientUSBToolDataTypeFile;
        string=[string stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        NSDictionary *fileInfo=[HGBClientUSBTool JSONStringToObject:string];
        NSString *fileString=[fileInfo objectForKey:@"data"];
        NSString *fileName=[fileInfo objectForKey:@"name"];
        NSString *filePath=@"";
        if(fileName==nil||fileName.length==0){
            filePath=[NSString stringWithFormat:@"document://%@",[HGBClientUSBTool getSecondTimeStringSince1970]];
        }else{
            filePath=[NSString stringWithFormat:@"document://%@",fileName];

            if ([HGBClientUSBTool urlExistCheck:filePath]) {
                filePath=[NSString stringWithFormat:@"document://%@.%@",[HGBClientUSBTool getSecondTimeStringSince1970],[fileName pathExtension]];
            }
        }
        NSString *fullPath=[HGBClientUSBTool urlAnalysis:filePath];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fileString options:0];
        [decodedData writeToFile:fullPath atomically:YES];
        message=filePath;
    }else if ([string hasPrefix:@"image://"]){
        type=HGBClientUSBToolDataTypeImage;
        string=[string stringByReplacingOccurrencesOfString:@"image://" withString:@""];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        UIImage *image=[UIImage imageWithData:decodedData];
        message=image;
    }else{
        type=HGBClientUSBToolDataTypeString;
        message=string;
    }
    return message;

}
/**
 数据解密后类型

 @param string 数据
 @return 解码后数据
 */
+(HGBClientUSBToolDataType )messageAnalysisToType:(NSString *)string{
    HGBClientUSBToolDataType type;
    if([string hasPrefix:@"string://"]){
        type=HGBClientUSBToolDataTypeString;
    }else if([string hasPrefix:@"array://"]){
        type=HGBClientUSBToolDataTypeArray;
    }else if ([string hasPrefix:@"dictionary://"]){
        type=HGBClientUSBToolDataTypeDictionary;
    }else if ([string hasPrefix:@"number://"]){
        type=HGBClientUSBToolDataTypeNumber;
    }else if ([string hasPrefix:@"data://"]){
        type=HGBClientUSBToolDataTypeData;
    }else if ([string hasPrefix:@"file://"]){
        type=HGBClientUSBToolDataTypeFile;

    }else if ([string hasPrefix:@"image://"]){
        type=HGBClientUSBToolDataTypeImage;
    }else{
        type=HGBClientUSBToolDataTypeString;
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
    jsonString=[HGBClientUSBTool jsonStringHandle:jsonString];
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
    if([HGBClientUSBTool isURL:url]){
        return NO;
    }
    url=[HGBClientUSBTool urlAnalysis:url];
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
        NSURL *urlCheck=[NSURL URLWithString:url];

        return [[UIApplication sharedApplication]canOpenURL:urlCheck];

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
    if([HGBClientUSBTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBClientUSBTool urlAnalysis:url];
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
    if([HGBClientUSBTool isURL:url]){
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
    if([HGBClientUSBTool isURL:url]){
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

