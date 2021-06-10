//
//  ESPAES.h
//  EspTouchDemo
//
//

#import <Foundation/Foundation.h>

@interface ESPAES : NSObject {
    @private NSString *key;
}

- (instancetype)initWithKey:(NSString *)secretKey;

- (NSData *)AES128EncryptData:(NSData *)data;
- (NSData *)AES128DecryptData:(NSData *)data;

@end
