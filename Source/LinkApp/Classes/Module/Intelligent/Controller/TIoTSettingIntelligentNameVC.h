//
//  TIoTSettingIntelligentNameVC.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SaveIntelligentNameBlock)(NSString *name);
@interface TIoTSettingIntelligentNameVC : UIViewController
@property (nonatomic, copy) SaveIntelligentNameBlock saveIntelligentNameBlock;
@property (nonatomic, copy) NSString *defaultSceneString;
@end

NS_ASSUME_NONNULL_END
