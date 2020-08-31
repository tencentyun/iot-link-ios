//
//  WxManager.h
//  N2D
//
//  Created by Salt on 16/5/24.
//  Copyright © 2016年 DX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WxBlock) (id obj,NSError * error);

@interface WxManager : NSObject

@property (nonatomic,copy) NSString *appID;

+ (id)sharedWxManager;
+ (BOOL)isWXAppInstalled;
- (void)registerApp;
- (BOOL)handleOpenURL:(NSURL *) url;
- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;
- (void)authFromWxComplete:(WxBlock)blk;
- (void)shareWebPageToWXSceneTimelineWithTitle:(NSString *)title
                                   description:(NSString *)description
                                    thumbImage:(UIImage*)image
                                        webUrl:(NSString *)url;  // 分享到朋友圈

- (void)shareWebPageToWXSceneSessionWithTitle:(NSString *)title
                                  description:(NSString *)description
                                   thumbImage:(UIImage*)image
                                       webUrl:(NSString *)url;   // 分享到聊天界面


/**
 分享小程序给微信好友

 @param title 小程序title
 @param description 小程序描述
 @param path 小程序页面path(可不传)
 @param webPageUrl 兼容低版本的网页链接（可不传）
 @param userName 小程序元始id（可不传，默认是小电铺）
 @param image 小程序节点高清图
 @param imageUrl 小程序节点高清图url（image为nil，将使用这个）
 @param blk 回调
 */
- (void)shareMiniProgramToWXSceneSessionWithTitle:(NSString *)title
                                      description:(NSString *)description
                                             path:(NSString *)path
                                       webpageUrl:(NSString *)webPageUrl
                                         userName:(NSString *)userName
                                       thumbImage:(UIImage*)image
                                    thumbImageUrl:(NSString *)imageUrl
                                         complete:(WxBlock)blk;// 分享到聊天界面

@end
