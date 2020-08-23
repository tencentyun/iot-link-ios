//
//  WCLongCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/6.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTLongCell.h"

@interface TIoTLongCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIImageView *rightImg;
@property (weak, nonatomic) IBOutlet UISwitch *swich;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effView;
@property (weak, nonatomic) IBOutlet UIView *effMaskView;

@end

@implementation TIoTLongCell

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
//        self.boolUpdate(@{self.info[@"id"]:@(self.swich.on)});
        self.boolUpdate(@{self.info[@"id"]: self.swich.on? @1:@0});
    }
}

- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    self.name.text = info[@"name"];
    
    NSDictionary *define = info[@"define"];
    if ([define[@"type"] isEqualToString:@"bool"]) {
        
        [self.imgV setImage:[[UIImage imageNamed:@"c_switch"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        self.content.hidden = YES;
        self.rightImg.hidden = YES;
        self.swich.hidden = NO;
        
        self.swich.on = [info[@"status"][@"Value"] integerValue] == 0 ? NO : YES;
    }
    else
    {
        self.content.hidden = NO;
        self.rightImg.hidden = NO;
        self.swich.hidden = YES;
        
        if ([define[@"type"] isEqualToString:@"enum"]) {
            [self.imgV setImage:[[UIImage imageNamed:@"c_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            NSString *key = [NSString stringWithFormat:@"%@",info[@"status"][@"Value"]];
            self.content.text = define[@"mapping"][key];
        }
        else if ([define[@"type"] isEqualToString:@"int"] || [define[@"type"] isEqualToString:@"float"]) {
            [self.imgV setImage:[[UIImage imageNamed:@"c_light"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            NSString *key = [NSString stringWithFormat:@"%@",info[@"status"][@"Value"] ?: @""];
            
            if ([info[@"id"]isEqualToString:@"Temperature"]) {
                NSDictionary *userconfig = info[@"Userconfig"];
                self.content.text = [self judepTemperatureWithUserConfig:userconfig[@"TemperatureUnit"] templeUnit:[NSString stringWithFormat:@"%@%@",key,define[@"unit"]]];;
            }else {
                self.content.text = [NSString stringWithFormat:@"%@%@",key,define[@"unit"]];
            }
            
        }
    }
}

- (void)setShowInfo:(NSDictionary *)showInfo
{
    self.content.hidden = NO;
    self.rightImg.hidden = NO;
    self.swich.hidden = YES;
    
    self.name.text = showInfo[@"name"];
    self.content.text = showInfo[@"content"];
    [self.imgV setImage:[[UIImage imageNamed:@"c_timer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}


- (void)setThemeStyle:(WCThemeStyle)themeStyle
{
    _themeStyle = themeStyle;
    
    if (themeStyle == WCThemeSimple) {
        self.tintColor = kMainColor;
        self.name.textColor = kFontColor;
        self.content.textColor = kRGBColor(153, 153, 153);
        self.effMaskView.backgroundColor = [UIColor whiteColor];
    }
    else if (themeStyle == WCThemeStandard)
    {
        self.tintColor = [UIColor whiteColor];
        self.name.textColor = [UIColor whiteColor];
        self.content.textColor = [UIColor whiteColor];
        self.effMaskView.backgroundColor = [UIColor blackColor];
    }
    else if (themeStyle == WCThemeDark)
    {
        self.tintColor = kMainColor;
        self.name.textColor = [UIColor whiteColor];
        self.content.textColor = [UIColor whiteColor];
        self.effMaskView.backgroundColor = [UIColor blackColor];
    }
    
}

- (NSString *)chanageTemperatureUnitWith:(NSString *)temperatureString {
    
        if ([temperatureString containsString:@"摄氏"] || [temperatureString containsString:@"℃"]) {
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℃" withString:@""];
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"摄氏" withString:@""];
            if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
                NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.fahrenheit];
                NSMeasurement *celsiusMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.celsius];
                return [NSString stringWithFormat:@"%f℉",celsiusMeasurement.doubleValue];
            }else {
                return [NSString stringWithFormat:@"%@℉",temperatureString];
            }
            
        }else if ([temperatureString containsString:@"华氏"] || [temperatureString containsString:@"℉"]){
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"℉" withString:@""];
            temperatureString = [temperatureString stringByReplacingOccurrencesOfString:@"华氏" withString:@""];
            if ([NSString isPureIntOrFloat:[temperatureString copy]]) {
                NSMeasurement *measurement = [[NSMeasurement alloc]initWithDoubleValue:temperatureString.floatValue unit:NSUnitTemperature.celsius];
                NSMeasurement *fahrenheitMeasurement = [measurement measurementByConvertingToUnit:NSUnitTemperature.fahrenheit];
                return [NSString stringWithFormat:@"%f℃",fahrenheitMeasurement.doubleValue];
            }else {
                return [NSString stringWithFormat:@"%@℃",temperatureString];
            }
        }else {
            return temperatureString;
        }
}

- (NSString *)judepTemperatureWithUserConfig:(NSString *)configString templeUnit:(NSString *)unitString {
    if ([configString isEqualToString:@"F"]) {
        if ([unitString containsString:@"摄氏"] || [unitString containsString:@"℃"]) {
            return [self chanageTemperatureUnitWith:unitString];
        }else {
            return unitString;
        }
    }else if ([configString isEqualToString:@"C"]) {
        if ([unitString containsString:@"华氏"] || [unitString containsString:@"℉"]) {
            return [self chanageTemperatureUnitWith:unitString];
        }else {
            return unitString;
        }
    }else {
        return unitString;
    }
}

@end
