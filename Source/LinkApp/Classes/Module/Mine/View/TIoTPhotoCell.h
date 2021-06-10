//
//  WCPhotoCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic) void (^deleteTap)(void);
- (void)setHiddenDeleteBtn:(BOOL)hiddenDeleteBtn;
@end

NS_ASSUME_NONNULL_END
