//
//  WCMediumCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTMediumCell : UICollectionViewCell
@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic, copy) void (^boolUpdate)(NSDictionary *uploadInfo);

@property (nonatomic) WCThemeStyle themeStyle;
@end

NS_ASSUME_NONNULL_END
