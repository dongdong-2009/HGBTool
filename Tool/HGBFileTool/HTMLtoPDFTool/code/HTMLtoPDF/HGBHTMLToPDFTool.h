//
//  HGBHTMLToPDFTool.h
//  测试
//
//  Created by huangguangbao on 2017/8/28.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGBHTMLtoPDF.h"


#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

//快捷url提示
/**
 project://工程包内
 home://沙盒路径
 http:// https://网络路径
 document://  或defaults://沙盒Documents文件夹
 caches://沙盒Caches
 tmp://沙盒Tmp文件夹

 */

/**
 错误类型
 */
typedef enum HGBHGBHTMLtoPDFToolReslut
{
    HGBHGBHTMLtoPDFToolReslutSucess=1,//成功
    HGBHGBHTMLtoPDFToolReslutErrorTypeHTMLPath=20,//html路径错误
    HGBHGBHTMLtoPDFToolReslutErrorTypePDFPath=21,//pdf路径错误
    HGBHGBHTMLtoPDFToolReslutErrorTypeCreate=99//生成错误

}HGBHGBHTMLtoPDFToolReslut;

typedef void (^HGBHTMLtoPDFToolCompletionBlock)(BOOL status,NSDictionary *messageInfo);


@interface HGBHTMLToPDFTool : NSObject
/**
 失败提示
 */
@property(assign,nonatomic)BOOL withoutFailPrompt;
#pragma mark init
/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;

#pragma mark 工具
/**
 通过HTML字符串创建PDF

 @param HTMLString HTML字符串
 @param PDFpath pdf路径
 @param compeleteBlock 完成回调
 
 */
- (void)createPDFWithHTMLSting:(NSString*)HTMLString pathForPDF:(NSString*)PDFpath compeleteBlock:(HGBHTMLtoPDFToolCompletionBlock)compeleteBlock;
/**
 通过HTML文件创建PDF

 @param HTMLFileSource HTML文件路径或url
 @param destination pdf路径或url
 @param compeleteBlock 完成回调

 */
- (void)createPDFWithHTMLFile:(NSString*)HTMLFileSource toPDFFileDestination:(NSString*)destination compeleteBlock:(HGBHTMLtoPDFToolCompletionBlock)compeleteBlock;
#pragma mark url

/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysisToPath:(NSString *)url;
/**
 url解析

 @return 解析后url
 */
+(NSString *)urlAnalysis:(NSString *)url;
@end
