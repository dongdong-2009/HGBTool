//
//  HGBCompressedFileTool.h
//  HelloCordova
//
//  Created by huangguangbao on 2017/7/11.
//
//

#import <Foundation/Foundation.h>

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
typedef enum HGBCompressedFileToolReslut
{
    HGBCompressedFileToolReslutSucess=1,//成功
    HGBCompressedFileToolErrorTypeSrcPath=20,//源文件路径错误
    HGBCompressedFileToolErrorTypeDestinationPath=21,//目标路径错误
    HGBCompressedFileToolErrorTypeCompress=99//解压或压缩错误

}HGBCompressedFileToolReslut;

typedef void(^HGBCompressedCompleteBlock)(BOOL status,NSDictionary *messageInfo);

@interface HGBCompressedFileTool : NSObject
/**
 解压
 @param source 文件路径或快捷url
 @param password 密码
 @param destination 目标地址或快捷url
 @param completeBlock 结果
*/
+(void)unArchive: (NSString *)source andPassword:(NSString*)password toDestination:(NSString *)destination andWithCompleteBlock:(HGBCompressedCompleteBlock)completeBlock;
/**
  压缩
  @param source 文件路径或快捷url集合
  @param destination 目标地址或快捷url
  @param completeBlock 结果
*/
+(void)archiveToZipWithSource: (NSArray *)source toDestination:(NSString *)destination andWithCompleteBlock:(HGBCompressedCompleteBlock)completeBlock;
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
