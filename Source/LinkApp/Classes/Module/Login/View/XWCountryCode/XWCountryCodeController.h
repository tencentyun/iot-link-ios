//
//  XWCountryCodeController.h
//  XWCountryCodeDemo
//
//  国家代码选择界面

#import <UIKit/UIKit.h>

typedef void(^returnCountryCodeBlock) (NSString *countryName, NSString *code);

@protocol XWCountryCodeControllerDelegate <NSObject>

@optional

/**
 Delegate 回调所选国家代码

 @param countryName 所选国家
 @param code 所选国家代码
 */
-(void)returnCountryName:(NSString *)countryName code:(NSString *)code;

@end


@interface XWCountryCodeController : UIViewController

@property (nonatomic, weak) id<XWCountryCodeControllerDelegate> deleagete;

@property (nonatomic, copy) returnCountryCodeBlock returnCountryCodeBlock;

@end
