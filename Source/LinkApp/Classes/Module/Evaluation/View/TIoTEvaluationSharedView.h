//
//  TIoTEvaluationSharedView.h
//  LinkApp
//
//  Created by ccharlesren on 2020/10/16.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTEvaluationSharedView : UIView
@property (nonatomic, strong) NSDictionary *sharedFriendDic; // url里item的字典
@property (nonatomic, copy) NSString *sharedURLString; //分享出去的URL 详情页面的URL
@property (nonatomic, copy) NSString *sharedPathString; //小程序path 
@end

NS_ASSUME_NONNULL_END
