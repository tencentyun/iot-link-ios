//
//  TIoTSettingIntelligentImageVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectedIntelligentImageBlock)(NSString *imageUrl);
@interface TIoTSettingIntelligentImageVC : UIViewController
@property (nonatomic, strong) SelectedIntelligentImageBlock selectedIntelligentImageBlock;
@end

NS_ASSUME_NONNULL_END
