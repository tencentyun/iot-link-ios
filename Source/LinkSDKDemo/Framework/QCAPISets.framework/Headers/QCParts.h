//
//  QCParts.h
//  QCAccount
//
//  Created by Wp on 2020/2/27.
//  Copyright © 2020 Reo. All rights reserved.
//

#ifndef QCParts_h
#define QCParts_h

typedef void (^FRHandler)(NSString * _Nullable reason,NSError * _Nullable error);
typedef void (^SRHandler)(id _Nonnull responseObject);
typedef void(^Result) (BOOL success, id _Nullable data);

#endif /* QCParts_h */
