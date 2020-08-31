//
//  SYPaneView.h
//  SYPanView
//
//  Created by Yunis on 2017/8/18.
//  Copyright © 2017年 Yunis. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 未完成任务占比图
 */
@interface SYPaneView : UIView

@property (nonatomic) CGFloat   radius;/**< 半径*/
@property (nonatomic) CGFloat   startAngle;/**<开始角度*/
@property (nonatomic) CGFloat   endAngle;/**<结束角度*/
@property (nonatomic) CGFloat   scaleLineWidth;/**<刻度线 宽度或者说长度*/
@property (nonatomic) NSInteger scaleLineCount;/**<刻度线 个数*/
@property (nonatomic) NSInteger allTaskCount;/**<总任务数量*/
@property (nonatomic) NSInteger todoTask;/**<未完成任务数量*/

@property(nonatomic,strong)UIColor *normalColor;/**<默认颜色*/
@property(nonatomic,strong)UIColor *hightColor;/**<未完成任务刻度颜色*/

- (void)faild;

- (void)sucess;

@end
