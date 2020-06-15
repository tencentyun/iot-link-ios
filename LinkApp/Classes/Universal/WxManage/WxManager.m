//
//  WxManager.m
//  N2D
//
//  Created by Salt on 16/5/24.
//  Copyright © 2016年 DX. All rights reserved.
//

#import "WxManager.h"
#import "WXApi.h"
#import "TIoTAppEnvironment.h"

#define WxAppID     @"wxfb36c49df3a370c7"
#define WxAppSecret @"e2002b0bb99f7484ca7c416b63507662"
#define WxManagerError @"WxManagerError"

//////bundleId com.tencent.cloudiot   com.Tenext.TenextCloud

@interface WxManager()<WXApiDelegate>

@property (nonatomic,copy)WxBlock authBlk;
@property (nonatomic,copy)WxBlock payBlk;
@property (nonatomic,copy)WxBlock shareBlk;

@end

@implementation WxManager

+ (id)sharedWxManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[WxManager alloc] init];
    });
    return _sharedObject;
}

+ (BOOL)isWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

- (void)registerApp
{
    [WXApi registerApp:WxAppID];
}


- (BOOL)handleOpenURL:(NSURL *) url
{
    return [WXApi handleOpenURL:url delegate:self];
}


- (void)authFromWxComplete:(WxBlock)blk
{
    if (blk) {

        self.authBlk = blk;
    }
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"app";
        [WXApi sendReq:req];
    }
    else {
        [MBProgressHUD showError:@"未安装微信或版本过低"];
    }
}

- (void)requestWxInfoWitAuthResp:(BaseResp *)resp
{
    SendAuthResp *aresp = (SendAuthResp *)resp;
    if (aresp.errCode != WXSuccess)
    {
        if (self.authBlk) {
            NSError  * error   = nil;
            error = [NSError errorWithDomain:WxManagerError code:aresp.errCode userInfo:@{NSLocalizedDescriptionKey : aresp.errStr?aresp.errStr:[self errorReason:aresp.errCode]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.authBlk(nil,error);
            });
            [MBProgressHUD showError:[self errorReason:aresp.errCode] toView:nil];
        }
    }else {
        NSString * code = aresp.code;
        if (code.length > 0) {
            
            if (self.authBlk) {
                self.authBlk(code, nil);
            }
        }
        else{
            NSError  * error   = nil;
            error = [NSError errorWithDomain:WxManagerError code:aresp.errCode userInfo:@{NSLocalizedDescriptionKey : aresp.errStr?aresp.errStr:[self errorReason:aresp.errCode]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.authBlk(nil,error);
            });
        }
    }
}


- (void)payFromWx:(NSDictionary *)payInfo complete:(WxBlock)blk
{
    if (blk) {
        self.payBlk = blk;
    }
    
    if (payInfo.count != 0) {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
            PayReq *req = [[PayReq alloc] init];
            req.partnerId = payInfo[@"partnerId"];
            req.prepayId  = payInfo[@"prePayId"];
            req.package   = @"Sign=WXPay";
            req.nonceStr  = payInfo[@"nonceStr"];
            req.timeStamp = [payInfo[@"timeStamp"] intValue];
            req.sign      = payInfo[@"paySign"];
            [WXApi sendReq:req];
        }
        else {
            [MBProgressHUD showError:@"未安装微信或版本过低"];
        }
    }
}


- (void)shareWebPageToWXSceneTimelineWithTitle:(NSString *)title
                                   description:(NSString *)description
                                    thumbImage:(UIImage*)image
                                        webUrl:(NSString *)url  // 分享到朋友圈
{
    WXMediaMessage * message = [WXMediaMessage message];
    message.title = title?title:@"";
    message.description = description?description:@"";
    if (image) {
        [message setThumbImage:image];
    }
    WXWebpageObject * webPage = [WXWebpageObject object];
    webPage.webpageUrl = url;
    message.mediaObject = webPage;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
}


- (void)shareWebPageToWXSceneSessionWithTitle:(NSString *)title
                                  description:(NSString *)description
                                   thumbImage:(UIImage*)image
                                       webUrl:(NSString *)url   // 分享到聊天界面
{
    WXMediaMessage * message = [WXMediaMessage message];
    message.title = title?title:@"";
    message.description = description?description:@"";
    if (image) {
        [message setThumbImage:image];
    }
    WXWebpageObject * webPage = [WXWebpageObject object];
    webPage.webpageUrl = url;
    message.mediaObject = webPage;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

- (void)shareMiniProgramToWXSceneSessionWithTitle:(NSString *)title
                                      description:(NSString *)description
                                             path:(NSString *)path
                                       webpageUrl:(NSString *)webPageUrl
                                         userName:(NSString *)userName
                                       thumbImage:(UIImage*)image
                                    thumbImageUrl:(NSString *)imageUrl
                                         complete:(WxBlock)blk{
    if (blk) {
        self.shareBlk = blk;
    }
    
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    if (webPageUrl.length == 0) {
        object.webpageUrl = @"";
    }
    else{
        object.webpageUrl = webPageUrl;
    }
    
    if (path.length == 0) {
        object.path = @"/pages/index/index";
    }
    else{
        object.path = path;
    }
    
    if (userName.length == 0) {
//        object.userName = [WCAppEnvironment shareEnvironment].microProgramId;
    }
    else{
        object.userName = userName;
    }

    object.miniProgramType = [TIoTAppEnvironment shareEnvironment].wxShareType;;
    
    if (image == nil) {

    }
    else{
        object.hdImageData = [self compressQualityWithLengthLimit:120*1024 image:image];
        [self shareMiniProgramToWXSceneSessionWithTitle:title description:description miniProgramObject:object];
    }
    
}

- (void)shareMiniProgramToWXSceneSessionWithTitle:(NSString *)title description:(NSString *)description miniProgramObject:(WXMiniProgramObject *)object{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    message.mediaObject = object;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;  //目前只支持会话
    [WXApi sendReq:req];
}

- (NSData *)compressQualityWithLengthLimit:(NSInteger)maxLength image:(UIImage *)image{
    NSData *tmpdata = UIImageJPEGRepresentation(image, 1);
    if (tmpdata.length < maxLength) return tmpdata;
 
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

#pragma mark Delegate
-(void) onReq:(BaseReq*)req
{
    WCLog(@"发送");
}

-(void) onResp:(BaseResp*)resp
{
    // 授权
    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
    {
        [self requestWxInfoWitAuthResp:resp];
    }
    // 支付
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp*response=(PayResp*)resp;
        if (response.errCode == WXSuccess) {
            if (self.payBlk) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.payBlk(nil,nil); // 支付成功
                });
            }
        }else {
            if (self.payBlk) {
                NSError  * error   = nil;
                int errCode = response.errCode;
                NSString * errStr = [self errorReason:errCode];
                [MBProgressHUD showError:errStr];
                error = [NSError errorWithDomain:WxManagerError code:errCode userInfo:@{NSLocalizedDescriptionKey : errStr}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.payBlk(nil,error); // 失败
                    });
            }
        }
    }
    // 分享
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {  // 分享
        SendMessageToWXResp*response=(SendMessageToWXResp*)resp;
        if (response.errCode == WXSuccess) {
            [MBProgressHUD showSuccess:@"分享成功"];
            if (self.shareBlk) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.shareBlk(nil,nil);
                });
            }
        }else {
            NSError  * error   = nil;
            int errCode = response.errCode;
            NSString * errStr = [self errorReason:errCode];
            error = [NSError errorWithDomain:WxManagerError code:errCode userInfo:@{NSLocalizedDescriptionKey : errStr}];
            [MBProgressHUD showError:errStr];
            if (self.shareBlk) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.payBlk(nil,error);
                });
            }
        }
    }
}


- (NSString *)errorReason:(int)code
{
    int errCode = code;
    NSString * errStr = @"";
    switch (errCode) {
        case WXErrCodeCommon:
            errStr = @"普通错误类型";
            break;
        case WXErrCodeUserCancel:
            errStr = @"取消微信操作";
            break;
        case WXErrCodeSentFail:
            errStr = @"发送失败";
            break;
        case WXErrCodeAuthDeny:
            errStr = @"授权失败";
            break;
        case WXErrCodeUnsupport:
            errStr = @"微信不支持";
            break;
        default:
            errStr = @"未知错误";
            break;
    }
    return errStr;
}

@end
