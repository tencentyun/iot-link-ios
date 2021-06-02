//
//  TIoTCustomCalendarCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCustomCalendarCell.h"

@implementation TIoTCustomCalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.todayBackCircle];
        [self addSubview:self.todayLabel];
        [self addSubview:self.lunarLabel];
    }
    
    return self;
}

- (UIView *)todayBackCircle {
    if (_todayBackCircle == nil) {
        _todayBackCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height)];
        _todayBackCircle.center = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
        _todayBackCircle.layer.cornerRadius = 8;
        _todayBackCircle.layer.masksToBounds = YES;
    }
    return _todayBackCircle;
}

- (UILabel *)todayLabel {
    if (_todayLabel == nil) {
        _todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, self.bounds.size.width, 22)];
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        _todayLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _todayLabel.textColor = [UIColor blackColor];
        _todayLabel.backgroundColor = [UIColor clearColor];
    }
    return _todayLabel;
}

- (UILabel *)lunarLabel {
    if (!_lunarLabel) {
        _lunarLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.todayLabel.frame), self.bounds.size.width, 14)];
        _lunarLabel.text = @"";
        _lunarLabel.textColor = [UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1];
        _lunarLabel.textAlignment = NSTextAlignmentCenter;
        _lunarLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    }
    return _lunarLabel;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.todayBackCircle.backgroundColor = [UIColor colorWithHexString:kVideoDemoMainThemeColor];
        self.lunarLabel.textColor = [UIColor whiteColor];
        self.todayLabel.textColor = [UIColor whiteColor];
    }else {
        self.todayBackCircle.backgroundColor = [UIColor clearColor];
    }
}
@end
