//
//  WCPhotoCell.h
//  TenextCloud
//
//  Created by Wp on 2019/11/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic) void (^deleteTap)(void);
- (void)setHiddenDeleteBtn:(BOOL)hiddenDeleteBtn;
@end

NS_ASSUME_NONNULL_END
