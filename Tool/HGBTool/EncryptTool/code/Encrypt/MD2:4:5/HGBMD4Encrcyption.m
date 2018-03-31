//
//  HGBMD4Encrcyption.m
//  测试
//
//  Created by huangguangbao on 2017/9/14.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBMD4Encrcyption.h"
#import <CommonCrypto/CommonDigest.h>

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation HGBMD4Encrcyption
#pragma mark 特殊
/**
 *  MD4加密, 32位 小写
 *
 *  @param string 传入要加密的字符串
 *
 *  @return 返回加密后的字符串
 */
+(NSString *)MD4ForLower32Bate:(NSString *)string{
    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }

    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD4_DIGEST_LENGTH];
    CC_MD4(input, (CC_LONG)strlen(input), result);

    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD4_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD4_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }

    return digest;
}


/**
 *  MD4加密, 32位 大写
 *
 *  @param string 传入要加密的字符串
 *
 *  @return 返回加密后的字符串
 */
+(NSString *)MD4ForUpper32Bate:(NSString *)string{

    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD4_DIGEST_LENGTH];
    CC_MD4(input, (CC_LONG)strlen(input), result);

    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD4_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD4_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }

    return digest;
}

/**
 *  MD4加密, 16位 小写
 *
 *  @param string 传入要加密的字符串
 *
 *  @return 返回加密后的字符串
 */
+(NSString *)MD4ForUpper16Bate:(NSString *)string{

    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }

    NSString *md5Str = [HGBMD4Encrcyption MD4ForUpper32Bate:string];

    NSString  *string2;
    for (int i=0; i<24; i++) {
        string2=[md5Str substringWithRange:NSMakeRange(0, 16)];
    }
    return string2;
}


/**
 *  MD4加密, 16位 大写
 *
 *  @param string 传入要加密的字符串
 *
 *  @return 返回加密后的字符串
 */
+(NSString *)MD4ForLower16Bate:(NSString *)string{

    if(string==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    NSString *md5Str = [HGBMD4Encrcyption MD4ForLower32Bate:string];

    NSString  *string2;
    for (int i=0; i<24; i++) {
        string2=[md5Str substringWithRange:NSMakeRange(0, 16)];
    }
    return string2;
}
#pragma mark 通用
/**
 *  MD4加密, 小写
 *
 *  @param string 传入要加密的字符串
 *  @param bate 位数
 *
 *  @return 返回加密后的字符串
 */
+(NSString *)MD4ForLower:(NSString *)string andWithBate:(NSInteger)bate{
    NSInteger bates=bate/2+bate%2;
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[bates];
    CC_MD4(input, (CC_LONG)strlen(input), result);

    NSMutableString *digest = [NSMutableString stringWithCapacity:bate];
    for (NSInteger i = 0; i < bates; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }

    return digest;
}

/**
 *  MD4加密,  大写
 *
 *  @param string 传入要加密的字符串
 *  @param bate 位数
 *
 *  @return 返回加密后的字符串
 */
+(NSString *)MD4ForUpper:(NSString *)string andWithBate:(NSInteger)bate{
    NSInteger bates=bate/2+bate%2;
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[bates];
    CC_MD4(input, (CC_LONG)strlen(input), result);

    NSMutableString *digest = [NSMutableString stringWithCapacity:bate];
    for (NSInteger i = 0; i < bates; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}
@end
