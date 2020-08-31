//
//  TIoTConfigInputView.m
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTConfigInputView.h"

@interface TIoTConfigInputView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *button;

@end

@implementation TIoTConfigInputView

@synthesize inputText = _inputText;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder haveButton:(BOOL)haveButton {
    self = [super init];
    if (self) {
        self.titleLabel.text = title;
        self.button.hidden = !haveButton;
        self.textField.enabled = !haveButton;
        self.textField.placeholder = placeholder;
        self.textField.secureTextEntry = !haveButton;
    }
    return self;
}

- (void)setupUI{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont wcPfRegularFontOfSize:17];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.width.mas_equalTo(68);
    }];
    
    self.textField = [[UITextField alloc] init];
    self.textField.font = [UIFont wcPfRegularFontOfSize:17];
    self.textField.textColor = [UIColor blackColor];
    [self.textField addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.left.equalTo(self.titleLabel.mas_right).offset(22);
        make.right.equalTo(self).offset(49);
    }];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setImage:[UIImage imageNamed:@"new_distri_arrow_down"] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.mas_equalTo(49);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:.0f alpha:0.1f];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark eventResponse

- (void)buttonClick:(UIButton *)sender {
    if (self.buttonAction) {
        self.buttonAction();
    }
}

- (void)changedTextField:(UITextField *)textField {
    if (self.textChangedAction) {
        self.textChangedAction(textField.text);
    }
}

#pragma mark setter or getter

- (void)setInputText:(NSString *)inputText {
    _inputText = inputText;
    self.textField.text = _inputText;
}

- (NSString *)inputText {
    return self.textField.text;
}

@end
