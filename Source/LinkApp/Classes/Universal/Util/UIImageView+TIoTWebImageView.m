//
//  UIImageView+WCWebImageView.m
//  TenextCloud
//
//

#import "UIImageView+TIoTWebImageView.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (WCWebImageView)

- (void)setImageWithURLStr:(NSString *_Nullable)str{
    [self sd_setImageWithURL:[NSURL URLWithString:str]];
}

- (void)setImageDefaultPlaceHolderWithURLStr:(NSString *_Nullable)str{
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@""]];
}

- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder{
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:placeHolder]];
}

@end
