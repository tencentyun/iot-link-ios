//
//  WCButton.m
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTButton.h"

@implementation TIoTButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        self.layer.cornerRadius = 4;
        self.backgroundColor = [UIColor colorWithHexString:kIntelligentMainHexColor];
    }
    return self;
}


@end
