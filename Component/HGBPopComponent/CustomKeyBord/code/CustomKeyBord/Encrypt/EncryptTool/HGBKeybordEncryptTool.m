
//
//  HGBKeybordEncryptTool.m
//  HelloCordova
//
//  Created by huangguangbao on 2017/8/9.
//
//

#import "HGBKeybordEncryptTool.h"

#import "HGBKeybordBase64.h"

#import "HGBKeyboardDESUtil.h"
#import "NSString+HGBKeybordAES256Encrytion.h"
#import "HGBKeybordMD5.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CommonCrypto/CommonDigest.h>
#import "HGBKeybordTTAlgorithmSM4.h"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBKeybordEncryptTool

#pragma mark DES
/**
 DES加密

 @param string 字符串
 @param key  加密密钥
 @return 加密后字符串
 */
+(NSString *)encryptStringWithDES:(NSString *)string andWithKey:(NSString *)key{

    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    if(key==nil||key.length==0){
        HGBLog(@"密钥不能为空");
        return nil;
    }
    NSString *encryptString= [HGBKeyboardDESUtil encrypt:string WithKey:key];
    return encryptString;
}
/**
 DES解密

 @param string 字符串
 @param key  解密密钥
 @return 解密后字符串
 */
+(NSString *)decryptStringWithDES:(NSString *)string andWithKey:(NSString *)key{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    if(key==nil||key.length==0){
        HGBLog(@"密钥不能为空");
        return nil;
    }
    NSString *decryptString= [HGBKeyboardDESUtil decrypt:string WithKey:key];
    return decryptString;
}
#pragma mark AES256-string
/**
 AES256加密

 @param string 字符串
 @param key  加密密钥
 @return 加密后字符串
 */
+(NSString *)encryptStringWithAES256:(NSString *)string andWithKey:(NSString *)key{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    if(key==nil||key.length==0){
        HGBLog(@"密钥不能为空");
        return nil;
    }
    NSString *encryptString= [NSString AES256Encrypt:string WithKey:key];
    return encryptString;
}
/**
 AES256解密

 @param string 字符串
 @param key  解密密钥
 @return 解密后字符串
 */
+(NSString *)decryptStringWithAES256:(NSString *)string
                          andWithKey:(NSString *)key{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    if(key==nil||key.length==0){
        HGBLog(@"密钥不能为空");
        return nil;
    }
    NSString *decryptString= [NSString AES256DecryptString:string WithKey:key];
    return decryptString;
}


#pragma mark SM4国密算法-ECB
/**
 *  TTAlgorithmSM4-ECB加密
 *
 *  @param key   要存的对象的key值-16位
 *  @param string 要保存的value值
 *  @return 获取的对象
 */
+ (NSString *)encryptStringWithTTAlgorithmSM4_ECB:(NSString *)string andWithKey:(NSString *)key{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    if(key==nil||key.length==0){
        HGBLog(@"密钥不能为空");
        return nil;
    }

    NSData *encryptData=[string dataUsingEncoding:NSUTF8StringEncoding];
    string=[[NSString alloc]initWithData:encryptData encoding:NSUTF8StringEncoding];

    HGBKeybordTTAlgorithmSM4 *sm4 = [HGBKeybordTTAlgorithmSM4 ecbSM4WithKey:key];
    NSString *encryptionString = [sm4 encryption:string];
    return encryptionString;
}
/**
 *  TTAlgorithmSM4-ECB解密
 *
 *  @param key 对象的key值-16位
 *  @param string 初始化向量
 *  @return 获取的对象
 */

+(NSString *)decryptStringWithTTAlgorithmSM4_ECB:(NSString *)string andWithKey:(NSString *)key{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    if(key==nil||key.length==0){
        HGBLog(@"密钥不能为空");
        return nil;
    }
    HGBKeybordTTAlgorithmSM4
    *sm4 = [HGBKeybordTTAlgorithmSM4 ecbSM4WithKey:key];
    NSString *decryptionString = [sm4 decryption:string];
    return decryptionString;
}

#pragma mark 删除两端空格
+(NSString *)trim:(NSString *)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
