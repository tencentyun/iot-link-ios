//
//  WCPopoverVC.h
//  TenextCloud
//
//  Created by Wp on 2020/1/11.
//  Copyright © 2020 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIoTPopoverVC : UIViewController

@property (nonatomic,copy) NSArray *families;

@property (nonatomic,strong) void(^update)(NSInteger index);

@end
