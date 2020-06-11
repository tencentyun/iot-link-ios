//
//  WCQCloudCOSXMLManage.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/9.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTQCloudCOSXMLManage.h"

#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCore/QCloudCore.h>
#import "TIoTUploadObj.h"

@interface TIoTQCloudCOSXMLManage ()<QCloudSignatureProvider>

@property (nonatomic, copy) NSDictionary *signatureDic;

@end

@implementation TIoTQCloudCOSXMLManage

- (void)registerQCloudCOSXML:(NSString *)regionName appID:(NSString *)bucket{
    NSArray *array = [bucket componentsSeparatedByString:@"-"];
    
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = [array lastObject];
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = regionName;//服务地域名称，可用的地域请参考注释
    endpoint.serviceName = [NSString stringWithFormat:@"%@/%@",endpoint.serviceName,self.signatureDic[@"cosConfig"][@"path"]];
    endpoint.useHTTPS = YES;
    configuration.endpoint = endpoint;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
}

- (void)signatureWithFields:(QCloudSignatureFields*)fileds         request:(QCloudBizHTTPRequest*)request urlRequest:(NSURLRequest*)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock{
    //实现签名的过程，我们推荐在服务器端实现签名的过程，具体请参考接下来的 “生成签名” 这一章。
    
    NSTimeInterval timeInterval=[self.signatureDic[@"credentials"][@"startTime"] doubleValue];

    NSDate *UTCDate=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = self.signatureDic[@"credentials"][@"tmpSecretId"];
    credential.secretKey = self.signatureDic[@"credentials"][@"tmpSecretKey"];
    credential.token = self.signatureDic[@"credentials"][@"sessionToken"];
    credential.startDate = UTCDate;
    credential.experationDate = [NSDate dateWithTimeIntervalSince1970:[self.signatureDic[@"credentials"][@"expiredTime"] doubleValue]];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature = [creator signatureForData:(NSMutableURLRequest *)urlRequst];
    continueBlock(signature, nil);
}

- (QCloudCOSXMLUploadObjectRequest *)uploadImage:(UIImage *)image{
    NSString* tempPath = QCloudTempFilePathWithExtension(@"jpg");
    [UIImageJPEGRepresentation(image, 0.3) writeToFile:tempPath atomically:YES];

    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest new];
    
    upload.body = [NSURL fileURLWithPath:tempPath];
    upload.bucket = self.signatureDic[@"cosConfig"][@"bucket"];
    upload.object = [NSString stringWithFormat:@"%@.jpg",[NSUUID UUID].UUIDString];
    
    [upload setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {

    }];
    
    return upload;

}

//获取签名数据
- (void)getSignature:(NSArray<UIImage *> *)images com:(ggBlock)block{
    
    NSMutableArray *reqArr = [NSMutableArray array];
    
    [[TIoTRequestObject shared] getSigForUpload:AppCosAuth Param:@{@"path":@"iotexplorer-app-logs/user_{uin}/"} success:^(id responseObject) {
        self.signatureDic = responseObject;
        [self registerQCloudCOSXML:self.signatureDic[@"cosConfig"][@"region"] appID:self.signatureDic[@"cosConfig"][@"bucket"]];
        
        for (UIImage *image in images) {
            TIoTUploadObj *obj = [TIoTUploadObj new];
            obj.image = image;
            obj.req = [self uploadImage:image];
            [reqArr addObject: obj];
        }
        
        block(reqArr);
    } failure:^(NSString *reason, NSError *error) {
        
    }];
}

- (void) uploadFileByRequest:(QCloudCOSXMLUploadObjectRequest*)upload
{
    
//    @weakify(self);
//    [upload setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
//        @strongify(self);
//        self.uploadRequest = nil;
//
//        if (self.upload) {
//            self.upload(error, result.location);
//        }
//    }];
    
    
    
}


@end
