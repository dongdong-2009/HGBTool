//
//  HGBContactTool.m
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/4.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBContactTool.h"

#import <MessageUI/MessageUI.h>
#import <Messages/Messages.h>
#import <UIKit/UIKit.h>

#define ReslutCode @"resultCode"
#define ReslutMessage @"resultMessage"






#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBContactTool()<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
/**
 信息
 */
@property(strong,nonatomic)HGBContactReslutBlock messageBlock;
/**
 邮件
 */
@property(strong,nonatomic)HGBContactReslutBlock emailBlock;
@end

@implementation HGBContactTool

static HGBContactTool *instance=nil;
#pragma mark init
+(instancetype)shareInstance{
    if(instance==nil){
        instance=[[HGBContactTool alloc]init];
    }
    return instance;
}
#pragma mark 打电话
/**
 打电话

 @param phoneNum 电话号码
 */
+(BOOL)callPhone:(NSString *)phoneNum{
    if(phoneNum==nil){
        HGBLog(@"电话号码不能为空");
        return NO;
    }
    phoneNum=[HGBContactTool deleteSpace:phoneNum];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"无法拨打该电话");
        return NO;
    }

}
/**
 打开短信界面

 @param phoneNum 电话号码
 */
+(BOOL)openMessageWithPhone:(NSString *)phoneNum{
    if(phoneNum==nil){
        HGBLog(@"电话号码不能为空");
        return NO;
    }
    phoneNum=[HGBContactTool deleteSpace:phoneNum];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@",phoneNum]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"无法打开短信");
        return NO;
    }
}
/**
 打开MobileStore

 @return 结果
 */
+(BOOL)openMobileStore{

    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"itms:"]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
#ifdef __IPHONE_10_0
        static BOOL sucessFlag=YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);

        [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
            sucessFlag=success;
            //发出已完成的信号
            dispatch_semaphore_signal(semaphore);
        }];


        //等待执行，不会占用资源
        dispatch_semaphore_wait(semaphore, 20);
        return sucessFlag;
#else
        return [[UIApplication sharedApplication]openURL:url];
#endif
    }else{
        HGBLog(@"无法打开MobileStore");
        return NO;
    }
}
#pragma mark 发短信
/**
 发送短信

 @param messgage 信息
 @param recivePhoneNums 接收人
 @param reslutBlock 返回
 @param parent 父控制器
 */
-(BOOL)sendMessage:(NSString *)messgage WithRecivePhoneNums:(NSArray<NSString *> *)recivePhoneNums withReslutBlock:(HGBContactReslutBlock)reslutBlock inParent:(UIViewController *)parent{

    if(parent==nil){
        parent=[HGBContactTool currentViewController];
    }
    if(messgage){
        messgage=@"";
    }

    MFMessageComposeViewController *msgCVC=[[MFMessageComposeViewController alloc]init];

    //3:创建接受者
    msgCVC.recipients=recivePhoneNums;
    //4:设置发送消息的内容

    msgCVC.body=messgage;
    //5:设置代理(当取消发送，发送完成，发送失败的时候调用代理的方法)
    msgCVC.messageComposeDelegate=self;
    //6:切换至发送界面
    [parent presentViewController:msgCVC animated:YES completion:nil];
    self.messageBlock=reslutBlock;
    return YES;
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *prompt;
    HGBContactReslut res;

    BOOL flag=NO;
    switch(result){
        case MessageComposeResultCancelled:
            res=HGBContactReslutCanceled;
            prompt=@"发送取消了";
            HGBLog(@"%@",prompt);
            flag=NO;
            break;
        case MessageComposeResultSent:
            res=HGBContactReslutSucessed;
            prompt=@"发送成功";
            flag=YES;

            break;
        case MessageComposeResultFailed:
            res=HGBContactReslutFailed;
            prompt=@"发送失败";
            HGBLog(@"%@",prompt);
            flag=NO;
            break;
        default:
            prompt=@"发送失败";
            res=HGBContactReslutFailed;
            HGBLog(@"%@",prompt);
            flag=NO;
        break;}

    if (self.messageBlock) {
        self.messageBlock(flag, @{ReslutCode:@(res).stringValue,ReslutMessage:prompt});
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 发邮件
/**
 发送邮件

 @param recives 收件人
 @param copyRecives 抄送人
 @param secretCopyRecives 秘密抄送人
 @param subject 邮件主题
 @param body 邮件内容
 @param fileDatas 附件
 @param fileTypes 附件类型
 @param fileNames 附件名
 @param reslutBlock 返回
 @param parent 父控制器
 @return 结果
 */
-(BOOL)sendEmailToRecives:(NSArray<NSString *>*)recives andWithCopyRecives:(NSArray<NSString *> *)copyRecives andWithSecretCopyRecives:(NSArray<NSString *> *)secretCopyRecives andWithSubject:(NSString *)subject andWithBody:(NSString *)body andWithFileDatas:(NSArray <NSData *>*)fileDatas andWithFileTypes:(NSArray<NSString *> *)fileTypes andWithFileNames:(NSArray<NSString  *>*)fileNames  withReslutBlock:(HGBContactReslutBlock)reslutBlock inParent:(UIViewController *)parent
{

    if(parent==nil){
        parent=[HGBContactTool currentViewController];
    }

    //2.创建控制器对象
    MFMailComposeViewController *mailC=[[MFMailComposeViewController alloc]init];
    if (!mailC) {
        // 在设备还没有添加邮件账户的时候mailViewController为空，下面的present view controller会导致程序崩溃，这里要作出判断
        return NO;
    }
    //3.设置接收者
    [mailC setToRecipients:recives];
    //4.主题
    if(subject){
        [mailC setSubject:subject];
    }
    if(copyRecives&&copyRecives.count!=0){
        //5.设置抄送
        [mailC setCcRecipients:copyRecives];
    }
    if(secretCopyRecives&&secretCopyRecives.count!=0){
        //6.设置秘密抄送
        [mailC setBccRecipients:secretCopyRecives];
    }
    if(body&&body.length!=0){
        //7.设置内容
        [mailC setMessageBody:body isHTML:NO];
    }
    NSInteger n;
    if(fileTypes&&fileDatas&&fileNames){
        if(fileDatas.count<fileTypes.count){
            if(fileNames.count<fileDatas.count){
                n=fileNames.count;
            }else{
                n=fileDatas.count;
            }

        }else{
            if(fileNames.count<fileTypes.count){
                n=fileNames.count;
            }else{
                n=fileTypes.count;
            }
        }
        for(int i=0;i<n;i++){
            NSData *fileData=fileDatas[i];
            NSString *fileType=fileTypes[i];
            NSString *fileName=fileNames[i];
            if(fileData&&fileType&&fileType.length!=0&&fileName&&fileName.length!=0){
                [mailC addAttachmentData:fileData mimeType:fileType fileName:fileName];
            }

        }

    }

    //8.设置附件


    //9.设置代理
    mailC.mailComposeDelegate=self;
    //10.切换到发送邮件控制器
    [parent presentViewController:mailC animated:YES completion:nil];
    self.emailBlock=reslutBlock;
    return YES;
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *prompt;
    BOOL flag=NO;
    HGBContactReslut res;
    switch (result) {
        case  MFMailComposeResultCancelled:
            res=HGBContactReslutCanceled;
            prompt=@"发送取消了";
            HGBLog(@"%@",prompt);
            flag=NO;
            break;
        case  MFMailComposeResultSaved:
            res=HGBContactReslutSaved;
            prompt=@"邮件已保存到草稿箱";
            HGBLog(@"%@",prompt);
            flag=NO;
            break;
        case  MFMailComposeResultSent:
            res=HGBContactReslutSucessed;
            prompt=@"发送成功";
            flag=YES;
            break;
        case  MFMailComposeResultFailed:
            res=HGBContactReslutFailed;
            prompt=@"发送失败";
            HGBLog(@"%@",prompt);
            flag=NO;

            break;

        default:
            prompt=@"发送失败";
            res=HGBContactReslutFailed;
            HGBLog(@"%@",prompt);
            flag=NO;
            break;

    }
    if (self.emailBlock) {
        self.emailBlock(flag,@{ReslutCode:@(res).stringValue,ReslutMessage:prompt});
    }
    [controller dismissViewControllerAnimated:YES completion:nil];

}
#pragma mark 其他
+(NSString *)deleteSpace:(NSString *)string
{
    if(string==nil){
        return nil;
    }
    while ([string containsString:@" "]){
        string=[string stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return string;
}
#pragma mark 获取当前控制器

/**
 获取当前控制器

 @return 当前控制器
 */
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [HGBContactTool findBestViewController:viewController];
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
        return [HGBContactTool findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBContactTool findBestViewController:svc.viewControllers.lastObject];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBContactTool findBestViewController:svc.topViewController];
        }else{
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0){
            return [HGBContactTool findBestViewController:svc.selectedViewController];
        }else{
            return vc;
        }
    } else {
        return vc;
    }
}
@end
