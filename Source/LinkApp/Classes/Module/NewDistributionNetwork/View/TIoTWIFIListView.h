//
//  TIoTWIFIListView.h
//  LinkApp
//
//  Created by Sun on 2020/7/29.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTWIFIListView : UIView

/// WIFI列表数据
@property (nonatomic, strong) NSArray *wifiListArray;

/// 刷新按钮响应事件
@property (nonatomic, copy) void (^refreshAction)(void);

/// 获取WiFi列表按钮响应事件
@property (nonatomic, copy) void (^accessWifiAction)(void);

@end

NS_ASSUME_NONNULL_END
