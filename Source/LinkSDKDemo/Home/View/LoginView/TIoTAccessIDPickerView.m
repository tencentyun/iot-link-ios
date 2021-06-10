//
//  TIoTAccessIDPickerView.m
//  LinkApp
//
//

#import "TIoTAccessIDPickerView.h"
#import "UIView+TIoTViewExtension.h"

@interface TIoTAccessIDPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *holdBackgroundView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) NSString *chooseID;
@end


@implementation TIoTAccessIDPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPickerUI];
        [self initVariable];
    }
    return self;
}

- (void)setupPickerUI {
    
    CGFloat kSafeBottomHeight = 34;
    CGFloat kControlViewHeight = 60;
    CGFloat kTopAreaHeight = 256;
    CGFloat kHoldViewHeight = kSafeBottomHeight+kControlViewHeight+kTopAreaHeight;
    CGFloat kHoldTopInterval = 20;
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
    }];
    
    //白色显示区域底层view
    UIView *holdBackgroundView = [[UIView alloc]init];
    holdBackgroundView.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:holdBackgroundView];
    [holdBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(bottomView);
        make.height.mas_equalTo(kHoldViewHeight);
    }];
    
    [self changeViewRectConnerWithView:holdBackgroundView withRect:CGRectMake(0, 0, kScreenWidth, kHoldViewHeight) roundCorner:UIRectCornerTopLeft|UIRectCornerTopRight withRadius:CGSizeMake(12, 12)];
    
    UIButton *tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tapBtn.backgroundColor = [UIColor clearColor];
    [tapBtn addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:tapBtn];
    [tapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(bottomView);
        make.bottom.equalTo(holdBackgroundView.mas_top);
    }];

    self.pickerView = [[UIPickerView alloc]init];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [holdBackgroundView addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(holdBackgroundView);
        make.top.equalTo(holdBackgroundView.mas_top).offset(kHoldTopInterval);
        make.height.mas_equalTo(kTopAreaHeight - kHoldTopInterval);
    }];
    
    // 取消、确认底层view
    UIView *controlView = [[UIView alloc]init];
    controlView.backgroundColor = [UIColor whiteColor];
    [holdBackgroundView addSubview:controlView];
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomView);
        make.bottom.equalTo(bottomView.mas_bottom).offset(-kSafeBottomHeight);
        make.height.mas_equalTo(kControlViewHeight);
    }];
    
    CGFloat kWidthPadding = 28;
    CGFloat kBtnWidth = (kScreenWidth - 3*kWidthPadding)/2;
    CGFloat kBtnHeight = 45;
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setButtonFormateWithTitlt:@"取消" titleColorHexString:kVideoDemoMainThemeColor font:[UIFont wcPfRegularFontOfSize:17]];
    self.cancelBtn.layer.borderColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor].CGColor;
    self.cancelBtn.layer.borderWidth = 1;
    [self.cancelBtn addTarget:self action:@selector(cancelChooseAccessID) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controlView);
        make.width.mas_equalTo(kBtnWidth);
        make.height.mas_equalTo(kBtnHeight);
        make.left.equalTo(controlView.mas_left).offset(kWidthPadding);
    }];
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmBtn setButtonFormateWithTitlt:@"确认" titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:17]];
    self.confirmBtn.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
    self.confirmBtn.layer.borderColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor].CGColor;
    self.confirmBtn.layer.borderWidth = 1;
    [self.confirmBtn addTarget:self action:@selector(confirmChooseAccessID) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cancelBtn);
        make.width.height.equalTo(self.cancelBtn);
        make.right.equalTo(controlView.mas_right).offset(-kWidthPadding);
    }];
    
}

- (void)initVariable {
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    NSMutableArray *accessIDArray = [defaluts objectForKey:@"AccessIDArrayKey"];
    if (accessIDArray != nil) {
        self.dataArray = [NSMutableArray arrayWithArray:accessIDArray];
        [self.pickerView reloadAllComponents];
        if (accessIDArray.count != 0) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
            self.chooseID = self.dataArray[0];
        }
    }
    
    
}

- (void)cancelChooseAccessID {
    [self removeView];
}

- (void)confirmChooseAccessID {
    if (self.accessIDStringBlock) {
        self.accessIDStringBlock(self.chooseID);
    }
    [self removeView];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArray.count;
}

#pragma mark - UIPickerViewDelegate

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.dataArray[row] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#15161A"],NSFontAttributeName:[UIFont wcPfRegularFontOfSize:15]}];
    return attributedString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 48;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.chooseID = self.dataArray[row];
}

- (void)removeView {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
