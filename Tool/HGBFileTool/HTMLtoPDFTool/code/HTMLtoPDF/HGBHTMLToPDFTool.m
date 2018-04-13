
//
//  HGBHTMLToPDFTool.m
//  测试
//
//  Created by huangguangbao on 2017/8/28.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBHTMLToPDFTool.h"

#define kWidth [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height

//屏幕比例
#define wScale kWidth / 750.0
#define hScale kHeight / 1334.0

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]//系统版本号
#define VERSION 8.0//界限版本号

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

@interface HGBHTMLToPDFTool()

@end
@implementation HGBHTMLToPDFTool
static HGBHTMLToPDFTool *instance=nil;
#pragma mark init
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBHTMLToPDFTool alloc]init];
    }
    return instance;
}

#pragma mark 功能
/**
 通过HTML字符串创建PDF

 @param HTMLString HTML字符串
 @param PDFpath pdf路径
 @param compeleteBlock 完成回调

 */
- (void)createPDFWithHTMLSting:(NSString*)HTMLString pathForPDF:(NSString*)PDFpath compeleteBlock:(HGBHTMLtoPDFToolCompletionBlock)compeleteBlock{
    NSString *dirPath=[PDFpath stringByDeletingLastPathComponent];
    if(![HGBHTMLToPDFTool isExitAtFilePath:dirPath]){
        [HGBHTMLToPDFTool createDirectoryPath:dirPath];
    }
    [HGBHTMLtoPDF createPDFWithHTML:HTMLString pathForPDF:PDFpath pageSize:basePageSize margins:UIEdgeInsetsMake(5, 5, 5, 5) successBlock:^(HGBHTMLtoPDF *htmlToPDF) {
        if(compeleteBlock){
            compeleteBlock(YES,@{});
        }
    } errorBlock:^(HGBHTMLtoPDF *htmlToPDF) {
        HGBLog(@"转换失败");
        if(compeleteBlock){
            compeleteBlock(NO,@{ReslutCode:@(HGBHGBHTMLtoPDFToolReslutErrorTypeCreate).stringValue,ReslutMessage:@"转换失败"});
        }

    }];
}


/**
 通过HTML文件创建PDF

 @param HTMLFileSource HTML文件路径或url
 @param destination pdf路径或url
 @param compeleteBlock 完成回调

 */
- (void)createPDFWithHTMLFile:(NSString*)HTMLFileSource toPDFFileDestination:(NSString*)destination compeleteBlock:(HGBHTMLtoPDFToolCompletionBlock)compeleteBlock{
    if(HTMLFileSource==nil||HTMLFileSource.length==0){

        HGBLog(@"html文件路径不能为空");
        if(compeleteBlock){
            compeleteBlock(NO,@{ReslutCode:@(HGBHGBHTMLtoPDFToolReslutErrorTypeHTMLPath).stringValue,ReslutMessage:@"html文件路径不能为空"});
        }
        return;
    }
    if(destination==nil||destination.length==0){
       HGBLog(@"pdf文件路径不能为空");
        if(compeleteBlock){
            compeleteBlock(NO,@{ReslutCode:@(HGBHGBHTMLtoPDFToolReslutErrorTypePDFPath).stringValue,ReslutMessage:@"pdf文件路径不能为空"});
        }
        return;
    }
    HTMLFileSource=[HGBHTMLToPDFTool urlAnalysis:HTMLFileSource];
    destination=[HGBHTMLToPDFTool urlAnalysis:destination];

    if(![HGBHTMLToPDFTool urlExistCheck:HTMLFileSource]){
       HGBLog(@"html文件路不存在");
        if(compeleteBlock){
            compeleteBlock(NO,@{ReslutCode:@(HGBHGBHTMLtoPDFToolReslutErrorTypeHTMLPath).stringValue,ReslutMessage:@"html文件路不存在"});
        }
        return;
    }
    if([HGBHTMLToPDFTool urlExistCheck:destination]){
        HGBLog(@"pdf文件路已存在");
        if(compeleteBlock){
            compeleteBlock(NO,@{ReslutCode:@(HGBHGBHTMLtoPDFToolReslutErrorTypeHTMLPath).stringValue,ReslutMessage:@"pdf文件路已存在"});
        }
        return;
    }
     destination=[[NSURL URLWithString:destination]path];

    NSString *htmlString=[[NSString alloc]initWithContentsOfURL:[NSURL URLWithString:HTMLFileSource] encoding:NSUTF8StringEncoding error:nil];
    [self createPDFWithHTMLSting:htmlString pathForPDF:destination compeleteBlock:^(BOOL status, NSDictionary *messageInfo) {
        if(compeleteBlock){
             compeleteBlock(status,messageInfo);
        }
    }];
}
#pragma mark 提示
/**
 展示内容

 @param prompt 提示
 */
-(void)alertWithPrompt:(NSString *)prompt{
    if(self.withoutFailPrompt==YES){
        return;
    }
    if((SYSTEM_VERSION<VERSION)){
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertview show];
    }else{
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [[HGBHTMLToPDFTool currentViewController] presentViewController:alert animated:YES completion:nil];
    }
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
    if(![HGBHTMLToPDFTool isURL:url]){
        return NO;
    }
     url=[HGBHTMLToPDFTool urlAnalysis:url];
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
    if(![HGBHTMLToPDFTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBHTMLToPDFTool urlAnalysis:url];
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
    if(![HGBHTMLToPDFTool isURL:url]){
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
    if(![HGBHTMLToPDFTool isURL:url]){
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
#pragma mark 文件
/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBHTMLToPDFTool isExitAtFilePath:directoryPath]){
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

#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBHTMLToPDFTool findBestViewController:viewController];
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
        return [HGBHTMLToPDFTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBHTMLToPDFTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBHTMLToPDFTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBHTMLToPDFTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
