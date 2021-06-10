//
//  SGQRCodeObtainConfigure.m
//  SGQRCodeExample
//
//

#import "SGQRCodeObtainConfigure.h"

@implementation SGQRCodeObtainConfigure

+ (instancetype)QRCodeObtainConfigure {
    return [[self alloc] init];
}

- (NSString *)sessionPreset {
    if (!_sessionPreset) {
        _sessionPreset = AVCaptureSessionPreset1920x1080;
    }
    return _sessionPreset;
}

- (NSArray *)metadataObjectTypes {
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    return _metadataObjectTypes;
}

@end
