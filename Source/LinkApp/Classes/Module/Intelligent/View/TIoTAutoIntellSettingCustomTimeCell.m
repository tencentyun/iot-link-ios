//
//  TIoTAutoIntellSettingCustomTimeCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/12.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTAutoIntellSettingCustomTimeCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTAutoIntellSettingCustomTimeCell ()
@property (nonatomic, strong) UILabel *weekLabel;
@end

@implementation TIoTAutoIntellSettingCustomTimeCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupItemUI];
    }
    return self;
}

- (void)setupItemUI {
    self.weekLabel = [[UILabel alloc]init];
    self.weekLabel.layer.cornerRadius = 23;
    self.weekLabel.layer.borderWidth = 1;
    self.weekLabel.layer.borderColor = [UIColor colorWithHexString:@"#E7E8EB"].CGColor;
//    [self.weekLabel setButtonFormateWithTitlt:@"asdf" titleColorHexString:kTemperatureHexColor font:[UIFont wcPfRegularFontOfSize:14]];
    [self.weekLabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kTemperatureHexColor textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.weekLabel];
    [self.weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.contentView);
    }];
    
}

- (void)setItemString:(NSString *)itemString {
    _itemString = itemString?:@"";
    self.weekLabel.text = itemString?:@"";
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.weekLabel.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
        self.weekLabel.textColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    }else {
        self.weekLabel.layer.borderColor = [UIColor colorWithHexString:@"#E7E8EB"].CGColor;
        self.weekLabel.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
    }
}

- (void)setSelected:(BOOL)selected {
    if (self.autoRepeatTimeType == AutoRepeatTimeTypeTimePeriod) {
        if (selected == YES) {
            self.weekLabel.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
            self.weekLabel.textColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        }else {
            self.weekLabel.layer.borderColor = [UIColor colorWithHexString:@"#E7E8EB"].CGColor;
            self.weekLabel.textColor = [UIColor colorWithHexString:kTemperatureHexColor];
        }
    }
}

@end
