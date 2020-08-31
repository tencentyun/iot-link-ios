//
//  NSAttributedString+XDPAdd.h
//  SEEXiaodianpu
//
//  Created by seeweiting on 2019/3/6.
//  Copyright © 2019 黄锐灏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (XDPAdd)

/**
 Returns the height of the attributedString if it were rendered with the specified constraints.
 
 @param width  The maximum acceptable width for the attributedString. This value is used
 to calculate where line breaks and wrapping would occur.
 
 @return       The height of the resulting attributedString's bounding box. These values
 may be rounded up to the nearest whole number.
 */
- (CGFloat)heightForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
