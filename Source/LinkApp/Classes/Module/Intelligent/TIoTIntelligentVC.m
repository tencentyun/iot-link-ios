//
//  TIoTIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTIntelligentVC.h"
#import "TIoTAddManualIntelligentVC.h"

@interface TIoTIntelligentVC ()
@property  (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *noIntelligentTipLabel;
@property (nonatomic, strong) UIButton *addIntelligentButton;
@end

@implementation TIoTIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}


- (void)setupUI {
    [self addEmptyIntelligentDeviceTipView];
}


- (void)addEmptyIntelligentDeviceTipView {
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
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
- (void)addIntelligentDevice {
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
