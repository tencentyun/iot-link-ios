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
        
    }
    
    return self;
}

- (UIView *)todayBackCircle {
    if (_todayBackCircle == nil) {
        _todayBackCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.8 * self.bounds.size.height, 0.8 * self.bounds.size.height)];
        _todayBackCircle.center = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
        _todayBackCircle.layer.cornerRadius = _todayBackCircle.frame.size.width/2;
    }
    return _todayBackCircle;
}

- (UILabel *)todayLabel {
    if (_todayLabel == nil) {
        _todayLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        _todayLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _todayLabel.backgroundColor = [UIColor clearColor];
    }
    return _todayLabel;
}

@end
