//
//  UserInfoVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/4.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "UserInfoVC.h"
#import <QCFoundation/QCUserManage.h>
#import <UIImageView+WebCache.h>


#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCore/QCloudCore.h>


 

@interface UserInfoVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,QCloudSignatureProvider>
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UILabel *nick;
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (nonatomic, copy) NSDictionary *signatureInfo;
@end

@implementation UserInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [[QCAccountSet shared] getUserInfoOnSuccess:^(id  _Nonnull responseObject) {
        
        self.nick.text = [QCUserManage shared].nickName;
        self.phoneNum.text = [QCUserManage shared].phoneNumber;
        [self.header sd_setImageWithURL:[NSURL URLWithString:[QCUserManage shared].avatar]];
        NSLog(@"头像==%@",[QCUserManage shared].avatar);
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
//    获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    [[QCAccountSet shared] getUploadInfoOnSuccess:^(id  _Nonnull responseObject) {
        
        self.signatureInfo = responseObject;
        
        NSString *region = responseObject[@"cosConfig"][@"region"];
        NSString *bucket = responseObject[@"cosConfig"][@"bucket"];
        NSString *path = responseObject[@"cosConfig"][@"path"];
        
        [self configWithRegion:region bucket:bucket path:path];
        QCloudCOSXMLUploadObjectRequest *request = [self getRequestObject:image bucket:bucket];
        
        [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [MBProgressHUD showError:@"上传失败" toView:self.view];
                }
                else
                {
                    [MBProgressHUD dismissInView:self.view];
                    self.header.image = image;
                    
                    [[QCAccountSet shared] updateUserWithNickName:@"" avatar:result.location success:^(id  _Nonnull responseObject) {
                        [MBProgressHUD showSuccess:@"修改成功"];
                    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
                        
                    }];
                    
                }
            });
            
        }];
        
        [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
        
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}

//按取消按钮时候的功能
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    返回
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 上传头像

- (IBAction)headerTap:(id)sender {
    [self showActionSheet];
}

- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.delegate = self;
        _picker.allowsEditing = YES;
    }
    return _picker;
}

//选择获取图片方式
- (void)showActionSheet{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSystemPhotoOrCamara:YES];
    }];
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSystemPhotoOrCamara:NO];
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:camera];
    [alert addAction:photo];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}

//打开系统相册
- (void)openSystemPhotoOrCamara:(BOOL)isCamara{
    if (isCamara) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            [MBProgressHUD showError:@"相机打开失败"];
            return;
        }
    }
    else{
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    [self presentViewController:self.picker animated:YES completion:nil];
}


- (void)configWithRegion:(NSString *)regionName bucket:(NSString *)bucket path:(NSString *)path{
    NSArray *array = [bucket componentsSeparatedByString:@"-"];
    
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = [array lastObject];
    configuration.signatureProvider = self;
    
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = regionName;//服务地域名称，可用的地域请参考注释
    endpoint.serviceName = [NSString stringWithFormat:@"%@/%@",endpoint.serviceName,path];
    configuration.endpoint = endpoint;
    
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
}

- (QCloudCOSXMLUploadObjectRequest *)getRequestObject:(UIImage *)image bucket:(NSString *)bucket {
    NSString* tempPath = QCloudTempFilePathWithExtension(@"jpg");
    [UIImageJPEGRepresentation(image, 0.3) writeToFile:tempPath atomically:YES];

    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest new];
    
    upload.body = [NSURL fileURLWithPath:tempPath];
    upload.bucket = bucket;
    upload.object = [NSUUID UUID].UUIDString;
    
    [upload setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {

    }];
    
    return upload;
}

//QCloudSignatureProvider
- (void)signatureWithFields:(QCloudSignatureFields*)fileds request:(QCloudBizHTTPRequest*)request urlRequest:(NSURLRequest*)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock{
    //实现签名的过程，我们推荐在服务器端实现签名的过程，具体请参考接下来的 “生成签名” 这一章。
    
    NSTimeInterval timeInterval=[self.signatureInfo[@"credentials"][@"startTime"] doubleValue];

    NSDate *UTCDate=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = self.signatureInfo[@"credentials"][@"tmpSecretId"];
    credential.secretKey = self.signatureInfo[@"credentials"][@"tmpSecretKey"];
    credential.token = self.signatureInfo[@"credentials"][@"sessionToken"];
    credential.startDate = UTCDate;
    credential.experationDate = [NSDate dateWithTimeIntervalSince1970:[self.signatureInfo[@"credentials"][@"expiredTime"] doubleValue]];
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature = [creator signatureForData:(NSMutableURLRequest *)urlRequst];
    continueBlock(signature, nil);
}


#pragma mark - 退出登录

- (IBAction)signOut:(id)sender {
    [[QCAccountSet shared] signOutOnSuccess:^(id  _Nonnull responseObject) {
        [UIApplication sharedApplication].keyWindow.rootViewController = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"LoginVC") new]];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
        
    }];
}


@end
