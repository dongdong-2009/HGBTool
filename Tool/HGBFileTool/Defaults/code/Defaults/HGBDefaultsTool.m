//
//  HGBDefaultsTool.m
//  测试
//
//  Created by huangguangbao on 2017/9/15.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBDefaultsTool.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBDefaultsTool
#pragma mark defaults保存

/**
 *  Defaults保存
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @return 保存结果
 */
+(BOOL)saveDefaultsValue:(id)value WithKey:(NSString *)key{
    if((!value)||(!key)||key.length==0){
        HGBLog(@"参数不能为空");
        return NO;
    }
    if(!([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSArray class]]||[value isKindOfClass:[NSDictionary class]]||[value isKindOfClass:[NSData class]])){
        HGBLog(@"参数格式不对");
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
    return YES;
}
/**
 *  Defaults取出
 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
+(id)getDefaultsWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        HGBLog(@"参数不能为空");
        return nil;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id  value=[defaults valueForKey:key];
    [defaults synchronize];
    return value;
}
/**
 *  Defaults删除 *
 *  @param key     关键字
 *  return  返回已保存的数据
 */
+(BOOL)deleteDefaultsWithKey:(NSString *)key{
    if(key==nil||key.length==0){
        HGBLog(@"参数不能为空");
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
    return YES;
}
#pragma mark defaults加密版

/**
 *  Defaults保存加密版
 *
 *  @param value   要保存的数据
 *  @param key   关键字
 *  @param encryptKey    密钥
 *  @return 保存结果
 */
+(BOOL)saveDefaultsValue:(id)value WithKey:(NSString *)key andWithEncryptKey:(NSString *)encryptKey{
    NSString *string;
    if((!value)||(!key)||key.length==0){
        HGBLog(@"参数不能为空");
        return NO;
    }
    if(!([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSArray class]]||[value isKindOfClass:[NSDictionary class]]||[value isKindOfClass:[NSData class]])){
        HGBLog(@"参数格式不对");
        return NO;
    }else{
        string=[HGBDefaultsTool objectEncapsulation:value];
    }
    if(encryptKey==nil||encryptKey.length==0){
        encryptKey=key;
    }
    string=[HGBDefaultsTool AES256EncryptString:string WithKey:encryptKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:string forKey:key];
    [defaults synchronize];
    return YES;
}
/**
 *  Defaults取出加密版
 *
 *  @param key     关键字
 *  @param encryptKey    密钥
 *  return  返回已保存的数据
 */
+(id)getDefaultsWithKey:(NSString *)key andWithEncryptKey:(NSString *)encryptKey{
    if(key==nil||key.length==0){
        HGBLog(@"参数不能为空");
        return nil;
    }
    if(encryptKey==nil||encryptKey.length==0){
        encryptKey=key;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString  *string=[defaults valueForKey:key];

    if(string){
        string=[HGBDefaultsTool AES256DecryptString:string WithKey:encryptKey];
    }
    id value=[HGBDefaultsTool stringAnalysis:string];
    [defaults synchronize];
    return value;
}

#pragma mark object-string
/**
 object编码

 @param object 对象
 @return 编码字符串
 */
+(NSString *)objectEncapsulation:(id)object{
    NSString *string;
    if([object isKindOfClass:[NSString class]]){
        string=[NSString stringWithFormat:@"string://%@",object];
    }else if([object isKindOfClass:[NSArray class]]){
        object=[HGBDefaultsTool ObjectToJSONString:object];
        string=[@"array://" stringByAppendingString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        object=[HGBDefaultsTool ObjectToJSONString:object];
        string=[@"dictionary://" stringByAppendingString:object];
    }else if([object isKindOfClass:[NSNumber class]]){
        string=[NSString stringWithFormat:@"number://%@",object];
    }else if([object isKindOfClass:[NSData class]]){
        NSData *encodeData =object;
        NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
        string=[NSString stringWithFormat:@"data://%@",base64String];
    }else{
        string=object;
    }




    return string;
}
/**
 字符串解码

 @param string 字符串
 @return 对象
 */
+(id)stringAnalysis:(NSString *)string{
    id object;
    if([string hasPrefix:@"string://"]){
        string=[string stringByReplacingOccurrencesOfString:@"string://" withString:@""];
        object=string;
    }else if([string hasPrefix:@"array://"]){
        string=[string stringByReplacingOccurrencesOfString:@"array://" withString:@""];
        object=[HGBDefaultsTool JSONStringToObject:string];
    }else if ([string hasPrefix:@"dictionary://"]){
        string=[string stringByReplacingOccurrencesOfString:@"dictionary://" withString:@""];
        object=[HGBDefaultsTool JSONStringToObject:string];
    }else if ([string hasPrefix:@"number://"]){
        string=[string stringByReplacingOccurrencesOfString:@"number://" withString:@""];
        object=[[NSNumber alloc]initWithFloat:string.floatValue];
    }else if ([string hasPrefix:@"number://"]){
        string=[string stringByReplacingOccurrencesOfString:@"data://" withString:@""];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        object=decodedData;
    }else{
        object=string;
    }
    return object;

}

#pragma mark 加密
/**
 *  @brief  AES256加密
 *
 *  @param string    明文
 *  @param keyString 32位的密钥
 *
 *  @return 返回加密后的密文
 */
+ (NSString *)AES256EncryptString:(NSString *)string  WithKey:(NSString *)keyString
{

    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [keyString getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSData *sourceData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [sourceData length];
    size_t buffersize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(buffersize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [sourceData bytes], dataLength, buffer, buffersize, &numBytesEncrypted);

    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        //对加密后的二进制数据进行base64转码
        return [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    else
    {
        free(buffer);
        return nil;
    }

}
/**
 *  @brief  AES256解密
 *
 *  @param string    密文
 *  @param keyString 32位的密钥
 *
 *  @return 返回解密后的明文
 */
+ (NSString *)AES256DecryptString:(NSString *) string WithKey:(NSString *)keyString
{
    //先对加密的字符串进行base64解码
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];

    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [keyString getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [decodeData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return result;
    }
    else
    {
        free(buffer);
        return nil;
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
    jsonString=[HGBDefaultsTool jsonStringHandle:jsonString];
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
@end
