//
//  TIoTAddFamilyCell.h
//  LinkApp
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^FillMessageBlock)(NSString *contentString);

typedef NS_ENUM(NSInteger, FillFamilyType) {
    FillFamilyTypeFamilyAddress,
    FillFamilyTypeFamilyName,
};

@interface TIoTAddFamilyCell : UITableViewCell
+ (instancetype)cellForTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *placeHoldString;
@property (nonatomic, strong) NSString *contectString;
@property (nonatomic, copy) FillMessageBlock fillMessageBlock;
@property (nonatomic, assign) FillFamilyType familyType;
@property (nonatomic, strong) UILabel *contentLabel;
@end

NS_ASSUME_NONNULL_END
