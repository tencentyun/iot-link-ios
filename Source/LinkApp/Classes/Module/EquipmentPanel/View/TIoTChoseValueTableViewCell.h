//
//  WCChoseValueTableViewCell.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTChoseValueTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic) UIEdgeInsets separatorInset;

- (void)setTitle:(NSString *)title andSelect:(BOOL)isSelect;


@end

NS_ASSUME_NONNULL_END
