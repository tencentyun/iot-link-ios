//
//  WCBaseBigBtnView.h
//  TenextCloud
//
//  Created by Wp on 2020/1/7.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TIoTBaseBigBtnView : UIView

@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic, copy) void (^update)(NSDictionary *uploadInfo);

@end

