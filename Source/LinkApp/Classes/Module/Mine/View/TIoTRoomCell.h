//
//  WCRoomCell.h
//  TenextCloud
//
//  Created by Wp on 2020/1/8.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTRoomCell : UITableViewCell
@property (nonatomic,assign) BOOL isOwer; //（配合info） 房间管理页面需要传 
@property (nonatomic,copy) NSDictionary *info;
@property (nonatomic,strong) NSDictionary *info2;

@end

NS_ASSUME_NONNULL_END
