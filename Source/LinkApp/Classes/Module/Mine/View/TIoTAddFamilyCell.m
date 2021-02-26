//
//  TIoTAddFamilyCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/12/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAddFamilyCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAddFamilyCell ()<UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *contentTextField;
@property (nonatomic, strong) NSString *inputContent;

@end

@implementation TIoTAddFamilyCell

+ (instancetype)cellForTableView:(UITableView *)tableView {
    static NSString *kTIoTAddFamilyCellID = @"TIoTAddFamilyCell";
    TIoTAddFamilyCell *cell = [tableView dequeueReusableCellWithIdentifier:kTIoTAddFamilyCellID];
    if (!cell) {
        cell = [[TIoTAddFamilyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTIoTAddFamilyCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.inputContent = @"";
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat kLeftRightPadding = 20;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.titleLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(kLeftRightPadding);
        make.width.mas_equalTo(80);
    }];
    
    UIImageView *arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mineArrow"]];
    [self.contentView addSubview:arrowImage];
    [arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-kLeftRightPadding);
        make.width.height.mas_equalTo(18);
        make.centerY.equalTo(self.contentView);
    }];
    arrowImage.hidden = YES;
    
    self.contentTextField = [[UITextField alloc]init];
    self.contentTextField.text = @"";
    self.contentTextField.textColor = [UIColor colorWithHexString:@"#A1A7B2"];
    self.contentTextField.textAlignment = NSTextAlignmentLeft;
    self.contentTextField.font = [UIFont wcPfRegularFontOfSize:14];
    self.contentTextField.delegate = self;
    self.contentTextField.returnKeyType = UIReturnKeyDone;
    [self.contentView addSubview:self.contentTextField];
    [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(20);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-44);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-1);
        make.bottom.mas_equalTo(1);
    }];
}

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    self.titleLabel.text = titleString;
}

- (void)setPlaceHoldString:(NSString *)placeHoldString {
    _placeHoldString = placeHoldString;
    self.contentTextField.placeholder = placeHoldString;
}

- (void)setContectString:(NSString *)contectString {
    _contectString = contectString;
    self.contentTextField.text = contectString;
}

- (void)drawRect:(CGRect)rect {
    if (self.familyType == FillFamilyTypeFamilyAddress) {
        self.contentTextField.hidden = YES;
        
        if (self.contentLabel == nil) {
            self.contentLabel = [[UILabel alloc]init];
            [self.contentLabel setLabelFormateTitle:self.placeHoldString font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentLeft];
            self.contentLabel.textColor = [UIColor colorWithHexString:@"#A1A7B2" withAlpha:0.7];
            
            [self.contentView addSubview:self.contentLabel];
            [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.titleLabel.mas_right).offset(20);
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_right).offset(-44);
            }];
        }
        
    }else {
        self.contentTextField.hidden = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *inputString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSInteger kMaxLength = 10;
    NSString *toBeString = inputString;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (toBeString.length > kMaxLength) {
                inputString = [toBeString substringToIndex:kMaxLength];
            }

        }
        else{//有高亮选择的字符串，则暂不对文字进行统计和限制

        }

    }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            inputString = [toBeString substringToIndex:kMaxLength];
        }

    }
    self.inputContent = inputString;
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self judgeContent];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self judgeContent];
    return YES;
}

- (void)judgeContent {
    [self.contentTextField resignFirstResponder];
    
    if (self.familyType == FillFamilyTypeFamilyName) {
        if ([NSString isNullOrNilWithObject:self.inputContent]|| [NSString isFullSpaceEmpty:self.inputContent]) {
            
            [MBProgressHUD showError:NSLocalizedString(@"no_familyName", @"家庭名称不能为空")];
        }
    }
    
    if (self.fillMessageBlock) {
        
        self.fillMessageBlock(self.inputContent?:@"");
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
