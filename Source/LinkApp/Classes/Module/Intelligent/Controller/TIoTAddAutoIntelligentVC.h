//
//  TIoTAddAutoIntelligentVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/10.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentProductConfigModel.h"

@class TIoTAutoIntelligentModel;
/**
 自动智能主页面
 */
NS_ASSUME_NONNULL_BEGIN

@interface TIoTAddAutoIntelligentVC : UIViewController

@property (nonatomic, strong) NSMutableArray <TIoTAutoIntelligentModel *>*autoDeviceStatusArray; //在setting创建完后返回的
@property (nonatomic, strong) NSDictionary *paramDic; //从智能主页传入场景参数


//自动智能-添加完后会回传
//@property (nonatomic, strong) TIoTDataTemplateModel *templateModel;
@property (nonatomic, strong) TIoTIntelligentProductConfigModel *productModel;  //回传

@property (nonatomic, assign) BOOL isSceneDetail;   //场景详情编辑页面，yes 从智能主页进入 no 普通入口进入
@property (nonatomic, strong) NSDictionary *autoSceneInfoDic; //智能主页，自动智能列表中获取的被选中场景
/**
 刷新当前条件、任务section
 modifiedModel : 编辑过后，回传回来的，需要当前列表刷新
 indexrow :在列表中的index
 isAction: 条件和任务的区分 1 任务 0 条件
 */
- (void)refreshAutoIntelligentList:(BOOL)isAction modifyModel:(TIoTAutoIntelligentModel *)modifiedModel originIndex:(NSInteger)indexrow isEdit:(BOOL )isEdit;

@end

NS_ASSUME_NONNULL_END
