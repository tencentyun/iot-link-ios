//
//  UIImageView+TIoTDemoWebImage.m
//  LinkSDKDemo
//
//

#import "UIImageView+TIoTDemoWebImage.h"
#import "UIImageView+WebCache.h"
@implementation UIImageView (TIoTDemoWebImage)
- (void)setImageWithURLStr:(NSString *_Nullable)str placeHolder:(NSString *_Nullable)placeHolder{
    [self sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:placeHolder]];
}
@end



