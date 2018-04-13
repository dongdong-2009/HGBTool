//
//  HGBCompressedFileTool.m
//  HelloCordova
//
//  Created by huangguangbao on 2017/7/11.
//
//

#import "HGBCompressedFileTool.h"
#import <UIKit/UIKit.h>
#import "LZMAExtractor.h"
#import "SARUnArchiveANY.h"
#import "SSZipArchive.h"
#import "ZipArchive.h"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"


@interface HGBCompressedFileTool()
@end
@implementation HGBCompressedFileTool
/**
 解压
 @param source 文件路径或快捷url
 @param password 密码
 @param destination 目标地址或快捷url
 @param completeBlock 结果
 */
+(void)unArchive: (NSString *)source andPassword:(NSString*)password toDestination:(NSString *)destination andWithCompleteBlock:(HGBCompressedCompleteBlock)completeBlock{

    if(source==nil||source.length==0){

        HGBLog(@"文件路径不能为空");
        if(completeBlock){
            completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeSrcPath).stringValue,ReslutMessage:@"文件路径不能为空"});
        }
        return;
    }
    NSString *url=[HGBCompressedFileTool urlAnalysis:source];
    NSString * filePath=[[NSURL URLWithString:url]path];
    if(![HGBCompressedFileTool isExitAtFilePath:filePath]){
       HGBLog(@"文件路径不存在");
        if(completeBlock){
             completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeSrcPath).stringValue,ReslutMessage:@"文件路径不存在"});
        }
        return;


    }


    url=[HGBCompressedFileTool urlAnalysis:destination];
    NSString* destPath=[[NSURL URLWithString:url]path];

    if(destPath&&[[destPath lastPathComponent] pathExtension].length!=0){
        destPath=[destPath stringByReplacingOccurrencesOfString:[[destPath lastPathComponent] pathExtension] withString:@""];

    }
    if([HGBCompressedFileTool isExitAtFilePath:destPath]){
       HGBLog(@"目标文件已存在");
        if(completeBlock){
            completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeDestinationPath).stringValue,ReslutMessage:@"目标文件已存在"});
        }
        return;
    }

    if(![HGBCompressedFileTool isExitAtFilePath:destPath]){
        [HGBCompressedFileTool createDirectoryPath:destPath];
    }
    

    HGBLog( @"can't find filePath");
    SARUnArchiveANY *unarchive = [[SARUnArchiveANY alloc]initWithPath:filePath];
    if (password != nil && password.length > 0) {
        unarchive.password = password;
    }

    if (destPath != nil)
        unarchive.destinationPath = destPath;
    unarchive.completionBlock = ^(NSArray *filePaths){
        HGBLog(@"For Archive : %@",filePath);

        for (NSString *filename in filePaths) {
            HGBLog(@"File: %@", filename);
        }
        if(completeBlock){
            completeBlock(YES,@{ReslutCode:@(HGBCompressedFileToolReslutSucess).stringValue,ReslutMessage:@"sucess"});
        }
    };
    unarchive.failureBlock = ^(){
        HGBLog(@"Cannot be unarchived");
        if(completeBlock){
             completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeCompress).stringValue,ReslutMessage:@"解压失败"});
        }

    };
    [unarchive decompress];
}
#pragma mark 压缩
/**
 压缩
 @param source 文件路径或快捷url集合
 @param destination 目标地址或快捷url
 @param completeBlock 结果
 */
+(void)archiveToZipWithSource: (NSArray *)source toDestination:(NSString *)destination andWithCompleteBlock:(HGBCompressedCompleteBlock)completeBlock{
    NSMutableArray *files=[NSMutableArray array];
    for(NSString *filePath in source){
        NSString *url=[HGBCompressedFileTool urlAnalysis:filePath];
         NSString *path=[[NSURL URLWithString:url]path];

        if(![HGBCompressedFileTool isExitAtFilePath:path]){
            HGBLog(@"路径错误");
            if(completeBlock){
                 completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeSrcPath).stringValue,ReslutMessage:@"路径错误"});
            }
            return;


        }
        [files addObject:path];

    }
    NSString *url=[HGBCompressedFileTool urlAnalysis:destination];
    NSString* destPath=[[NSURL URLWithString:url]path];

    if(destPath&&[[destPath lastPathComponent] pathExtension].length!=0){
        destPath=[destPath stringByReplacingOccurrencesOfString:[[destPath lastPathComponent] pathExtension] withString:@"zip"];

    }else{
        destPath=[destPath stringByAppendingString:@"/归档.zip"];
    }
    if([HGBCompressedFileTool isExitAtFilePath:destPath]){


       HGBLog(@"目标文件已存在");
        if(completeBlock){
            completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeDestinationPath).stringValue,ReslutMessage:@"目标文件已存在"});
        }

        return;
    }

    NSString *basePath=[destPath stringByDeletingLastPathComponent];
    if(![HGBCompressedFileTool isExitAtFilePath:basePath]){
        [HGBCompressedFileTool createDirectoryPath:basePath];
    }

    NSString *baseCopyPath=[[HGBCompressedFileTool getTmpFilePath] stringByAppendingPathComponent:[[destPath lastPathComponent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",[[destPath lastPathComponent] pathExtension]] withString:@""]];

    if([HGBCompressedFileTool isExitAtFilePath:baseCopyPath]){
        [HGBCompressedFileTool removeFilePath:baseCopyPath];
    }

    for(NSString *filePath in files){
        [HGBCompressedFileTool copyFilePath:filePath ToPath:[baseCopyPath stringByAppendingPathComponent:[filePath lastPathComponent]]];
    }



    BOOL flag=[self doZipAtDirectoryPath:baseCopyPath to:destPath];
    if(flag){
//        HGBLog(@"成功");
        if(completeBlock){
             completeBlock(YES,@{ReslutCode:@(HGBCompressedFileToolReslutSucess).stringValue,ReslutMessage:@"成功"});
        }
    }else{
       HGBLog(@"压缩失败");
        if(completeBlock){
             completeBlock(NO,@{ReslutCode:@(HGBCompressedFileToolErrorTypeCompress).stringValue,ReslutMessage:@"压缩失败"});
        }
    }
    [HGBCompressedFileTool removeFilePath:baseCopyPath];
}

/**
 压缩文件

 @param sourceDirectoryPath 源文件夹
 @param destZipFile 目标文件
 @return 结果
 */
+(BOOL)doZipAtDirectoryPath:(NSString*)sourceDirectoryPath to:(NSString*)destZipFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZipArchive * zipArchive = [ZipArchive new];
    [zipArchive CreateZipFile2:destZipFile];
    NSArray *subPaths = [fileManager subpathsAtPath:sourceDirectoryPath];// 关键是subpathsAtPath方法
    for(NSString *subPath in subPaths){
        NSString *fullPath = [sourceDirectoryPath stringByAppendingPathComponent:subPath];
        BOOL isDir;
        if([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir)// 只处理文件
        {
            [zipArchive addFileToZip:fullPath newname:subPath];
        }
    }
    [zipArchive CloseZipFile2];
    return YES;
}
#pragma mark 文件
/**
 文档是否存在

 @param filePath 归档的路径
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
/**
 删除文档

 @param filePath 归档的路径
 @return 结果
 */
+ (BOOL)removeFilePath:(NSString *)filePath{
    if(filePath==nil||filePath.length==0){
        return YES;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL isExit=[filemanage fileExistsAtPath:filePath];
    BOOL deleteFlag=NO;
    if(isExit){
        deleteFlag=[filemanage removeItemAtPath:filePath error:nil];
    }else{
        deleteFlag=NO;
    }
    return deleteFlag;
}
/**
 文件拷贝

 @param srcPath 文件路径
 @param filePath 复制文件路径
 @return 结果
 */
+(BOOL)copyFilePath:(NSString *)srcPath ToPath:(NSString *)filePath{
    if(![HGBCompressedFileTool isExitAtFilePath:srcPath]){
        return NO;
    }
    NSString *directoryPath=[filePath stringByDeletingLastPathComponent];
    if(![HGBCompressedFileTool isExitAtFilePath:directoryPath]){
        [HGBCompressedFileTool createDirectoryPath:directoryPath];
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];//创建对象
    BOOL flag=[filemanage copyItemAtPath:srcPath toPath:filePath error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}
#pragma mark 文件夹
/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBCompressedFileTool isExitAtFilePath:directoryPath]){
        return YES;
    }
    NSFileManager *filemanage=[NSFileManager defaultManager];
    BOOL flag=[filemanage createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    if(flag){
        return YES;
    }else{
        return NO;
    }
}


/**
 获取沙盒tmp路径
 
 @return tmp路径
 */
+(NSString *)getTmpFilePath{
    NSString *tmpPath=NSTemporaryDirectory();
    return tmpPath;
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
    if(![HGBCompressedFileTool isURL:url]){
        return NO;
    }
     url=[HGBCompressedFileTool urlAnalysis:url];
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
    if(![HGBCompressedFileTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBCompressedFileTool urlAnalysis:url];
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
    if(![HGBCompressedFileTool isURL:url]){
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
    if(![HGBCompressedFileTool isURL:url]){
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
