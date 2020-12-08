//
//  TIoTModifyNameVC.h
//  LinkApp
//
//  Created by ccharlesren on 2020/12/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ModifyType) {
    ModifyTypeNickName,
    ModifyTypeDeviceName,
    ModifyTypeFamilyName, //修改家庭名称
    ModifyTypeRoomName, //房间名称
    ModifyTypeAddRoom, //添加房间
};

typedef void(^ModifyNameBlock)(NSString *name);
typedef void(^AddRoomBlock)(NSDictionary *roomDic);

@interface TIoTModifyNameVC : UIViewController
@property (nonatomic, strong)NSString * titleText;
@property (nonatomic, strong)NSString * defaultText;
@property (nonatomic, assign)ModifyType modifyType;
@property (nonatomic, copy) ModifyNameBlock modifyNameBlock;

@property (nonatomic, copy) NSString *familyId; //添加房间时必须传递
@property (nonatomic, copy) AddRoomBlock addRoomBlock; //添加房间时候需要实现block  roomDic :@{"RoomName":@"",@"RoomId":@""}
@end

NS_ASSUME_NONNULL_END
