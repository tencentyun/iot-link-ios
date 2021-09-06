//
//  QCParts.h
//  QCAccount
//
//

#ifndef QCParts_h
#define QCParts_h

typedef void (^FRHandler)(NSString * _Nullable reason,NSError * _Nullable error, NSDictionary * _Nullable dic);
typedef void (^SRHandler)(id _Nonnull responseObject);
typedef void(^TIoTResult) (BOOL success, id _Nullable data);

#endif /* QCParts_h */
