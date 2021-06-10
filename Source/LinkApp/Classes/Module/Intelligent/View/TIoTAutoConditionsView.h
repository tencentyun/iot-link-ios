//
//  TIoTAutoConditionsView.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AutoChooseConditionBlock)(NSString *conditionContent, NSInteger number);

@interface TIoTAutoConditionsView : UIView
@property (nonatomic, copy) AutoChooseConditionBlock chooseConditionBlock;
@end

NS_ASSUME_NONNULL_END
