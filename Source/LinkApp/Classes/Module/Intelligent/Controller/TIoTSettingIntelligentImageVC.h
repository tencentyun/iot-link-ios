//
//  TIoTSettingIntelligentImageVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectedIntelligentImageBlock)(NSString *imageUrl);
@interface TIoTSettingIntelligentImageVC : UIViewController
@property (nonatomic, strong) SelectedIntelligentImageBlock selectedIntelligentImageBlock;
@end

NS_ASSUME_NONNULL_END
