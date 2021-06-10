//
//  ControlInfo.h
//  QCFrameworkDemo
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ControlInfo : NSObject

//@property (nonatomic,copy) NSString *theme;
@property (nonatomic,copy) NSDictionary *navBar;
@property (nonatomic,assign) BOOL timingProject;

@property (nonatomic,copy) NSMutableArray *zipData;
@end

NS_ASSUME_NONNULL_END
