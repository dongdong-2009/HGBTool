//
//  HGBAppCheckTool.m
//  HelloCordova
//
//  Created by huangguangbao on 2017/8/17.
//
//

#import "HGBAppCheckTool.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CommonCrypto/CommonDigest.h>





#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif

typedef void(^ SucessBlock)(void);

@interface HGBAppCheckTool()<UIAlertViewDelegate>
@property(strong,nonatomic)SucessBlock sucessBlock;

@end
@implementation HGBAppCheckTool
#pragma mark init
static HGBAppCheckTool *instance=nil;
+ (instancetype)shareInstance
{
    if (instance==nil) {
        instance=[[HGBAppCheckTool alloc]init];
    }
    return instance;
}
#pragma mark app自检

/**
 app自检
 @return 自检结果
 */
+(BOOL)appCheck{
    [HGBAppCheckTool shareInstance];
    NSString *appCodeSignatureData=[HGBAppCheckTool getAppCodeSignatureData];


    NSString *path=@"project://appCheck.plist";
    path=[HGBAppCheckTool urlAnalysisToPath:path];
    NSDictionary *appCheckDic=[[NSDictionary alloc]initWithContentsOfFile:path];
    NSString *key=[appCheckDic objectForKey:@"appCodeSignature"];
    if(key==nil||(![appCodeSignatureData isEqualToString:key])){
        HGBLog(@"app自检失败");
        [HGBAppCheckTool alertPromptWithTitle:@"版权提示" Detail:@"您使用的APP非正版,请下载正版使用!" andWithSucessBlock:^{
            [[UIApplication sharedApplication]setIdleTimerDisabled:NO];
            exit(0);
        } InParent:[HGBAppCheckTool currentViewController]];
        return NO;
    }else{
        return YES;
    }
}
#pragma mark 获取app数据
/**
 获取签名证书加密数据

 @return 签名证书加密数据
 */
+ (NSString *)getAppCodeSignatureData
{
    NSString *sourcePath =[HGBAppCheckTool getAppCodeSignaturePath];
    NSData *sourceData=[[NSData alloc]initWithContentsOfFile:sourcePath];
    NSString *sourceDataString=[[NSString alloc]initWithData:sourceData encoding:NSASCIIStringEncoding];

    NSString *sourceDataEncryptString=[HGBAppCheckTool encryptStringWithsha1:sourceDataString];
    return sourceDataEncryptString;
}

/**
 获取资源文件数据

 @return 资源文件数据
 */
+ (NSString *)getAppBinaryData
{
    NSString *sourcePath =[HGBAppCheckTool getAppBinaryPath];
    NSData *sourceData=[[NSData alloc]initWithContentsOfFile:sourcePath];
    NSString *sourceDataString=[[NSString alloc]initWithData:sourceData encoding:NSASCIIStringEncoding];

    NSString *sourceDataEncryptString=[HGBAppCheckTool encryptStringWithsha1:sourceDataString];
    return sourceDataEncryptString;
}
#pragma mark 检包路径获取

/**
 获取签名证书路径

 @return 签名证书路径
 */
+ (NSString *)getAppCodeSignaturePath
{
//    NSString *excutableName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
//    NSString *docPath = [HGBAppCheckTool getDocumentFilePath];
//    NSString *appPath = [[docPath stringByAppendingPathComponent:excutableName]stringByAppendingPathExtension:@"app"];
//    NSString *codeSignaturePath = [[appPath stringByAppendingPathComponent:@"_CodeSignature"]stringByAppendingPathComponent:@"CodeResources"];

    NSString *bundlePath=[[NSBundle mainBundle]resourcePath];
    NSString *appCodeSignaturePath=[bundlePath stringByAppendingPathComponent:@"_CodeSignature/CodeResources"];
    
    return appCodeSignaturePath;
}

/**
 获取资源文件路径

 @return 资源文件路径
 */
+ (NSString *)getAppBinaryPath
{
//    NSString *excutableName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
//    NSString *docPath = [HGBAppCheckTool getDocumentFilePath];
//    NSString *appPath = [[docPath stringByAppendingPathComponent:excutableName] stringByAppendingPathExtension:@"app"];
//    NSString *binaryPath = [appPath stringByAppendingPathComponent:excutableName];
    NSString *bundlePath=[[NSBundle mainBundle]resourcePath];


    return bundlePath;
}
#pragma mark 提示
/**
 展示内容

 @param prompt 提示
 */
+(void)alertWithPrompt:(NSString *)prompt{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [[HGBAppCheckTool currentViewController] presentViewController:alert animated:YES completion:nil];
#else
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:prompt delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertview show];
#endif

}
/**
 *  单键-功能－标题
 *
 *  @param title    提示标题
 *  @param detail     提示详情
 *
 *  @param sucessBlock 成功返回
 *  @param parent 父控件
 */
+(void)alertPromptWithTitle:(NSString *)title Detail:(NSString *)detail andWithSucessBlock:(SucessBlock)sucessBlock InParent:(UIViewController *)parent
{
#ifdef __IPHONE_8_0
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:detail preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        sucessBlock();
    }];
    [alert addAction:action1];
    [parent presentViewController:alert animated:YES completion:nil];
#else
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:title message:detail delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertview show];
#endif

}
#ifdef __IPHONE_8_0
#else
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(self.sucessBlock){
        self.sucessBlock();
    }
}
#endif

#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBAppCheckTool findBestViewController:viewController];
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
        return [HGBAppCheckTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBAppCheckTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBAppCheckTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBAppCheckTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}

#pragma mark sha1加密
/**
 *  sha1加密
 *
 *  @param string 需要加密的字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString*)encryptStringWithsha1:(NSString*)string
{
    if(string==nil){
        return nil;
    }
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (int)data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];

    return output;

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
    if(![HGBAppCheckTool isURL:url]){
        return NO;
    }
     url=[HGBAppCheckTool urlAnalysis:url];
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
    if(![HGBAppCheckTool isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBAppCheckTool urlAnalysis:url];
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
    if(![HGBAppCheckTool isURL:url]){
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
    if(![HGBAppCheckTool isURL:url]){
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
