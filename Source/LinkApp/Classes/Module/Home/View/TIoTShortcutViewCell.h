//
//  TIoTShortcutViewCell.h
//  LinkApp
//
//  Created by ccharlesren on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTShortcutViewCell : UICollectionViewCell
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyValue;
@property (nonatomic, copy) void (^boolUpdate)(NSDictionary *uploadInfo); //bool
@property (nonatomic, copy) void (^intOrFloatUpdate)(void);               // int float
@property (nonatomic, copy) void (^enumUpdate)(void);                     //enum 

- (void)setPropertyModel:(NSDictionary *)infoModel;

- (void)setIconDefaultImageString:(NSString *)iconImage withURLString:(NSString *)urlString;
@end

NS_ASSUME_NONNULL_END
