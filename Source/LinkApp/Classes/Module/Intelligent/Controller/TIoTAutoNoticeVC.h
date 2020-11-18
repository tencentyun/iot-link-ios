//
//  TIoTAutoNoticeVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TIoTAutoIntelligentModel;
typedef void(^AutoAddNoticeBlock)(NSMutableArray <TIoTAutoIntelligentModel*>* _Nullable noticeArray);
typedef void(^AutoDeleteNoticeBlcok)(NSMutableArray <TIoTAutoIntelligentModel*>* _Nullable noticeArray);
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAutoNoticeVC : UIViewController
@property (nonatomic, copy) AutoAddNoticeBlock addNoticeBlock;

@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, copy) AutoDeleteNoticeBlcok deleteNoticeBlcok;
@property (nonatomic, strong) TIoTAutoIntelligentModel *editModel;
@end

NS_ASSUME_NONNULL_END
