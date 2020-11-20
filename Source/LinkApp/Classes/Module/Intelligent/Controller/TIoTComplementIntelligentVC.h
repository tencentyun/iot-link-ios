//
//  TIoTComplementIntelligentVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTIntelligentProductConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SceneActioinType) {
    SceneActioinTypeManual,
    SceneActioinTypeDelay,
    SceneActioinTypeNotice,
    SceneActioinTypeTimer,
};

/**
 完善信息页面
 */
@interface TIoTComplementIntelligentVC : UIViewController
@property (nonatomic, strong) NSMutableArray <TIoTPropertiesModel*>*actionArray;
@property (nonatomic, strong) NSMutableArray *valueArray;
@property (nonatomic, strong) TIoTIntelligentProductConfigModel *productModel;
//@property (nonatomic, strong) NSMutableArray <TIoTIntelligentProductConfigModel *>*productModelArray;
@property (nonatomic, assign) SceneActioinType sceneActioinType;
@property (nonatomic, strong) NSMutableArray *delayTimeArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) BOOL isAuto;
@property (nonatomic, strong) NSMutableDictionary *autoParamDic; //自动场景
@property (nonatomic, strong) NSMutableDictionary *manualParamDic; //手动场景
@end

NS_ASSUME_NONNULL_END
