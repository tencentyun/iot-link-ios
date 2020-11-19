//
//  TIoTAutoNoticeCell.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TIoTAutoNoticeCellDelegate <NSObject>

- (void)switchChange:(UISwitch *_Nullable)senderSwitch;

@end

/**
 自动智能-添加任务中-发送通知
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoNoticeCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, weak) id<TIoTAutoNoticeCellDelegate>delegate;
@property (nonatomic, assign) BOOL isOn;
@end

NS_ASSUME_NONNULL_END
