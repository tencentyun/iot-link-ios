//
//  TIoTChooseDelayTimeVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/3.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTChooseDelayTimeVC.h"
#import "TIoTIntelligentBottomActionView.h"
#import "TIoTAddManualIntelligentVC.h"

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
        if (self.isEditing == YES) {
            [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
            
            _bottomView.firstBlock = ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            
            _bottomView.secondBlock = ^{
                
                [weakSelf judgechoiceTime];
                
#warning 返回再刷新列表（更改时间）
            };
            
        }else {
            [_bottomView bottomViewType:IntelligentBottomViewTypeSingle withTitleArray:@[NSLocalizedString(@"confirm", @"确定")]];
            
            _bottomView.confirmBlock = ^{
                [weakSelf judgechoiceTime];
                
#warning 返回再刷新列表 （添加一个延时task）
            };
        }
        
    }
    return _bottomView;
}

- (void)judgechoiceTime {
    NSString *timeString = @"";
    
    if ([NSString isNullOrNilWithObject:self.hourString]) {
        if ([NSString isNullOrNilWithObject: self.minuteString]) {
            [MBProgressHUD showMessage:NSLocalizedString(@"error_delay_oneminute", @"延时时长至少为一分钟") icon:@""];
        }else {
            if ([self.minuteString isEqualToString:@"0分钟"]) {
                [MBProgressHUD showMessage:NSLocalizedString(@"error_delay_oneminute", @"延时时长至少为一分钟") icon:@""];
            }else {
                timeString = [NSString stringWithFormat:@"%@后",self.minuteString];
//                [self addDelayTime:timeString];
                [self addDelayTime:timeString withHour:@"0" withMinuteString:self.minuteString];
             }
        }
    }else {
        if ([self.hourString isEqualToString:@"0小时"]) {
            if ([NSString isNullOrNilWithObject:self.minuteString] || [self.minuteString isEqualToString:@"0分钟"]) {
                [MBProgressHUD showMessage:NSLocalizedString(@"error_delay_oneminute", @"延时时长至少为一分钟") icon:@""];
            }else {
                timeString = [NSString stringWithFormat:@"%@%@后",self.hourString,self.minuteString];
                [self addDelayTime:timeString withHour:self.hourString withMinuteString:self.minuteString];
            }
        }else {
            if ([NSString isNullOrNilWithObject:self.minuteString] || [self.minuteString isEqualToString:@"0分钟"]) {
                timeString = [NSString stringWithFormat:@"%@后",self.hourString];
                [self addDelayTime:timeString withHour:self.hourString withMinuteString:@"0"];
            }else {
                timeString = [NSString stringWithFormat:@"%@%@后",self.hourString,self.minuteString];
                [self addDelayTime:timeString withHour:self.hourString withMinuteString:self.minuteString];
            }
        }
    }
}

- (void)addDelayTime:(NSString *)timeStr withHour:(NSString *)hourString withMinuteString:(NSString *)min{
    
    if (self.isEditing == YES) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(changeDelayTimeString:hour:minuteString:)]) {
            [self.delegate changeDelayTimeString:timeStr?:@"" hour:hourString?:@"0" minuteString:min?:@"0"];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
        if (self.addDelayTimeBlcok) {
            self.addDelayTimeBlcok(timeStr?:@"", hourString?:@"0", min?:@"0");
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        //不用再次创建手动添加列表，返回后添加回调
        
    }
    
}
@end
