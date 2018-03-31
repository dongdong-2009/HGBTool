//
//  JSRSA.m
//  RSA Example
//
//  Created by Js on 12/23/14.
//  Copyright (c) 2014 JS Lim. All rights reserved.
//

#include "js_rsa.h"
#import "JSRSA.h"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@implementation JSRSA

#pragma mark - helper
- (NSString *)publicKeyPath
{
    if (_publicKey == nil || [_publicKey isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[_publicKey componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
        
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    return keyPath;
}

- (NSString *)privateKeyPath
{
    if (_privateKey == nil || [_privateKey isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[_privateKey componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
        
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    return keyPath;
}

#pragma mark - implementation
- (NSString *)publicEncrypt:(NSString *)plainText
{
    NSString *keyPath = [self publicKeyPath];
    if (keyPath == nil) {
        HGBLog(@"密钥文件地址不能为空");
        return nil;

    }
    if(plainText==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
        
    char *cipherText = js_public_encrypt([plainText UTF8String], [keyPath UTF8String]);
    
    NSString *cipherTextString = [NSString stringWithUTF8String:cipherText];
    
    free(cipherText);
    
    return cipherTextString;
}

- (NSString *)privateDecrypt:(NSString *)cipherText
{
    NSString *keyPath = [self privateKeyPath];
    if (keyPath == nil) {
        HGBLog(@"密钥文件地址不能为空");
        return nil;

    }
    if(cipherText==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    
    char *plainText = js_private_decrypt([cipherText UTF8String], [keyPath UTF8String]);
    
    NSString *planTextString = [NSString stringWithUTF8String:plainText];
    
    free(plainText);
    
    return planTextString;
}

- (NSString *)privateEncrypt:(NSString *)plainText
{
    NSString *keyPath = [self privateKeyPath];
    if (keyPath == nil) {
        HGBLog(@"密钥文件地址不能为空");
        return nil;

    }
    if(plainText==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
        
    char *cipherText = js_private_encrypt([plainText UTF8String], [keyPath UTF8String]);
    
    NSString *cipherTextString = [NSString stringWithUTF8String:cipherText];
    
    free(cipherText);
    
    return cipherTextString;
}

- (NSString *)publicDecrypt:(NSString *)cipherText
{
    NSString *keyPath = [self publicKeyPath];
    if (keyPath == nil) {
        HGBLog(@"密钥文件地址不能为空");
        return nil;

    }
    if(cipherText==nil){
        HGBLog(@"字符串不能为空");
        return nil;
    }
    
    char *plainText = js_public_decrypt([cipherText UTF8String], [keyPath UTF8String]);
    
    NSString *plainTextString = [NSString stringWithUTF8String:plainText];
    
    free(plainText);
    
    return plainTextString;
}

#pragma mark - instance method
+ (JSRSA *)sharedInstance
{
    static JSRSA *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

@end
