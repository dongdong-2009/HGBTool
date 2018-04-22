//
//  HGBGZip.h
//  MyApp_HGB
//
//  Created by huangguangbao on 2018/3/14.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zlib.h"

#ifdef DEBUG
#define HGBLogFlag YES
#else
#endif

@interface HGBGZip : NSObject

+(NSData*) gzipData:(NSData*)pUncompressedData;  //压缩
+(NSData*) ungzipData:(NSData *)compressedData;  //解压缩
@end
