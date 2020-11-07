//
//  TIoTIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentVC.h"
#import "TIoTAddManualIntelligentVC.h"
#import "UILabel+TIoTExtension.h"
#import "TIoTCustomSheetView.h"
#import "TIoTChooseIntelligentDeviceVC.h"
#import "TIoTChooseDelayTimeVC.h"

@interface TIoTIntelligentVC ()
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelligentTipLabel;
@property (nonatomic, strong) UIButton *addIntelligentButton;
@property (nonatomic, strong) UIView *navCustomTopView;
@property (nonatomic, strong) TIoTCustomSheetView *customSheet;
@end

@implementation TIoTIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navCustomTopView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navCustomTopView.hidden = YES;
    if (self.customSheet) {
        [self.customSheet removeFromSuperview];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

- (void)setupUI {
    
    [self addEmptyIntelligentDeviceTipView];
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.navCustomTopView];
}


- (void)addEmptyIntelligentDeviceTipView {
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            CGFloat kHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
            make.centerY.equalTo(self.view.mas_centerY).offset(-kHeight);
        } else {
            // Fallback on earlier versions
        }
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.height.mas_equalTo(160);
    }];
    
    [self.view addSubview:self.noIntelligentTipLabel];
    [self.noIntelligentTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.addIntelligentButton];
    [self.addIntelligentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noIntelligentTipLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(36);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - event

- (void)addClick {
    self.customSheet = [[TIoTCustomSheetView alloc]init];
    __weak typeof(self)weakSelf = self;
    self.customSheet.chooseIntelligentDeviceBlock = ^{
        TIoTChooseIntelligentDeviceVC *chooseDeviceVC = [[TIoTChooseIntelligentDeviceVC alloc]init];
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }
        [weakSelf.navigationController pushViewController:chooseDeviceVC animated:YES];
    };
    self.customSheet.chooseDelayTimerBlock = ^{
        TIoTChooseDelayTimeVC *delayTimeVC = [[TIoTChooseDelayTimeVC alloc]init];
        delayTimeVC.isEditing = NO;
        if (weakSelf.customSheet) {
            [weakSelf.customSheet removeFromSuperview];
        }
        [weakSelf.navigationController pushViewController:delayTimeVC animated:YES];
    };
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.customSheet];
    [self.customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([UIApplication sharedApplication].delegate.window);
        make.leading.right.bottom.equalTo(weakSelf.view);
    }];
}

- (void)addIntelligentDevice {
#warning 刷新手动添加智能tableView
    TIoTAddManualIntelligentVC *addManualTask = [[TIoTAddManualIntelligentVC alloc]init];
    [self.navigationController pushViewController:addManualTask animated:YES];
}

#pragma mark - lazy loading
- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_placeHold"]];
    }
    return _emptyImageView;
}

- (UILabel *)noIntelligentTipLabel {
    if (!_noIntelligentTipLabel) {
        _noIntelligentTipLabel = [[UILabel alloc]init];
        _noIntelligentTipLabel.text = NSLocalizedString(@"intelligent_noDeviceTip", @"当前暂无智能，点击添加智能");
        _noIntelligentTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noIntelligentTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noIntelligentTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noIntelligentTipLabel;
}

- (UIButton *)addIntelligentButton {
    if (!_addIntelligentButton) {
        _addIntelligentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addIntelligentButton.layer.borderWidth = 1;
        _addIntelligentButton.layer.borderColor = [UIColor colorWithHexString:@"#0066FF"].CGColor;
        _addIntelligentButton.layer.cornerRadius = 18;
        [_addIntelligentButton setTitle:NSLocalizedString(@"addDeveice_immediately", @"立即添加") forState:UIControlStateNormal];
        [_addIntelligentButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _addIntelligentButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_addIntelligentButton addTarget:self action:@selector(addIntelligentDevice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addIntelligentButton;
}

- (UIView *)navCustomTopView {
    if (!_navCustomTopView) {
        
        CGFloat kTopHeight = [TIoTUIProxy shareUIProxy].statusHeight;
        
        _navCustomTopView = [[UIView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, [TIoTUIProxy shareUIProxy].navigationBarHeight - [TIoTUIProxy shareUIProxy].statusHeight)];
        
        UIButton *addActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addActionButton setImage:[UIImage imageNamed:@"addManual_Intelligent"] forState:UIControlStateNormal];
        [addActionButton addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
        [_navCustomTopView addSubview:addActionButton];
        [addActionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-15*kScreenAllWidthScale);
            make.centerY.equalTo(_navCustomTopView.mas_centerY);
            make.width.height.mas_equalTo(22);
        }];
        
        
        UILabel *titleLab = [[UILabel alloc] init];
        [titleLab setLabelFormateTitle:NSLocalizedString(@"home_intelligent", @"智能") font:[UIFont wcPfMediumFontOfSize:17] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
        [_navCustomTopView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.centerX.equalTo(_navCustomTopView);
            make.height.mas_equalTo(kTopHeight);
            make.top.equalTo(_navCustomTopView.mas_top);
        }];
        
        _navCustomTopView.backgroundColor = [UIColor whiteColor];
        
    }
    return  _navCustomTopView;
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
