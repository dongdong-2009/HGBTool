//
//  HGBXMLReader.m
//  测试
//
//  Created by huangguangbao on 2017/9/5.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBXMLReader.h"
#import "HGBXMLModel.h"
#import <UIKit/UIKit.h>


#ifdef HGBLogFlag
#define HGBLog(FORMAT,...) fprintf(stderr,"**********HGBErrorLog-satrt***********\n{\n文件名称:%s;\n方法:%s;\n行数:%d;\n提示:%s\n}\n**********HGBErrorLog-end***********\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],[[NSString stringWithUTF8String:__func__] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define HGBLog(...);
#endif


@interface HGBXMLReader () <NSXMLParserDelegate>

/** 解析结束标志 */
@property (nonatomic, assign) BOOL  parserEnd;

/** 解析结果 */
@property (nonatomic, strong) id                 parserResult;

/** 当前解析到的节点 */
@property (nonatomic, strong) HGBXMLModel  *currNode;

/** 当前节点字符串内容 */
@property (nonatomic, copy  ) NSMutableString   *nodeString;
/** 解析超时定时器 */
@property (nonatomic, strong) NSTimer           *timer;
/** 是否读取底层 */

@end
@implementation HGBXMLReader
static BOOL    _isReadBaseItem=NO;
static NSString  *baseItem=@"";
/**
 *  是否读取最外层Item
 *
 *  @param isReadBaseItem 读取
 *
 */
+(void)isReadBaseItem:(BOOL)isReadBaseItem{
    _isReadBaseItem=isReadBaseItem;

}
#pragma mark 工具方法
/**
 *  XML解析
 *
 *  @param source 待解析的xml路径或url
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithXmlFile:(NSString *)source{
    if(source==nil||source.length==0){
        return nil;
    }

    source=[HGBXMLReader urlAnalysis:source];

    if(![HGBXMLReader urlExistCheck:source]){
        return nil;
    }

    NSURL *xmlFileURL = [NSURL URLWithString:source];
    NSData *xmlData = [NSData dataWithContentsOfURL:xmlFileURL options:NSDataReadingUncached error:NULL];
    return [HGBXMLReader XMLObjectWithData:xmlData];
}
/**
 *  XML解析
 *
 *  @param xmlString 待解析的xml字符串
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithXMLString:(NSString *)xmlString{
    if(xmlString==nil||xmlString.length==0){
        return nil;
    }
    return [HGBXMLReader XMLObjectWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
}
/**
 *  XML解析
 *
 *  @param data 待解析的二进制数据
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithData:(NSData *)data {
    if(data==nil){
        return nil;
    }
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    return [self XMLObjectWithParser:parser];
}

/**
 *  XML解析
 *
 *  @param parser 带解析的parser
 *
 *  @return 解析结果
 */
+ (id)XMLObjectWithParser:(NSXMLParser *)parser {
    HGBXMLReader *xmlParser = [[self alloc] init];
    baseItem=@"";
    /** 配置解析代理 */
    parser.delegate = xmlParser;
    /** 开始解析 */
    [parser parse];

    /** 创建定时器，用于判断解析超时 */
    xmlParser.timer = [NSTimer scheduledTimerWithTimeInterval:PARSER_TIMEOUT target:xmlParser selector:@selector(timeOut) userInfo:nil repeats:NO];
    [xmlParser.timer fire];

    // 等待解析结束
    while (!xmlParser.parserEnd);
    if(!_isReadBaseItem){
        return xmlParser.parserResult;
    }else{
        // 返回解析结果
        return @{baseItem:xmlParser.parserResult};
    }

}
#pragma mark 解析
/**
 *  解析超时回调，可能是由于XML文件格式错误，导致SAX解析无法结束！
 */
- (void)timeOut {
    if(!self.parserEnd) {
        HGBLog(@"解析超时：可能是由于XML文件格式错误！");
        self.parserEnd = TRUE;
    }
}
/********************************************************************
 *
 *                             解析过程
 *
 *******************************************************************/
/**
 *  打开文档
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser {
        HGBLog(@"打开文档%@", parser);
}
/**
 *  关闭文件
 *
 *  @note 设置结束标志位，设置解析结果
 */
-(void)parserDidEndDocument:(NSXMLParser *)parser {
    self.parserResult = _currNode.value;
    self.parserEnd    = TRUE;
    /** 停止定时器 */
    [_timer invalidate];
}

/**
 *  开始节点
 *
 *  @param elementName   节点名称
 *  @param attributeDict 节点参数
 *  @note  生成新的节点对象，记录父子关系
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    /** 创建新的节点 */
    HGBXMLModel *newNode = [[HGBXMLModel alloc] init];

    newNode.attribute = attributeDict.copy;
    if(baseItem==nil||baseItem.length==0){
        baseItem=elementName;
    }
    if(_currNode) {
        /** 存储当前节点到父节点 */
        NSDictionary *dict = @{@"key":elementName, @"value":newNode};
        [_currNode.subNodes addObject:dict];
        if(!_currNode.key) {
            _currNode.key = elementName;
        }
        if((_currNode.key != elementName) && ![_currNode.key isEqualToString:@"-1"]) {
            _currNode.key = @"-1";
        }
        newNode.parent = _currNode;
    }
    /** 记录新的节点为当前节点 */
    _currNode = newNode;

    /** 初始化拼接字符串 */
    _nodeString = [NSMutableString string];
}

/**
 *  遍历节点内容
 *
 *  @param string 节点内容
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    // 拼接节点内容
    [_nodeString appendString:string];
}

/**
 *  结束节点
 *
 *  @param elementName  结束节点名称
 *  @note  根据节点内容，判断当前节点类型：
 1.没有参数，且没有子节点           ---- NSString （例：<test>abc</test>）
 2.含有子节点，且子节点key值不同     ---- NSArray (例：<test>  <sub1>abc</sub1>  <sub2>cde</sub2>  </test>)
 3.含有参数或者子节点key值唯一       ---- NSDictionary (例：<test> <sub1>abc</sub1> <sub1>abc</sub1> </test>或<test para="p" />)
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if(_currNode.subNodes.count == 0 && _currNode.attribute.allKeys.count == 0) {

        /** 没有参数，且没有子节点 */
        _currNode.value = (NSString *)_nodeString.copy;
    }else if((_currNode.key != nil) && ![_currNode.key isEqualToString:@"-1"]) {

        /** 含有参数或者子节点key值唯一 */
        NSMutableArray *subNods = [NSMutableArray array];
        [_currNode.subNodes enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            HGBXMLModel *subNode = dict[@"value"];
            [subNods addObject:subNode.value];
        }];
        _currNode.value = subNods.copy;
    }else {

        /** 含有子节点，且子节点key值不同 */
        NSMutableDictionary *subNodes = [NSMutableDictionary dictionaryWithDictionary:_currNode.attribute];
        [_currNode.subNodes enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
            HGBXMLModel *subNode = dict[@"value"];
            [subNodes setValue:subNode.value forKey:dict[@"key"]];
        }];
        _currNode.value = subNodes.copy;
    }
    if(_currNode.parent) {
        _currNode = _currNode.parent;
    }
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
    if(![HGBXMLReader isURL:url]){
        return NO;
    }
     url=[HGBXMLReader urlAnalysis:url];
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
    if(![HGBXMLReader isURL:url]){
        return nil;
    }
    NSString *urlstr=[HGBXMLReader urlAnalysis:url];
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
    if(![HGBXMLReader isURL:url]){
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
    if(![HGBXMLReader isURL:url]){
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
