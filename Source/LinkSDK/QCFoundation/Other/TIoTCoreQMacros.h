//
//  QCMacros.h
//  QCAccount
//
//  Created by Wp on 2019/12/5.
//  Copyright © 2019 Reo. All rights reserved.
//

#ifndef QCMacros_h
#define QCMacros_h


#define kRGBAColor(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kRGBColor(r,g,b) kRGBAColor(r,g,b,1.0f)

#define kMainColor kRGBColor(0, 110, 255)
#define kBgColor kRGBColor(242, 242, 242)
#define kFontColor kRGBColor(51, 51, 51)


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "UIFont+TIoTFont.h"
#import "TIoTCoreWMacros.h"

#endif /* QCMacros_h */
