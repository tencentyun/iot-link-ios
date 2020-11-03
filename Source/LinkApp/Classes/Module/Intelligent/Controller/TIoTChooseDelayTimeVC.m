//
//  TIoTChooseDelayTimeVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseDelayTimeVC.h"
#import "TIoTIntelligentBottomActionView.h"

@interface TIoTChooseDelayTimeVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSArray *pickDataArray;
@property (nonatomic, strong) NSString *hourString;
@property (nonatomic, strong) NSString *minuteString;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;

@end

@implementation TIoTChooseDelayTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI {
    
    self.title = NSLocalizedString(@"manualIntelligent_delay", @"延时");
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    [self.view addSubview:self.pickView];
    [self.pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_bottom).offset(64 + 15);
        }
    }];
    
    CGFloat kBottomHeight = 90;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kBottomHeight);
    }];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.pickDataArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSMutableArray *compoentArray = self.pickDataArray[component];
    return compoentArray.count;
}

#pragma mark - UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickDataArray[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSMutableArray *itemArray = self.pickDataArray[component];
    if (component == 0) {
        self.hourString = itemArray[row];
    }else if (component == 1){
        self.minuteString = itemArray[row];
    }
}

#pragma mark - lazy loading

- (UIPickerView *)pickView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc]init];
        _pickView.delegate = self;
        _pickView.dataSource = self;
        _pickView.showsSelectionIndicator = YES;
        _pickView.backgroundColor = [UIColor whiteColor];
    }
    return _pickView;
}

- (NSArray *)pickDataArray {
    if (!_pickDataArray) {
        NSMutableArray *hourArray = [[NSMutableArray alloc]init];
        for (int i = 0; i< 24; i++) {
            [hourArray addObject:[NSString stringWithFormat:@"%d小时",i]];
        }
        NSMutableArray *minuteArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< 60; j++) {
            [minuteArray addObject:[NSString stringWithFormat:@"%d分钟",j]];
        }
        _pickDataArray = @[hourArray,minuteArray];
    }
    return _pickDataArray;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        _bottomView.confirmBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _bottomView;
}
@end
