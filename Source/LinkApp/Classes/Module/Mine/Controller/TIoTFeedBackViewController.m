//
//  WCFeedBackViewController.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/18.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTFeedBackViewController.h"
#import "TZImagePickerController.h"
#import "TIoTQCloudCOSXMLManage.h"
#import <IQKeyboardManager/IQTextView.h>
#import "TIoTPhotoCell.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import "TIoTUploadObj.h"

static NSInteger maxNumber = 100;

@interface TIoTFeedBackViewController ()<UITextViewDelegate,TZImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic) CGFloat itemWidth;

@property (nonatomic, strong) UIScrollView *scView;
@property (nonatomic, strong) IQTextView *contextTV;
@property (nonatomic, strong) UITextField *contactTF;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UILabel *countLab;

@property (nonatomic, strong) TIoTQCloudCOSXMLManage *cosXml;
@property (nonatomic, strong) UIImageView *picView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation TIoTFeedBackViewController

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _itemWidth = (kScreenWidth - 40 - 15) / 4.0;
    [self setupUI];
}

#pragma mark privateMethods
- (void)setupUI{
    self.view.backgroundColor = kBgColor;
    self.title = @"意见反馈";
    
    UIScrollView *scroll = [[UIScrollView alloc] init];
    [self.view addSubview:scroll];
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(0);
    }];
    
    UIView *zw = [UIView new];
    [scroll addSubview:zw];
    [zw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.width.equalTo(scroll);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *desLab = [[UILabel alloc] init];
    desLab.text = @"意见反馈";
    desLab.textColor = kFontColor;
    desLab.font = [UIFont systemFontOfSize:16];
    [scroll addSubview:desLab];
    [desLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(scroll).offset(16);
        make.top.equalTo(scroll).offset(10);
    }];
    
    self.countLab = [[UILabel alloc] init];
    _countLab.text = [NSString stringWithFormat:@"0/%zi",maxNumber];
    _countLab.textColor = kRGBColor(187, 187, 187);
    _countLab.font = [UIFont wcPfRegularFontOfSize:14];
    [scroll addSubview:_countLab];
    [_countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(scroll).offset(-16);
        make.centerY.mas_equalTo(desLab);
    }];
    
    self.contextTV = [[IQTextView alloc] init];
    _contextTV.placeholder = @"请填写您的反馈（至少10个字）";
    self.contextTV.backgroundColor = kRGBColor(245, 245, 245);
    self.contextTV.font = [UIFont wcPfRegularFontOfSize:16];
    self.contextTV.delegate = self;
//    UILabel *placeHolderLabel = [[UILabel alloc] init];
//    placeHolderLabel.text = @"最多200个汉字";
//    placeHolderLabel.numberOfLines = 0;
//    placeHolderLabel.textColor = kRGBColor(187, 187, 187);
//    placeHolderLabel.font = [UIFont wcPfRegularFontOfSize:16];
//    [placeHolderLabel sizeToFit];
//    [self.contextTV addSubview:placeHolderLabel];
//    [self.contextTV setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    [scroll addSubview:self.contextTV];
    [self.contextTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(scroll).offset(20);
        make.trailing.equalTo(scroll).offset(-20);
        make.top.equalTo(desLab.mas_bottom).offset(20);
        make.height.mas_equalTo(180);
//        make.width.equalTo(scroll);
    }];
    
    UILabel *desLab2 = [[UILabel alloc] init];
    desLab2.text = @"相关截图";
    desLab2.textColor = kFontColor;
    desLab2.font = [UIFont systemFontOfSize:16];
    [scroll addSubview:desLab2];
    [desLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.equalTo(self.contextTV.mas_bottom).offset(20);
    }];
    
    UIView *photoView = [UIView new];
    photoView.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:photoView];
    [photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.equalTo(desLab2.mas_bottom).offset(20);
//        make.height.mas_equalTo(128);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [photoView addSubview:_collectionView];
    [_collectionView registerNib:[UINib nibWithNibName:@"TIoTPhotoCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoCell"];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.bottom.mas_equalTo(0);
        make.height.mas_equalTo(self.itemWidth);
    }];
    
//    self.picView = [[UIImageView alloc] init];
//    _picView.image = [UIImage imageNamed:@"img_add"];
//    [_picView xdp_addTarget:self action:@selector(addImage)];
//    [photoView addSubview:_picView];
//    [_picView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo((kScreenWidth - 30 - 5 * 3) / 4.0);
//        make.centerY.equalTo(photoView);
//        make.leading.mas_equalTo(15);
//    }];
    
    
    UILabel *contactTipLab = [[UILabel alloc] init];
    contactTipLab.text = @"输入有效联系方式以便开发者联系您（选填）";
    contactTipLab.textColor = kFontColor;
    contactTipLab.font = [UIFont systemFontOfSize:16];
    [scroll addSubview:contactTipLab];
    [contactTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.equalTo(photoView.mas_bottom).offset(20);
    }];
    
    
    self.contactTF = [[UITextField alloc] init];
    self.contactTF.placeholder = @"手机号码/邮箱";
    self.contactTF.backgroundColor = kRGBColor(245, 245, 245);
    self.contactTF.leftViewMode = UITextFieldViewModeAlways;
    self.contactTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    [self.contactTF addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    self.contactTF.font = [UIFont wcPfRegularFontOfSize:15];
    [scroll addSubview:self.contactTF];
    [self.contactTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(20);
        make.right.equalTo(scroll).offset(-20);
        make.top.equalTo(contactTipLab.mas_bottom).offset(20);
        make.height.mas_equalTo(48);
    }];
    
    
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.submitBtn setTitleColor:kRGBColor(153, 153, 153) forState:UIControlStateDisabled];
    self.submitBtn.titleLabel.font = [UIFont wcPfRegularFontOfSize:16];
    [self.submitBtn addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
    self.submitBtn.backgroundColor = kMainColorDisable;
    self.submitBtn.enabled = NO;
    self.submitBtn.layer.cornerRadius = 3;
    [scroll addSubview:self.submitBtn];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scroll).offset(24);
        make.top.equalTo(self.contactTF.mas_bottom).offset(60);
        make.right.equalTo(scroll).offset(-24);
        make.height.mas_equalTo(48);
        make.bottom.mas_equalTo(-60);
    }];
}

//是否可提交
- (void)checkContext{
    if (self.contextTV.hasText && self.images.count > 0) {
        self.submitBtn.backgroundColor = kMainColor;
        self.submitBtn.enabled = YES;
    }
    else{
        self.submitBtn.backgroundColor = kMainColorDisable;
        self.submitBtn.enabled = NO;
    }
}

#pragma mark - event
- (void)submitClick:(id)sender{
    
    if (_contextTV.text.length < 10) {
        [MBProgressHUD showMessage:@"反馈意见至少10个字" icon:@""];
        return;
    }
    
    if (_contactTF.text.length > 50) {
        [MBProgressHUD showMessage:@"联系方式请勿超过50字符" icon:@""];
        return;
    }
    
    [MBProgressHUD showLodingNoneEnabledInView:self.view withMessage:@""];
    
    NSMutableArray *urlArr = [NSMutableArray array];
    for (NSDictionary *dic in self.images) {
        [urlArr addObject:dic[@"url"]];
    }
    
    
    [[TIoTRequestObject shared] post:AppUserFeedBack Param:@{@"Type":@"advise",@"Desc":self.contextTV.text,@"Contact":self.contactTF.hasText ? self.contactTF.text : @"",@"LogUrl":[urlArr componentsJoinedByString:@","]} success:^(id responseObject) {
        [MBProgressHUD showSuccess:@"反馈成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        
    }];
}


- (void)addImage
{
    [self pushTZImagePickerController:4];
}

#pragma mark - other

/**
 调起相册
 
 @param maxImageCount 可选择最大张数
 */
- (void)pushTZImagePickerController:(NSInteger)maxImageCount {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxImageCount columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.naviTitleColor = [UIColor whiteColor];
    imagePickerVc.barItemTextColor = [UIColor whiteColor];
    imagePickerVc.naviBgColor = [UIColor blackColor];
//    imagePickerVc.navigationBar.translucent = NO;
    
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.cropRect = CGRectMake(0, kScreenHeight / 2 - kScreenWidth / 2, kScreenWidth, kScreenWidth);
    //    imagePickerVc.selectedAssets = self.selectedAsset;
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
//TZvc dismiss调用
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    if (photos.count > 0) {
        
        [MBProgressHUD showLodingNoneEnabledInView:nil withMessage:@""];
        WeakObj(self)
        self.cosXml = [[TIoTQCloudCOSXMLManage alloc] init];
        [self.cosXml getSignature:photos com:^(NSArray * _Nonnull reqs) {
            for (int i = 0; i < reqs.count; i ++) {
                TIoTUploadObj *obj = reqs[i];
                QCloudCOSXMLUploadObjectRequest *request = obj.req;
                [request setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
                    StrongObj(self)
                    
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (i + 1 == reqs.count) {
                                [MBProgressHUD dismissInView:selfstrong.view];
                            }
                            
                            [selfstrong.images addObject:@{@"image":obj.image,@"url":result.location}];
                            [selfstrong.collectionView reloadData];
                            
                            [selfstrong checkContext];
                        });
                        
                    }
                }];
                [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:request];
            }
            
        }];
        
    }
    
}
//点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    
    return YES;
}

// 照骗显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];
    if (str.length > maxNumber)
    {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self checkContext];
    //统计字数
    self.countLab.text = [NSString stringWithFormat:@"%zi/%zi",textView.text.length,maxNumber];
}

#pragma mark - collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.images.count == 0) {
        return 1;
    }
    else if (self.images.count > 0 && self.images.count < 4)
    {
        return self.images.count + 1;
    }
    else
    {
        return self.images.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    if (indexPath.item == self.images.count) {
        [cell setHiddenDeleteBtn:YES];
        [cell.imgView setImage:[UIImage imageNamed:@"img_add"]];
    }
    else
    {
        [cell.imgView setImage:self.images[indexPath.item][@"image"]];
        [cell setHiddenDeleteBtn:NO];
        cell.deleteTap = ^{
            [self.images removeObjectAtIndex:indexPath.item];
            [collectionView reloadData];
        };
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_itemWidth, _itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.images.count < 4 &&  indexPath.item == self.images.count) {
        [self addImage];
    }
}

//MARK: getter

- (NSMutableArray *)images
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}
@end
