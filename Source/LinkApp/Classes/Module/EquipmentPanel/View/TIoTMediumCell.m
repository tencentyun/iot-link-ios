//
//  WCMediumCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/6.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTMediumCell.h"

@interface TIoTMediumCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIImageView *righImg;
@property (weak, nonatomic) IBOutlet UISwitch *swich;
@property (weak, nonatomic) IBOutlet UIView *effMaskView;


@end
@implementation TIoTMediumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowRadius = 16;
    self.layer.shadowOpacity = 1;
    self.layer.cornerRadius = 6;
    
    [self addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if (![change[NSKeyValueChangeNewKey] boolValue]) {
            self.tintColor = [UIColor grayColor];
            self.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        }
    }
}

- (IBAction)switchChanged:(UISwitch *)sender {
    if (self.boolUpdate) {
        self.boolUpdate(@{self.info[@"id"]:@(self.swich.on)});
    }
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    if ([info[@"ui"][@"icon"] isEqualToString:@"create"]) {
        
    }
    self.nameLab.text = info[@"name"];
    
//    NSString *defaultKey = [NSString stringWithFormat:@"%@",info[@"Value"]?:@""];
    
    NSString *defaultKey = [NSString stringWithFormat:@"%@",info[@"status"][@"Value"]?:@""];
    
    NSDictionary *define = info[@"define"];
    if ([define[@"type"] isEqualToString:@"bool"]) {
        [self.imgV setImage:[[UIImage imageNamed:@"c_switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        self.contentLab.hidden = YES;
        self.righImg.hidden = YES;
        self.swich.hidden = NO;
        
//        self.swich.on = [info[@"status"][@"Value"] integerValue] == 0 ? NO : YES;
        
        if (![NSString isNullOrNilWithObject:defaultKey]) {
            self.swich.on = [defaultKey integerValue] == 0 ? NO : YES;
        }else {
            self.swich.on = [info[@"Value"] integerValue] == 0 ? NO : YES;
        }
    }
    else
    {
        self.contentLab.hidden = NO;
        self.righImg.hidden = NO;
        self.swich.hidden = YES;
        
        if ([define[@"type"] isEqualToString:@"enum"]) {
            [self.imgV setImage:[[UIImage imageNamed:@"c_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            
//            NSString *key = [NSString stringWithFormat:@"%@",info[@"status"][@"Value"]];
//            self.contentLab.text = define[@"mapping"][key];
            
            if (![NSString isNullOrNilWithObject:defaultKey]) {
                
                self.contentLab.text = define[@"mapping"][defaultKey];
            }else {
                NSString *key = [NSString stringWithFormat:@"%@",info[@"Value"]];
                self.contentLab.text = define[@"mapping"][key];
            }
        }
        else if ([define[@"type"] isEqualToString:@"int"] || [define[@"type"] isEqualToString:@"float"]) {
            [self.imgV setImage:[[UIImage imageNamed:@"c_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            NSString *key = @"";
            if (![NSString isNullOrNilWithObject:defaultKey]) {
                key = [NSString stringWithFormat:@"%@",defaultKey];
            }else {
                key = [NSString stringWithFormat:@"%@",info[@"Value"] ?: @""];
            }
            
            if ([info[@"id"]isEqualToString:@"Temperature"]) {
                NSDictionary *userconfig = info[@"Userconfig"];
                self.contentLab.text = [NSString judepTemperatureWithUserConfig:userconfig[@"TemperatureUnit"] templeUnit:[NSString stringWithFormat:@"%@%@",key,define[@"unit"]]];;
            }else {
                self.contentLab.text = [NSString stringWithFormat:@"%@%@",key,define[@"unit"]];
            }
        }else {
            //结构体 数组 字符串 时间类  暂时数值不做处理
            [self.imgV setImage:[[UIImage imageNamed:@"c_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            NSString *key = @"";
            if (![NSString isNullOrNilWithObject:defaultKey]) {
                key = [NSString stringWithFormat:@"%@",defaultKey];
            }else {
                key = [NSString stringWithFormat:@"%@",info[@"Value"] ?: @""];
            }
            
            if ([info[@"id"]isEqualToString:@"Temperature"]) {
                NSDictionary *userconfig = info[@"Userconfig"];
                self.contentLab.text = [NSString judepTemperatureWithUserConfig:userconfig[@"TemperatureUnit"] templeUnit:[NSString stringWithFormat:@"%@%@",key,define[@"unit"]]];;
            }else {
                self.contentLab.text = [NSString stringWithFormat:@"%@%@",key,define[@"unit"]];
            }
        }
    }
}


- (void)setThemeStyle:(WCThemeStyle)themeStyle
{
    _themeStyle = themeStyle;
    
    if (themeStyle == WCThemeSimple) {
        self.tintColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        self.nameLab.textColor = kFontColor;
        self.contentLab.textColor = kRGBColor(153, 153, 153);
        self.effMaskView.backgroundColor = [UIColor whiteColor];
    }
    else if (themeStyle == WCThemeStandard)
    {
        self.tintColor = [UIColor whiteColor];
        self.nameLab.textColor = [UIColor whiteColor];
        self.contentLab.textColor = [UIColor whiteColor];
        self.effMaskView.backgroundColor = [UIColor blackColor];
    }
    else if (themeStyle == WCThemeDark)
    {
        self.tintColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
        self.nameLab.textColor = [UIColor whiteColor];
        self.contentLab.textColor = [UIColor whiteColor];
        self.effMaskView.backgroundColor = [UIColor blackColor];
    }
    
}
@end
