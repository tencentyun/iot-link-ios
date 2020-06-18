//
//  WCWebVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIoTWebVC : UIViewController

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) NSString *urlPath;
@property (nonatomic,assign) BOOL needJudgeJump;//需要判断跳转

@end

NS_ASSUME_NONNULL_END
