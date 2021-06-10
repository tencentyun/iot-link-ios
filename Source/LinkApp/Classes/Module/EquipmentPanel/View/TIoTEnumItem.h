//
//  WCEnumItem.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTEnumItem : UICollectionViewCell

@property (nonatomic) BOOL isSelected;
@property (nonatomic,copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
