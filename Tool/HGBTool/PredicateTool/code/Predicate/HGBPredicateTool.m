//
//  HGBPredicateTool.m
//  测试
//
//  Created by huangguangbao on 2017/8/6.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBPredicateTool.h"


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@implementation HGBPredicateTool
/**
 字符串校验

 @param string 字符串
 @param condition 条件
 @return 结果
 */
+(BOOL)evaluateString:(NSString *)string WithCondition:(NSString *)condition{
    if(![string isKindOfClass:[NSString class]]){
        HGBLog(@"string参数格式错误");
        return NO;
    }
    if(!condition){
        HGBLog(@"condition参数错误");
        return NO;
    }
    return [HGBPredicateTool evaluateObject:string WithPredicateCondition:condition andWithType:HGBPredicateTypeMatch];
}
/**
 谓词工具-便捷版

 @param object 对象
 @param condition 条件
 @param type 类型
 @return 结果
 */
+(BOOL)evaluateObject:(id)object WithPredicateCondition:(NSString *)condition andWithType:(HGBPredicateType )type{
    if(![object isKindOfClass:[NSObject class]]){
        HGBLog(@"object参数格式错误");
        return NO;
    }
    if(!condition){
        HGBLog(@"condition参数错误");
        return NO;
    }

    NSString *mode=@"";
    if(type==HGBPredicateTypeEqual){
        mode=@"SELF = %@";
    }else if (type==HGBPredicateTypeLike){
        mode=@"SELF LIKE %@";
    }else if (type==HGBPredicateTypeMatch){
        mode=@"SELF MATCHES %@";
    }else{
        mode=@"SELF = %@";
    }



    NSPredicate *predicate=[NSPredicate predicateWithFormat:mode,condition];
    if([predicate evaluateWithObject:object]){
        return YES;
    }else{

        return NO;
    }
    
}
/**
 谓词工具

 @param predicateString predicate
 @param object 对象
 @return 结果
 */
+(BOOL)evaluateObject:(id)object WithPredicateFormat:(NSString *)predicateString,...{

    if(![object isKindOfClass:[NSObject class]]){
        HGBLog(@"object参数格式错误");
        return NO;
    }
    NSMutableArray *array = [NSMutableArray array];

    if (predicateString)
    {
        va_list argsList;
        [array addObject:predicateString];
        va_start(argsList, predicateString);
        id arg;
        while ((arg = va_arg(argsList, id)))
        {
            [array addObject:arg];
        }
        va_end(argsList);

        NSPredicate *predicate=[NSPredicate predicateWithFormat:predicateString,argsList];
        if([predicate evaluateWithObject:object]){
            return YES;
        }else{
          
            return NO;
        }
    }else{
        return NO;
    }




}
@end
