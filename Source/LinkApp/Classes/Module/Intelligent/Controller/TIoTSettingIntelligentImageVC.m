//
//  TIoTSettingIntelligentImageVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTSettingIntelligentImageVC.h"
#import <UIButton+WebCache.h>
#import "UIButton+LQRelayout.h"
#import "TIoTUIProxy.h"

@interface TIoTSettingIntelligentImageVC ()
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIButton *saveImageButton;
@property (nonatomic, assign) NSInteger number;
@end

@implementation TIoTSettingIntelligentImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}


- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.title = NSLocalizedString(@"choose_Intelligent_Image", @"选择智能图片");
    
    CGFloat kButtonWidth = 107 * kScreenAllWidthScale;
    CGFloat kButtonHeight = 54 * kScreenAllHeightScale;
    CGFloat kPadding = 15 * kScreenAllWidthScale;
    CGFloat kInterval = 12 * kScreenAllHeightScale;
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/c05e0ef33ff62962a089649800cd5ce9/scene1.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button1.tag = 101;
//    button1.layer.borderWidth = 2;
    [button1 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kButtonWidth);
        make.height.mas_equalTo(kButtonHeight);
        make.left.equalTo(self.view.mas_left).offset(kPadding);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(kPadding);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64*kScreenAllHeightScale + kPadding);
        }
    }];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/a699919a2d7df048757facf781f9449e/scene2.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button2.tag = 102;
//    button2.layer.borderWidth = 2;
    [button2 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1.mas_top);
        make.width.height.equalTo(button1);
        make.left.equalTo(button1.mas_right).offset(kInterval);
    }];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/41a727f20f200a1100c6e5cf7ac40088/scene3.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button3.tag = 103;
//    button3.layer.borderWidth = 2;
    [button3 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1.mas_top);
        make.width.height.equalTo(button1);
        make.left.equalTo(button2.mas_right).offset(kInterval);
    }];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/493cd8e417bb990c3662f5689bf32074/scene4.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button4.tag = 104;
//    button4.layer.borderWidth = 2;
    [button4 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    [button4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1.mas_bottom).offset(kInterval);
        make.width.height.equalTo(button1);
        make.left.equalTo(button1.mas_left);
    }];
    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button5 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/a383821b3bf8eab99ccc4e51935bbf95/scene5.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button5.tag = 105;
//    button5.layer.borderWidth = 2;
    [button5 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5];
    [button5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button4.mas_top);
        make.width.height.equalTo(button1);
        make.left.equalTo(button2.mas_left);
    }];
    
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button6 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/9c04afe82f2d18448efa45e239ee1244/scene6.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button6.tag = 106;
//    button6.layer.borderWidth = 2;
    [button6 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button6];
    [button6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button4.mas_top);
        make.width.height.equalTo(button1);
        make.left.equalTo(button3.mas_left);
    }];
    
    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button7 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/4aa0aff9c1f0f67df0d0ad7e906d736a/scene7.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button7.tag = 107;
//    button7.layer.borderWidth = 2;
    [button7 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button7];
    [button7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button4.mas_bottom).offset(kInterval);
        make.width.height.equalTo(button1);
        make.left.equalTo(button4.mas_left);
    }];
    
    UIButton *button8 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button8 sd_setImageWithURL:[NSURL URLWithString:@"https://main.qcloudimg.com/raw/0a5e2254ef293ef32a4749e77c4e73fa/scene8.jpg"] forState:UIControlStateNormal placeholderImage:nil];
    button8.tag = 108;
//    button8.layer.borderWidth = 2;
    [button8 addTarget:self action:@selector(selectedSceneBackImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button8];
    [button8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button7.mas_top);
        make.width.height.equalTo(button1);
        make.left.equalTo(button5.mas_left);
    }];
    
    self.saveImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveImageButton setButtonFormateWithTitlt:NSLocalizedString(@"save", @"保存") titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:16]];
    [self.saveImageButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    self.saveImageButton.layer.cornerRadius = 20;
    [self.saveImageButton addTarget:self action:@selector(saveSelectedImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveImageButton];
    [self.saveImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(40);
        
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(-20);
            }
        }else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }
    }];
    
}

- (void)selectedSceneBackImage:(UIButton *)sender {
    for (int i = 101; i<109; i++) {
        if (sender.tag == i) {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i];
            btn.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
            btn.layer.borderWidth = 2;
        }else {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i];
            btn.layer.borderColor = [UIColor clearColor].CGColor;
            btn.layer.borderWidth = 0.0;
        }
    }
    
     self.number = sender.tag -101;
    
}

- (void)saveSelectedImage {
    
    if (self.selectedIntelligentImageBlock) {
        
        self.selectedIntelligentImageBlock(self.imageArray[self.number]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)imageArray{
    if (!_imageArray) {
        _imageArray = @[@"https://main.qcloudimg.com/raw/c05e0ef33ff62962a089649800cd5ce9/scene1.jpg",
                        @"https://main.qcloudimg.com/raw/a699919a2d7df048757facf781f9449e/scene2.jpg",
                        @"https://main.qcloudimg.com/raw/41a727f20f200a1100c6e5cf7ac40088/scene3.jpg",
                        @"https://main.qcloudimg.com/raw/493cd8e417bb990c3662f5689bf32074/scene4.jpg",
                        @"https://main.qcloudimg.com/raw/a383821b3bf8eab99ccc4e51935bbf95/scene5.jpg",
                        @"https://main.qcloudimg.com/raw/9c04afe82f2d18448efa45e239ee1244/scene6.jpg",
                        @"https://main.qcloudimg.com/raw/4aa0aff9c1f0f67df0d0ad7e906d736a/scene7.jpg",
                        @"https://main.qcloudimg.com/raw/0a5e2254ef293ef32a4749e77c4e73fa/scene8.jpg"];
    }
    return _imageArray;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
