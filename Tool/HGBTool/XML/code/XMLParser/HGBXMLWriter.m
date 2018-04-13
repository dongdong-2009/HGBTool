//
//  HGBXMLWriter.m
//  测试
//
//  Created by huangguangbao on 2017/9/5.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBXMLWriter.h"
#import <UIKit/UIKit.h>

#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif



#define PREFIX_STRING_FOR_ELEMENT @"@"

@interface HGBXMLWriter(){
@private
    NSMutableArray* nodes;
    NSString* xml;
    NSMutableArray* treeNodes;
    BOOL isRoot;
    NSString* passDict;
    BOOL withHeader;
}

@end
@implementation HGBXMLWriter

-(void)serialize:(id)root
{
    if([root isKindOfClass:[NSArray class]])
    {
        int mula = (int)[root count];
        mula--;
        [nodes addObject:[NSString stringWithFormat:@"%i",(int)mula]];

        for(id objects in root)
        {
            if ([[nodes lastObject] isEqualToString:@"0"] || [nodes lastObject] == NULL || ![nodes count])
            {
                [nodes removeLastObject];
                [self serialize:objects];
            }
            else
            {
                [self serialize:objects];
                if(!isRoot)
                xml = [xml stringByAppendingFormat:@"</%@><%@>",[treeNodes lastObject],[treeNodes lastObject]];
                else
                isRoot = FALSE;
                int value = [[nodes lastObject] intValue];
                [nodes removeLastObject];
                value--;
                [nodes addObject:[NSString stringWithFormat:@"%i",(int)value]];
            }
        }
    }
    else if ([root isKindOfClass:[NSDictionary class]])
    {
        for (NSString* key in root)
        {
            if(!isRoot)
            {
                [treeNodes addObject:key];
                xml = [xml stringByAppendingFormat:@"<%@>",key];
                [self serialize:[root objectForKey:key]];
                xml =[xml stringByAppendingFormat:@"</%@>",key];
                [treeNodes removeLastObject];
            } else {
                isRoot = FALSE;
                [self serialize:[root objectForKey:key]];
            }
        }
    }
    else if ([root isKindOfClass:[NSString class]] || [root isKindOfClass:[NSNumber class]] || [root isKindOfClass:[NSURL class]])
    {
        //            if ([root hasPrefix:"PREFIX_STRING_FOR_ELEMENT"])
        //            is element
        //            else
        xml = [xml stringByAppendingFormat:@"%@",root];
    }
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        xml = @"";
        if (withHeader)
        xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        nodes = [[NSMutableArray alloc] init];
        treeNodes = [[NSMutableArray alloc] init];
        isRoot = YES;
        passDict = [[dictionary allKeys] lastObject];
        xml = [xml stringByAppendingFormat:@"<%@>\n",passDict];
        [self serialize:dictionary];
    }

    return self;
}
- (id)initWithDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header {
    withHeader = header;
    self = [self initWithDictionary:dictionary];
    return self;
}

-(void)dealloc
{
    //    [xml release],nodes =nil;
     nodes = nil ;
    treeNodes = nil;
}

-(NSString *)getXML
{
    xml = [xml stringByReplacingOccurrencesOfString:@"</(null)><(null)>" withString:@"\n"];
    xml = [xml stringByAppendingFormat:@"\n</%@>",passDict];
    xml=[@"<?xml version='1.0' encoding='utf-8'?>\n" stringByAppendingFormat:@"%@", xml];
    return xml;
}
#pragma mark XML生成
/**
 *  XML生成
 *
 *  @param object 数据源 数据类型可以为字典数组json字符串
 *
 *  @return xml结果
 */
+(NSString *)XMLStringFromObject:(NSObject *)object
{
    if (object==nil ){
        HGBLog(@"参数不正确");
        return nil;
    }
    NSDictionary *dictionary=nil;
    if([object isKindOfClass:[NSString class]]){
        dictionary=[HGBXMLWriter JSONStringToObject:(NSString *)object];
        if([dictionary allKeys].count!=1){
            dictionary=@{@"items":dictionary};
        }

    }else if ([object isKindOfClass:[NSArray class]]){
        dictionary=@{@"items":object};
    }else if ([object isKindOfClass:[NSDictionary class]]){
        dictionary=(NSDictionary *)object;
        if([dictionary allKeys].count!=1){
            dictionary=@{@"items":dictionary};
        }
    }
    
    HGBXMLWriter* fromDictionary = [[HGBXMLWriter alloc]initWithDictionary:dictionary];
    return [fromDictionary getXML];
}
/**
 *  XML生成
 *
 *  @param object 数据源 数据类型可以为字典数组json字符串
 *  @param header 是否是属性
 *
 *  @return xml结果
 */
+(NSString *)XMLStringFromObject:(NSObject *)object withHeader:(BOOL)header{
    if (object==nil ){
        HGBLog(@"参数不正确");
        return nil;
    }
    NSDictionary *dictionary=nil;
    if([object isKindOfClass:[NSString class]]){
        dictionary=[HGBXMLWriter JSONStringToObject:(NSString *)object];
        if([dictionary allKeys].count!=1){
            dictionary=@{@"items":dictionary};
        }
    }else if ([object isKindOfClass:[NSArray class]]){
        dictionary=@{@"items":object};
    }else if ([object isKindOfClass:[NSDictionary class]]){
        dictionary=(NSDictionary *)object;
        if([dictionary allKeys].count!=1){
            dictionary=@{@"items":dictionary};
        }
    }
    HGBXMLWriter* fromDictionary = [[HGBXMLWriter alloc]initWithDictionary:dictionary withHeader:header];
    return [fromDictionary getXML];
}
/**
 *  XML生成
 *
 *  @param object 数据源 数据类型可以为字典数组json字符串
 *  @param header 是否是属性
 *  @param destination xml文件地址或url
 *  @param error 错误
 *
 *  @return xml结果
 */
+(BOOL)XMLFileFromObject:(NSObject *)object withHeader:(BOOL)header toDestinationFile:(NSString *)destination  Error:(NSError **)error
{

    if (object==nil ){
        HGBLog(@"参数不正确");
        return nil;
    }
    NSDictionary *dictionary=nil;
    if([object isKindOfClass:[NSString class]]){
        dictionary=[HGBXMLWriter JSONStringToObject:(NSString *)object];
        if([dictionary allKeys].count!=1){
            dictionary=@{@"items":dictionary};
        }
    }else if ([object isKindOfClass:[NSArray class]]){
        dictionary=@{@"items":object};
    }else if ([object isKindOfClass:[NSDictionary class]]){
        dictionary=(NSDictionary *)object;
        if([dictionary allKeys].count!=1){
            dictionary=@{@"items":dictionary};
        }
    }
    NSString *diretoryPath=[[[NSURL URLWithString:destination]path] stringByDeletingLastPathComponent];
    if(![HGBXMLWriter isExitAtFilePath:diretoryPath]){
        [HGBXMLWriter createDirectoryPath:diretoryPath];
    }

    HGBXMLWriter* fromDictionary = [[HGBXMLWriter alloc]initWithDictionary:dictionary withHeader:header];
    NSString *url=[HGBXMLWriter urlAnalysis:destination];
    NSString *path=[[NSURL URLWithString:url]path];
    if([HGBXMLWriter urlExistCheck:url]){
        HGBLog(@"路径已存在不正确");
        return false;
    }
    [[fromDictionary getXML] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
    if (error){
        return false;
    }else{
        return true;
    }


}

#pragma mark json
/**
 把Json字符串转化成json对象

 @param jsonString json字符串
 @return json字符串
 */
+ (id)JSONStringToObject:(NSString *)jsonString{
    if(![jsonString isKindOfClass:[NSString class]]){
        return nil;
    }
    jsonString=[HGBXMLWriter jsonStringHandle:jsonString];
    NSError *error = nil;
    NSData  *data=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"{"]){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            HGBLog(@"%@",error);
            return jsonString;
        }else{
            return dic;
        }
    }else if(jsonString.length>0&&[[jsonString substringToIndex:1] isEqualToString:@"["]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if(error){
            HGBLog(@"%@",error);
            return jsonString;
        }else{
            return array;
        }
    }else{
        return jsonString;
    }


}
/**
 json字符串处理

 @param jsonString 字符串处理
 @return 处理后字符串
 */
+(NSString *)jsonStringHandle:(NSString *)jsonString{
    if(jsonString==nil){
        return nil;
    }
    NSString *string=jsonString;
    //大括号

    //中括号
    while ([string containsString:@"【"]) {
        string=[string stringByReplacingOccurrencesOfString:@"【" withString:@"]"];
    }
    while ([string containsString:@"】"]) {
        string=[string stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
    }

    //小括弧
    while ([string containsString:@"（"]) {
        string=[string stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    }

    while ([string containsString:@"）"]) {
        string=[string stringByReplacingOccurrencesOfString:@"）" withString:@")"];
    }


    while ([string containsString:@"("]) {
        string=[string stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    }

    while ([string containsString:@")"]) {
        string=[string stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    }


    //逗号
    while ([string containsString:@"，"]) {
        string=[string stringByReplacingOccurrencesOfString:@"，" withString:@","];
    }
    while ([string containsString:@";"]) {
        string=[string stringByReplacingOccurrencesOfString:@";" withString:@","];
    }
    while ([string containsString:@"；"]) {
        string=[string stringByReplacingOccurrencesOfString:@"；" withString:@","];
    }
    //引号
    while ([string containsString:@"“"]) {
        string=[string stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    }
    while ([string containsString:@"”"]) {
        string=[string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    }
    while ([string containsString:@"‘"]) {
        string=[string stringByReplacingOccurrencesOfString:@"‘" withString:@"\""];
    }
    while ([string containsString:@"'"]) {
        string=[string stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    }
    //冒号
    while ([string containsString:@"："]) {
        string=[string stringByReplacingOccurrencesOfString:@"：" withString:@":"];
    }
    //等号
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    while ([string containsString:@"="]) {
        string=[string stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    }
    return string;

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
    if(![HGBXMLWriter isURL:url]){
        return NO;
    }
     url=[HGBXMLWriter urlAnalysis:url];
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
    if(![HGBXMLWriter isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBXMLWriter urlAnalysis:url];
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
    if(![HGBXMLWriter isURL:url]){
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
    if(![HGBXMLWriter isURL:url]){
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
 文档是否存在

 @param filePath 文件路径
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

/**
 创建文件夹

 @param directoryPath 路径
 @return 结果
 */
+(BOOL)createDirectoryPath:(NSString *)directoryPath{
    if([HGBXMLWriter isExitAtFilePath:directoryPath]){
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
@end
