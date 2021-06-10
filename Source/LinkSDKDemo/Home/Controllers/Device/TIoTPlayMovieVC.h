//
//  TIoTPlayMovieVC.h
//  LinkSDKDemo
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TIotPLayType) {
    TIotPLayTypeLive,
    TIotPLayTypePlayback,
};

@interface TIoTPlayMovieVC : UIViewController

@property (nonatomic, strong)NSString *deviceName;
@property (nonatomic, strong)NSString *videoUrl;
@property (nonatomic, assign)TIotPLayType playType;
@end

NS_ASSUME_NONNULL_END
