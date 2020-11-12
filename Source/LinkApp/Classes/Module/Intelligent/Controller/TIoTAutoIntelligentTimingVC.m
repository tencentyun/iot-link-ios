//
//  TIoTAutoIntelligentTimingVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoIntelligentTimingVC.h"
#import "TIoTIntelligentBottomActionView.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAutoIntelligentTimingVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, strong) NSArray *pickDataArray;
@property (nonatomic, strong) NSString *hourString;
@property (nonatomic, strong) NSString *minuteString;

@property (nonatomic, strong) UIButton *repeatingTimeButton;
@property (nonatomic, strong) UILabel *timingLabel;
@property (nonatomic, strong) TIoTIntelligentBottomActionView *bottomView;
@end

@implementation TIoTAutoIntelligentTimingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    
    self.title = NSLocalizedString(@"auto_timer", @"定时");
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
    
    self.repeatingTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.repeatingTimeButton setBackgroundColor:[UIColor whiteColor]];
    [self.repeatingTimeButton addTarget:self action:@selector(setRepeatTiming) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.repeatingTimeButton];
    [self.repeatingTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pickView.mas_bottom).offset(15);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(48);
    }];
    
    CGFloat kPadding = 16;
    
    UILabel *repeatLabel = [[UILabel alloc]init];
    [repeatLabel setLabelFormateTitle:NSLocalizedString(@"autoIntellignt_repeat", @"重复") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.repeatingTimeButton addSubview:repeatLabel];
    [repeatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.repeatingTimeButton.mas_left).offset(kPadding);
        make.centerY.equalTo(self.repeatingTimeButton.mas_centerY);
    }];
    
    UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mineArrow"]];
    [self.repeatingTimeButton addSubview:arrowImage];
    [arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(18);
        make.right.equalTo(self.repeatingTimeButton.mas_right).offset(-kPadding);
        make.centerY.equalTo(self.repeatingTimeButton.mas_centerY);
    }];
    
    self.timingLabel = [[UILabel alloc]init];
    [self.timingLabel setLabelFormateTitle:NSLocalizedString(@"auto_repeatTiming_once", @"执行一次") font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentRight];
    [self.repeatingTimeButton addSubview:self.timingLabel];
    [self.timingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(arrowImage.mas_left).offset(-8);
        make.centerY.equalTo(self.repeatingTimeButton.mas_centerY);
    }];
}

#pragma mark - event
- (void)setRepeatTiming {
    
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
            [hourArray addObject:[NSString stringWithFormat:@"%d%@",i,NSLocalizedString(@"auto_hour", @"时")]];
        }
        NSMutableArray *minuteArray = [[NSMutableArray alloc]init];
        for (int j = 0; j< 60; j++) {
            [minuteArray addObject:[NSString stringWithFormat:@"%d%@",j,NSLocalizedString(@"auto_minute", @"分")]];
        }
        _pickDataArray = @[hourArray,minuteArray];
    }
    return _pickDataArray;
}

- (TIoTIntelligentBottomActionView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[TIoTIntelligentBottomActionView alloc]init];
        __weak typeof(self)weakSelf = self;
        [_bottomView bottomViewType:IntelligentBottomViewTypeDouble withTitleArray:@[NSLocalizedString(@"cancel", @"取消"),NSLocalizedString(@"save", @"保存")]];
        
        _bottomView.firstBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        _bottomView.secondBlock = ^{
#warning 返回再刷新列表（更改时间）
//            [weakSelf judgechoiceTime];
            
        };

        
    }
    return _bottomView;
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
