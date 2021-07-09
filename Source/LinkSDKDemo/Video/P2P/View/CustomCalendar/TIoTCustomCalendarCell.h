//
//  TIoTCustomCalendarCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTCustomCalendarCell : UICollectionViewCell
@property (nonatomic, strong) UIView *todayBackCircle; //标记
@property (nonatomic, strong) UILabel *todayLabel; //标记日期label
@property (nonatomic, strong) UILabel *lunarLabel; //农历日期Label
- (void)setSelected:(BOOL)selected;
@end

NS_ASSUME_NONNULL_END
