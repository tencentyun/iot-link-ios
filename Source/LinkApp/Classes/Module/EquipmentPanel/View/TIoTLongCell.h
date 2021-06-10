//
//  WCLongCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTLongCell : UICollectionViewCell


@property (nonatomic,strong) NSDictionary *showInfo;
@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic, copy) void (^boolUpdate)(NSDictionary *uploadInfo);

@property (nonatomic) WCThemeStyle themeStyle;

@end

NS_ASSUME_NONNULL_END
