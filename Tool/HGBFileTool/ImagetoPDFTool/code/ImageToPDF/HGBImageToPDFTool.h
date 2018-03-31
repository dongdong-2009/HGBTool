//
//  HGBImageToPDFTool.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2017/10/31.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


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

@class HGBImageToPDFTool;

/**
 错误类型
 */
typedef enum HGBHGBImagetoPDFToolReslut
{
    HGBHGBImagetoPDFToolReslutSucess=1,//成功
    HGBHGBImagetoPDFToolReslutErrorTypeImage=20,//图片错误
    HGBHGBImagetoPDFToolReslutErrorTypePDFPath=21,//pdf路径错误
    HGBHGBImagetoPDFToolReslutErrorTypeCreate=99//生成错误

}HGBHGBImagetoPDFToolReslut;



typedef void (^HGBImagetoPDFToolCompletionBlock)(BOOL status,NSDictionary *messageInfo);



@interface HGBImageToPDFTool : NSObject
@property (nonatomic, strong) NSString *PDFpath;


#pragma mark init
+(instancetype)shareInstance;
/**
 *  @brief  创建PDF文件
 *
 *  @param  image        图片
 *  @param  destination    PDF文件路径或url
 *  @param  password        要设定的密码
 */
- (void)createPDFFileWithImage:(UIImage *)image toPDFFileDestination:(NSString*)destination withPassword:(NSString *)password compeleteBlock:(HGBImagetoPDFToolCompletionBlock)compeleteBlock;


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
