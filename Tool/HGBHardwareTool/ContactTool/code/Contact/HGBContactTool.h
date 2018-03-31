//
//  HGBContactTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/2/4.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MessageUI/MessageUI.h>

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

/**
 错误类型
 */
typedef enum HGBContactReslut
{
    HGBContactReslutSucessed=1,//成功
    HGBContactReslutCanceled=2,//取消
    HGBContactReslutFailed=99,//失败
    HGBContactReslutSaved=80//保存至草稿

}HGBContactReslut;

typedef void (^HGBContactReslutBlock)(BOOL status,NSDictionary *returnMessage);


@interface HGBContactTool : NSObject
#pragma mark init
+(instancetype)shareInstance;
/**
 打电话

 @param phoneNum 电话号码
 */
+(BOOL)callPhone:(NSString *)phoneNum;
/**
 打开短信界面

 @param phoneNum 电话号码
 */
+(BOOL)openMessageWithPhone:(NSString *)phoneNum;
/**
 打开MobileStore
 @return 结果
 */
+(BOOL)openMobileStore;

/**
 发送短信

 @param messgage 信息
 @param recivePhoneNums 接收人
 @param reslutBlock 返回
 @param parent 父控制器
 */
-(BOOL)sendMessage:(NSString *)messgage WithRecivePhoneNums:(NSArray<NSString *> *)recivePhoneNums withReslutBlock:(HGBContactReslutBlock)reslutBlock inParent:(UIViewController *)parent;


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
-(BOOL)sendEmailToRecives:(NSArray<NSString *>*)recives andWithCopyRecives:(NSArray<NSString *> *)copyRecives andWithSecretCopyRecives:(NSArray<NSString *> *)secretCopyRecives andWithSubject:(NSString *)subject andWithBody:(NSString *)body andWithFileDatas:(NSArray <NSData *>*)fileDatas andWithFileTypes:(NSArray<NSString *> *)fileTypes andWithFileNames:(NSArray<NSString  *>*)fileNames  withReslutBlock:(HGBContactReslutBlock)reslutBlock inParent:(UIViewController *)parent;

@end

