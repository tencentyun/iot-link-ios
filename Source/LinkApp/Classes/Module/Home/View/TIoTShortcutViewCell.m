//
//  TIoTShortcutViewCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTShortcutViewCell.h"
#import "UILabel+TIoTExtension.h"
#import "UIImageView+TIoTWebImageView.h"
@interface TIoTShortcutViewCell ()
@property (nonatomic, strong) UIButton *itemBtn;
@property (nonatomic, strong) UIImageView *itemIcon;
@property (nonatomic, strong) UILabel *functionName;
@property (nonatomic, strong) UILabel *functionValue;
@property (nonatomic, strong) NSDictionary *infoModel;
@end

@implementation TIoTShortcutViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupItemUI];
    }
    return self;
}

- (void)setupItemUI {
    
    CGFloat kItemBtnSize = 55;
    CGFloat kItemIconSize = 20;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.itemBtn.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
    self.itemBtn.layer.cornerRadius = kItemBtnSize/2;
    [self.itemBtn addTarget:self action:@selector(switchTrunOnOrOff:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.itemBtn];
    [self.itemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(44);
        make.centerX.equalTo(self.contentView);
        make.height.width.mas_equalTo(kItemBtnSize);
    }];
    
    self.itemIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [self.itemBtn addSubview:self.itemIcon];
    [self.itemIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.itemBtn);
        make.height.width.mas_equalTo(kItemIconSize);
    }];
    
    self.functionName = [[UILabel alloc]init];
    [self.functionName setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:@"#15161A" textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.functionName];
    [self.functionName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.contentView);
        make.centerX.equalTo(self.itemBtn);
        make.top.equalTo(self.itemBtn.mas_bottom).offset(8);
    }];
    
    self.functionValue = [[UILabel alloc]init];
    [self.functionValue setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.functionValue];
    [self.functionValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.functionName.mas_bottom);
        make.width.equalTo(self.itemBtn);
        make.centerX.equalTo(self.functionName);
    }];
}

#pragma mark - setter

- (void)setIconDefaultImageString:(NSString *)iconImage withURLString:(NSString *)urlString {
    [self.itemIcon setImageWithURLStr:urlString?:@"" placeHolder:iconImage];
}

- (void)switchTrunOnOrOff:(UIButton *)sender {
    
    NSString *typeString = self.infoModel[@"define"][@"type"]?:@"";
    
    if ([typeString isEqualToString:@"bool"]) {
        if (self.boolUpdate) {
            
            BOOL isTurnOn = [self.infoModel[@"status"][@"Value"] integerValue] == 0 ? NO : YES;
            
            self.boolUpdate(@{self.infoModel[@"id"]:@(!isTurnOn)});
        }
    }else if ([typeString isEqualToString:@"int"]||[typeString isEqualToString:@"float"]) {
        if (self.intOrFloatUpdate) {
            self.intOrFloatUpdate();
        }
    }else if ([typeString isEqualToString:@"enum"]) {
        if (self.enumUpdate) {
            self.enumUpdate();
        }
    }else {
        
    }
}

- (void)setPropertyModel:(NSDictionary *)infoModel{
    self.infoModel = infoModel;

    if ([infoModel[@"define"][@"type"] isEqualToString:@"bool"]) {
        BOOL isTurnOn = [infoModel[@"status"][@"Value"] integerValue] == 0 ? NO : YES;
        if (isTurnOn) {
            self.itemBtn.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        }else {
            self.itemBtn.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];
        }
    }
    
}

- (void)setPropertyName:(NSString *)propertyName {
    _propertyName = propertyName;
    self.functionName.text = propertyName;
}

- (void)setPropertyValue:(NSString *)propertyValue {
    _propertyValue = propertyValue;
    self.functionValue.text = propertyValue;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.itemBtn.backgroundColor = [UIColor colorWithHexString:@"#F3F3F5"];

}

@end
