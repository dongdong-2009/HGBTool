
//
//  HGBDownLoadTask.m
//  测试
//
//  Created by huangguangbao on 2018/3/13.
//  Copyright © 2018年 agree.com.cn. All rights reserved.
//

#import "HGBDownLoadTask.h"

@implementation HGBDownLoadTask
#pragma mark 单例
static HGBDownLoadTask *instance=nil;
/**
 单例

 @return 单例
 */
+(instancetype)shareInstance
{

    if (instance==nil) {
        instance=[[HGBDownLoadTask alloc]init];

    }
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.totalSize=0;
        self.downloadSize=0;
        self.progress=0;
        self.id=[self getSecondTimeStringSince1970];
        self.groupId=HGBDownLoadTaskGrounpID;
    }
    return self;
}
#pragma mark set
-(void)setUrl:(NSString *)url{
    _url=url;
    NSString *lastName=[_url lastPathComponent];
    if([lastName containsString:@"?"]){
        lastName=[lastName componentsSeparatedByString:@"?"][0];

    }
    if(_path==nil||_path.length==0){
        _path=[[self getDocumentFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",_id,lastName]];
    }
    if(_name==nil||_name.length==0){
        _name=lastName;
    }


}

//编码
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_id forKey:@"id"];

    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_groupId forKey:@"groupId"];

    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_data forKey:@"data"];

    [aCoder encodeBool:_status forKey:@"status"];
    [aCoder encodeFloat:_totalSize forKey:@"totalSize"];
    [aCoder encodeFloat:_progress forKey:@"progress"];
    [aCoder encodeFloat:_downloadSize forKey:@"downloadSize"];





}
//解码
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    _id=[aDecoder decodeObjectForKey:@"id"];
    _name=[aDecoder decodeObjectForKey:@"name"];

    _groupId=[aDecoder decodeObjectForKey:@"groupId"];

    _url=[aDecoder decodeObjectForKey:@"url"];
    _path=[aDecoder decodeObjectForKey:@"path"];
    _data=[aDecoder decodeObjectForKey:@"data"];

    _status=[aDecoder decodeBoolForKey:@"status"];

    _progress=[aDecoder decodeFloatForKey:@"progress"];
    _downloadSize=[aDecoder decodeFloatForKey:@"downloadSize"];
    _totalSize=[aDecoder decodeFloatForKey:@"totalSize"];


    return self;
}
/**
 快捷创建模型

 @param url 下载的url
 @param path 下载后保存在本地的地址
 @return 模型
 */
+(HGBDownLoadTask *)downLoadTaskModelWithUrl:(NSString *)url andWithPath:(NSString *)path{
    HGBDownLoadTask *model=[[HGBDownLoadTask alloc]init];
    model.url=url;
    if(path&&path!=nil){
        model.path=path;
    }
    return model;
}
/**
 将任务模型转化为字典

 @param taskModel 模型
 @return 字典
 */
+(NSDictionary *)dictionaryFromTaskModel:(HGBDownLoadTask *)taskModel{
    if(taskModel==nil){
        return nil;
    }
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    if(taskModel.id){
        [dic setObject:taskModel.id forKey:@"id"];
    }
    if(taskModel.name){
        [dic setObject:taskModel.name forKey:@"name"];
    }

    if(taskModel.groupId){
        [dic setObject:taskModel.groupId forKey:@"groupId"];
    }

    if(taskModel.url){
        [dic setObject:taskModel.url forKey:@"url"];
    }
    if(taskModel.path){
        [dic setObject:taskModel.path forKey:@"path"];
    }
    if(taskModel.data){
        [dic setObject:taskModel.data forKey:@"data"];
    }

    [dic setObject:@(taskModel.status) forKey:@"status"];


    [dic setObject:@(taskModel.progress) forKey:@"progress"];
    [dic setObject:@(taskModel.downloadSize) forKey:@"downloadSize"];
    [dic setObject:@(taskModel.totalSize) forKey:@"totalSize"];
    return dic;
}
/**
 将字典转化为任务模型

 @param dictionary 字典
 @return 模型
 */
+(HGBDownLoadTask *)taskModelFormDictionary:(NSDictionary *)dictionary{
    if(dictionary==nil){
        return nil;
    }
    HGBDownLoadTask *taskModel=[[HGBDownLoadTask alloc]init];
    if([dictionary objectForKey:@"id"]){
        taskModel.id=[dictionary objectForKey:@"id"];
    }

    if([dictionary objectForKey:@"name"]){
        taskModel.name=[dictionary objectForKey:@"name"];
    }

    if([dictionary objectForKey:@"groupId"]){
        taskModel.groupId=[dictionary objectForKey:@"groupId"];
    }

    if([dictionary objectForKey:@"url"]){
        taskModel.url=[dictionary objectForKey:@"url"];
    }
    if([dictionary objectForKey:@"path"]){
        taskModel.path=[dictionary objectForKey:@"path"];
    }
    if([dictionary objectForKey:@"data"]){
        taskModel.data=[dictionary objectForKey:@"data"];
    }


    if([dictionary objectForKey:@"status"]){
        taskModel.status=[(NSNumber *)[dictionary objectForKey:@"status"] intValue];
    }

    if([dictionary objectForKey:@"progross"]){
        taskModel.progress=[(NSNumber *)[dictionary objectForKey:@"progress"] floatValue];
    }
    if([dictionary objectForKey:@"downloadSize"]){
        taskModel.downloadSize=[(NSNumber *)[dictionary objectForKey:@"downloadSize"] floatValue];
    }
    if([dictionary objectForKey:@"totalSize"]){
        taskModel.totalSize=[(NSNumber *)[dictionary objectForKey:@"totalSize"] floatValue];
    }


    return taskModel;

}

#pragma mark 获取时间
/**
 获取时间戳-秒级

 @return 秒级时间戳
 */
-(NSString *)getSecondTimeStringSince1970
{
    NSDate* date = [NSDate date];
    NSTimeInterval interval=[date timeIntervalSince1970];  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%f", interval]; //转为字符型
    NSString *timeStr = [NSString stringWithFormat:@"%lf",[timeString doubleValue]*1000000];

    if(timeStr.length>=16){
        return [timeStr substringToIndex:16];
    }else{
        return timeStr;
    }
}
#pragma mark 沙盒
/**
 获取沙盒Document路径

 @return Document路径
 */
-(NSString *)getDocumentFilePath{
    NSString  *path_huang =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    return path_huang;
}

@end
