//
//  WCEnumItem.m
//  TenextCloud
//
//  Created by Wp on 2019/12/31.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTEnumItem.h"

@interface TIoTEnumItem()
@property (weak, nonatomic) IBOutlet UIView *bgview;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *imgV;



@property (nonatomic,strong) CAGradientLayer *gl;
@end

@implementation TIoTEnumItem

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    [self.bgview.layer insertSublayer:self.gl atIndex:0];
    
    
    self.bgview.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.20].CGColor;
    self.bgview.layer.shadowOffset = CGSizeMake(0,3);
    self.bgview.layer.shadowRadius = 3;
    self.bgview.layer.shadowOpacity = 0.7;
    self.bgview.layer.cornerRadius = 3;
    
}


#pragma mark - getter&setter

- (void)setName:(NSString *)name
{
    _name = name;
    self.titleLab.text = name;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (isSelected) {
        self.imgV.image = [UIImage imageNamed:@"enum_sel"];
        self.gl.colors = @[(__bridge id)[UIColor colorWithRed:106/255.0 green:225/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:0/255.0 green:82/255.0 blue:217/255.0 alpha:1.0].CGColor];
    }
    else
    {
        self.imgV.image = [UIImage imageNamed:@"enum_no"];
        self.gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor];
    }
    
}

- (CAGradientLayer *)gl
{
    if (!_gl) {
        _gl = [CAGradientLayer layer];
        _gl.frame = self.bgview.bounds;
        _gl.startPoint = CGPointMake(0.5, 0);
        _gl.endPoint = CGPointMake(0.5, 1);
        _gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor];
        _gl.locations = @[@(0),@(1.0f)];
        _gl.cornerRadius = 3;
    }
    
    return _gl;
}

@end
