//
//  WCStringView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/10/28.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTStringView.h"

@interface TIoTStringView ()<UIGestureRecognizerDelegate,UITextViewDelegate>

@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) NSUInteger maxNumber;

@end

@implementation TIoTStringView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)setupUI{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.backgroundColor = kRGBAColor(0, 0, 0, 0.7);
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self addGestureRecognizer:singleFingerOne];
    
    
    self.whiteView = [[UIView alloc] init];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(219);
        make.bottom.equalTo(self);
    }];
    
    [self layoutIfNeeded];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.whiteView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20,20)];
    //创建 layer
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.whiteView.bounds;
    //赋值
    maskLayer.path = maskPath.CGPath;
    self.whiteView.layer.mask = maskLayer;
    
//    self.titleLab = [[UILabel alloc] init];
//    self.titleLab.textColor = kRGBColor(51, 51, 51);
//    self.titleLab.font = [UIFont wcPfSemiboldFontOfSize:18];
//    [self.whiteView addSubview:self.titleLab];
//    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.equalTo(self.whiteView).offset(20);
//    }];
    UIButton *cancelB = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelB setTitle:NSLocalizedString(@"cancel", @"取消") forState:UIControlStateNormal];
    [cancelB setTitleColor:kMainColor forState:UIControlStateNormal];
    [cancelB addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [cancelB.titleLabel setFont:[UIFont wcPfRegularFontOfSize:14]];
    [self.whiteView addSubview:cancelB];
    [cancelB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.whiteView).offset(20);
        make.top.equalTo(self.whiteView).offset(15);
    }];
    
    UIButton *doneB = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneB setTitle:NSLocalizedString(@"confirm", @"确定") forState:UIControlStateNormal];
    [doneB setTitleColor:kMainColor forState:UIControlStateNormal];
    [doneB.titleLabel setFont:[UIFont wcPfRegularFontOfSize:14]];
    [doneB addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:doneB];
    [doneB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.whiteView).offset(-20);
        make.top.equalTo(self.whiteView).offset(15);
    }];
    
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = kBgColor;
    [self.whiteView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.top.equalTo(self.whiteView.mas_top).offset(54);
    }];
    
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = kBgColor;
    self.textView.font = [UIFont wcPfRegularFontOfSize:15];
    [self.textView becomeFirstResponder];
    self.textView.delegate = self;
    [bgView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.whiteView).offset(kHorEdge);
        make.right.equalTo(self.whiteView).offset(-kHorEdge);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-10);
    }];
}

#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
        //取出键盘动画的时间(根据userInfo的key----UIKeyboardAnimationDurationUserInfoKey)
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //取得键盘最后的frame(根据userInfo的key----UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 227}, {320, 253}}";)
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.frame.size.height;
    
    //执行动画
    [UIView animateWithDuration:duration animations:^{
        [self.whiteView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(transformY);
        }];
        [self layoutIfNeeded];
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
      [self.whiteView mas_updateConstraints:^(MASConstraintMaker *make) {
          make.bottom.equalTo(self);
      }];
      [self layoutIfNeeded];
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.whiteView]) {
        return NO;
    }
    return YES;
}

- (void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)hide{
    [self removeFromSuperview];
}

- (void)done
{
    if (self.updateData) {
        self.updateData(@{self.dic[@"id"]:self.textView.text});
    }
    [self hide];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];
    if (str.length > self.maxNumber)
    {
        NSRange rangeIndex = [str rangeOfComposedCharacterSequenceAtIndex:self.maxNumber];
        
        if (rangeIndex.length == 1)//字数超限
        {
            textView.text = [str substringToIndex:self.maxNumber];
            //这里重新统计下字数，字数超限，我发现就不走textViewDidChange方法了，你若不统计字数，忽略这行
            //self.textNumLab.attributedText = [self handleNum:[NSString stringWithFormat:@"%lu", (unsigned long)textView.text.length]];
        }else{
            NSRange rangeRange = [str rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.maxNumber)];
            textView.text = [str substringWithRange:rangeRange];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > self.maxNumber)
    {
        textView.text = [textView.text substringToIndex:self.maxNumber];
    }
    
    //记录输入的字数，你若不统计字数，忽略这行
    //self.textNumLab.attributedText = [self handleNum:[NSString stringWithFormat:@"%lu", (unsigned long)textView.text.length]];
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    self.titleLab.text = dic[@"name"];
    self.textView.text = dic[@"status"][@"Value"];
    self.maxNumber = [dic[@"define"][@"max"] integerValue];
}

@end
