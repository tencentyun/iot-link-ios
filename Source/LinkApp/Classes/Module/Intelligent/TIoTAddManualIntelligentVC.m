//
//  TIoTAddManualIntelligentVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/2.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAddManualIntelligentVC.h"
#import "TIoTCustomSheetView.h"

@interface TIoTAddManualIntelligentVC ()
@property  (nonatomic, strong) UIImageView *noManualTaskImageView;
@property (nonatomic, strong) UILabel *noManualTaskTipLabel;
@property (nonatomic, strong) UIButton *addManualTaskButton;
@end

@implementation TIoTAddManualIntelligentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {

    self.title = NSLocalizedString(@"addManualTask", @"添加手动智能");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self addEmptyIntelligentDeviceTipView];
}


- (void)addEmptyIntelligentDeviceTipView {
    [self.view addSubview:self.noManualTaskImageView];
    [self.noManualTaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
        make.height.mas_equalTo(160);
    }];
    
    [self.view addSubview:self.noManualTaskTipLabel];
    [self.noManualTaskTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noManualTaskImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [self.view addSubview:self.addManualTaskButton];
    [self.addManualTaskButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noManualTaskTipLabel.mas_bottom).offset(20);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(36);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - event
- (void)addManualTask {
    TIoTCustomSheetView *customSheet = [[TIoTCustomSheetView alloc]init];
    [[UIApplication sharedApplication].delegate.window addSubview:customSheet];
    [customSheet mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (@available(iOS 11.0, *)) {
//            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
//        }else {
//            make.top.equalTo(self.view.mas_top).offset(64 * kScreenAllHeightScale);
//        }
        make.top.equalTo([UIApplication sharedApplication].keyWindow);
        make.leading.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - lazy loading
- (UIImageView *)noManualTaskImageView {
    if (!_noManualTaskImageView) {
        _noManualTaskImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty_noTask"]];
    }
    return _noManualTaskImageView;
}

- (UILabel *)noManualTaskTipLabel {
    if (!_noManualTaskTipLabel) {
        _noManualTaskTipLabel = [[UILabel alloc]init];
        _noManualTaskTipLabel.text = NSLocalizedString(@"current_noManualTask", @"暂无手动任务");
        _noManualTaskTipLabel.font = [UIFont wcPfRegularFontOfSize:14];
        _noManualTaskTipLabel.textColor= [UIColor colorWithHexString:@"#6C7078"];
        _noManualTaskTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noManualTaskTipLabel;
}

- (UIButton *)addManualTaskButton {
    if (!_addManualTaskButton) {
        _addManualTaskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addManualTaskButton.layer.borderWidth = 1;
        _addManualTaskButton.layer.borderColor = [UIColor colorWithHexString:@"#0066FF"].CGColor;
        _addManualTaskButton.layer.cornerRadius = 18;
        [_addManualTaskButton setTitle:NSLocalizedString(@"addTast", @"添加任务") forState:UIControlStateNormal];
        [_addManualTaskButton setTitleColor:[UIColor colorWithHexString:kIntelligentMainHexColor] forState:UIControlStateNormal];
        _addManualTaskButton.titleLabel.font = [UIFont wcPfRegularFontOfSize:14];
        [_addManualTaskButton addTarget:self action:@selector(addManualTask) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addManualTaskButton;
}

@end
