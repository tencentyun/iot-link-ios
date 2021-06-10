//
//  WCBaseBigBtnView.h
//  TenextCloud
//
//

#import <UIKit/UIKit.h>


@interface TIoTBaseBigBtnView : UIView

@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic, copy) void (^update)(NSDictionary *uploadInfo);

@end

