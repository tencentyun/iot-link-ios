//
// Created by Larry Tin on 2020/4/22.
// Copyright (c) 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TIoTCoreLogReport : NSObject
//通用配置参数
@property (nonatomic, strong, readonly) NSString *appId;        //腾讯云appId     基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, strong, readonly) NSString *secretId;     //腾讯云secretId  基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, strong, readonly) NSString *secretKey;    //腾讯云secretKey 基本概念见https://cloud.tencent.com/document/product/441/6194
@property (nonatomic, assign, readonly) NSInteger projectId;    //腾讯云projectId 基本概念见https://cloud.tencent.com/document/product/441/6194

/**
 * 初始化方法
 * @param appid     腾讯云appId     基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretId  腾讯云secretId  基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param secretKey 腾讯云secretKey 基本概念见https://cloud.tencent.com/document/product/441/6194
 * @param projectId 腾讯云projectId 基本概念见https://cloud.tencent.com/document/product/441/6194
 */
- (instancetype)initWithAppId:(NSString *)appid
                     secretId:(NSString *)secretId
                    secretKey:(NSString *)secretKey
                    projectId:(NSInteger)projectId;

- (void)reportCrash;

+ (NSString *)getCrashStringFromLogFile;
+ (void)deleteLogFile;
@end
