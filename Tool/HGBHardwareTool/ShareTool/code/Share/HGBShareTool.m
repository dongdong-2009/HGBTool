
//
//  HGBShareTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/3.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBShareTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <SafariServices/SafariServices.h>
#import <Social/Social.h>




#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"



#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBShareTool
/**
 分享

 @param source 数据 //可以 UIImage NSString NSURL NSData  NSAttributedString ALAsset 或以上组成的数组
 @param parent 父控制器
 @param result 结果
 @return 结果
 */
+(BOOL)shareSource:(id)source inParent:(UIViewController *)parent andWithResult:(HGBShareReslutBlock)result{
    NSArray *shareArray;
    if([source isKindOfClass:[NSData class]]||[source isKindOfClass:[UIImage class]]||[source isKindOfClass:[NSURL class]]||[source isKindOfClass:[NSString class]]||[source isKindOfClass:[NSAttributedString class]]){
        shareArray=@[source];
    }else if ([source isKindOfClass:[NSArray class]]){
        for(id object in source){
            if(!([object isKindOfClass:[NSData class]]||[object isKindOfClass:[UIImage class]]||[object isKindOfClass:[NSURL class]]||[object isKindOfClass:[NSString class]]||[object isKindOfClass:[NSAttributedString class]])){
                 HGBLog(@"参数格式错误");
                if(result){
                    result(NO,@{ReslutCode:@(HGBShareErrorTypeParams).stringValue,ReslutMessage:@"参数格式错误"});

                }
                return NO;
            }
        }
        shareArray=source;

    }else{
        HGBLog(@"参数格式错误");
        if(result){
            result(NO,@{ReslutCode:@(HGBShareErrorTypeParams).stringValue,ReslutMessage:@"参数格式错误"});
            
        }
        return NO;
    }
    if(parent==nil){
        parent=[HGBShareTool currentViewController];
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:shareArray applicationActivities:nil];
#ifdef __IPHONE_8_0
    //初始化回调方法
    UIActivityViewControllerCompletionWithItemsHandler activityBlock = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
    {
        if(activityError){
            result(NO,@{ReslutCode:@(HGBShareErrorTypeError).stringValue,ReslutMessage:@"失败"});
        }
        if (completed){
            result(YES,@{ReslutCode:activityType,ReslutMessage:activityType});

        }else{
            result(NO,@{ReslutCode:@(HGBShareErrorTypeCancel).stringValue,ReslutMessage:@"取消"});
        }

    };

    // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
    activityVC.completionWithItemsHandler = activityBlock;
#else
    UIActivityViewControllerCompletionHandler activityBlock = ^(NSString *activityType,BOOL completed)
    {

        if (completed){
            result(YES,nil);

        }else{
            result(NO,@{ReslutCode:@(HGBShareErrorTypeCancel).stringValue,ReslutMessage:@"取消"});
        }

    };
    // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
    activityVC.completionHandler = activityBlock;
#endif
    [parent presentViewController:activityVC animated:YES completion:nil];
    return YES;

}
/**
 分享

 @param title 标题
 @param url url
 @param image 图片
 @param parent 父控制器
 @param result 结果
 @return 结果
 */
+(BOOL)shareWithTitle:(NSString *)title andWithURL:(NSString *)url andWithImage:(UIImage *)image inParent:(UIViewController *)parent andWithResult:(HGBShareReslutBlock)result{
    if(title==nil&&image==nil&&url==nil){
        HGBLog(@"参数错误");
        if(result){
            result(NO,@{ReslutCode:@(HGBShareErrorTypeParams).stringValue,ReslutMessage:@"参数错误"});

        }
        return NO;
    }
    NSMutableArray *array=[NSMutableArray array];
    if(image){
        [array addObject:image];
    }
    if(title){
        [array addObject:title];
    }
    if(url){
        [array addObject:[NSURL URLWithString:url]];
    }
    return [HGBShareTool shareSource:array inParent:parent andWithResult:result];
}
/**
 添加书签

 @param title 标题
 @param prompt 描述
 @param url url
 @return 结果
 */
+(BOOL)shareToSafariBookmarkWithTitle:(NSString *)title andWithPrompt:(NSString *)prompt andWithURL:(NSString *)url{
    NSURL *saveURL = [NSURL URLWithString:url];
    if(url==nil){
        return NO;
    }
    NSError *error;
    BOOL result = [[SSReadingList defaultReadingList] addReadingListItemWithURL:saveURL title:title previewText:prompt  error:&error];
    if(error){
        HGBLog(@"%@",error);
        return NO;
    }
    return result;
}
/**
 系统分享

 @param shareType 分享类型
 @param title 分享文字
 @param images 分享图片集合
 @param urls 分享url集合
 @param parent 父控制器
 @param result 结果
 @return 结果
 */
+(BOOL)slshareWithShareType:(HGBSLShareType)shareType andWithTitle:(NSString *)title andWithImages:(NSArray <UIImage *>*)images andWithURLs:(NSArray <NSString *>*)urls inParent:(UIViewController *)parent andWithResult:(HGBShareReslutBlock)result{
    if(parent==nil){
        parent=[HGBShareTool currentViewController];
    }
    NSString *shareTypeString;
    if(shareType==HGBSLShareTypeTwitter){
        shareTypeString=SLServiceTypeTwitter;
    }else if (shareType==HGBSLShareTypeFacebook){
        shareTypeString=SLServiceTypeFacebook;
    }else if (shareType==HGBSLShareTypeSinaWeibo){
        shareTypeString=SLServiceTypeSinaWeibo;
    }else if (shareType==HGBSLShareTypeTencentWeibo){
        shareTypeString=SLServiceTypeTencentWeibo;
    }else if (shareType==HGBSLShareTypeLinkedIn){
        shareTypeString=SLServiceTypeLinkedIn;
    }


    //1.判断平台是否可用(系统没有集成,用户设置新浪账号)
    if (![SLComposeViewController isAvailableForServiceType:shareTypeString]) {
        if(result){
            result(NO,@{ReslutCode:@(HGBShareErrorTypeAccount).stringValue,ReslutMessage:@"未设置账号"});
        }
        HGBLog(@"到设置界面去设置自己的新浪账号");
        return NO;
    }
    // 2.创建分享控制器
    SLComposeViewController *composeVc = [SLComposeViewController composeViewControllerForServiceType:shareTypeString];

    // 2.1.添加分享的文字
    if(title){
         [composeVc setInitialText:title];
    }

    for(UIImage *image in images){
        // 2.2.添加分享的图片
        [composeVc addImage:image];
    }


    for (NSString *urlString in urls){
        NSURL *url=[NSURL URLWithString:urlString];
        // 2.3 添加分享的URL
        [composeVc addURL:url];
    }

    // 3.弹出控制器进行分享
    [parent presentViewController:composeVc animated:YES completion:nil];

    // 4.设置监听发送结果
    composeVc.completionHandler = ^(SLComposeViewControllerResult reulst) {
        if (reulst == SLComposeViewControllerResultDone) {

            result(YES,@{ReslutCode:@(YES).stringValue,ReslutMessage:@"用户发送成功"});
        } else {
             HGBLog(@"用户取消发送");
            if(result){
                result(NO,@{ReslutCode:@(HGBShareErrorTypeError).stringValue,ReslutMessage:@"用户取消发送"});
            }
        }
    };
    return YES;
}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBShareTool findBestViewController:viewController];
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
        return [HGBShareTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBShareTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBShareTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBShareTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
