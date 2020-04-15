//
//  NSTimer+BlockSupport.h
//  SEEXiaodianpu
//
//  Created by seeweiting on 2019/3/2.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (BlockSupport)

+ (instancetype)xdp_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
