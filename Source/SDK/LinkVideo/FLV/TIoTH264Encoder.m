
#import "TIoTH264Encoder.h"
#define MAX_BITRATE_LENGTH 500000
@implementation TIoTH264Encoder

{
    NSString * yuvFile;
    VTCompressionSessionRef EncodingSession;
    dispatch_queue_t aQueue;
    CMFormatDescriptionRef  format;
    CMSampleTimingInfo * timingInfo;
    BOOL initialized;
    int  frameCount;
    NSData *sps;
    NSData *pps;
    
    int _width;
    int _height;
}
@synthesize error;

- (void) initWithConfiguration
{
    
    EncodingSession = nil;
    initialized = true;
    aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    frameCount = 0;
    sps = NULL;
    pps = NULL;
    
}

void didCompressH264(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags,
                     CMSampleBufferRef sampleBuffer )
{
    //    NSLog(@"didCompressH264 called with status %d infoFlags %d", (int)status, (int)infoFlags);
    if (status != 0) return;
    
    if (!CMSampleBufferDataIsReady(sampleBuffer))
    {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
    TIoTH264Encoder* encoder = (__bridge TIoTH264Encoder*)outputCallbackRefCon;
    
    // Check if we have got a key frame first
    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    
    if (keyframe)
    {
        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
        // CFDictionaryRef extensionDict = CMFormatDescriptionGetExtensions(format);
        // Get the extensions
        // From the extensions get the dictionary with key "SampleDescriptionExtensionAtoms"
        // From the dict, get the value for the key "avcC"
        
        size_t sparameterSetSize, sparameterSetCount;
        const uint8_t *sparameterSet;
        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
        if (statusCode == noErr)
        {
            // Found sps and now check for pps
            size_t pparameterSetSize, pparameterSetCount;
            const uint8_t *pparameterSet;
            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
            if (statusCode == noErr)
            {
                // Found pps
                encoder->sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
                encoder->pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
                if (encoder->_delegate)
                {
                    [encoder->_delegate gotSpsPps:encoder->sps pps:encoder->pps];
                }
            }
        }
    }
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t length, totalLength;
    char *dataPointer;
    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
    if (statusCodeRet == noErr) {
        
        size_t bufferOffset = 0;
        static const int AVCCHeaderLength = 4;
        while (bufferOffset < totalLength - AVCCHeaderLength) {
            
            // Read the NAL unit length
            uint32_t NALUnitLength = 0;
            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
            
            // Convert the length value from Big-endian to Little-endian
            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
            
            NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
            [encoder->_delegate gotEncodedData:data isKeyFrame:keyframe];
            
            // Move to the next NAL unit in the block buffer
            bufferOffset += AVCCHeaderLength + NALUnitLength;
        }
        
    }
    
}

- (void) initEncode:(int)width  height:(int)height
{
    _width = width;
    _height = height;
    
    dispatch_sync(aQueue, ^{
        
        // For testing out the logic, lets read from a file and then send it to encoder to create h264 stream
        
        // Create the compression session
        OSStatus status = VTCompressionSessionCreate(NULL, width, height, kCMVideoCodecType_H264, NULL, NULL, NULL, didCompressH264, (__bridge void *)(self),  &EncodingSession);
        NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
        
        if (status != 0)
        {
            NSLog(@"H264: Unable to create a H264 session");
            error = @"H264: Unable to create a H264 session";
            
            return ;
            
        }
        
        // Set the properties
        // 设置实时编码输出（避免延迟）
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);

        //关闭B帧
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
        
        // 设置关键帧（GOPsize)间隔
        int frameInterval = 60;
        CFNumberRef  frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
        
        
        // 设置关键帧（GOPsize)间隔
        int frameDur = 4;
        CFNumberRef  frameDurRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameDur);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration, frameDurRef);
        
        // 设置期望帧率
        int fps = 15;
        CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
        
        
        //设置码率，均值，单位是bits per second
//        int bitRate = width * height * 60;
//        int bitRate = 300000;
        int bitRate = width * height;
        if (bitRate > MAX_BITRATE_LENGTH) {
            bitRate = MAX_BITRATE_LENGTH;
        }
        _encoderBitrateBps = bitRate;
        CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
        
        //设置码率，上限1.1倍平均码率，单位是bytes         1 Byte = 8 Bits
        NSArray *bitRateLimit = @[@(bitRate * 1.1 / 8),@(1)];
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)bitRateLimit);
            
        // Tell the encoder to start encoding
        VTCompressionSessionPrepareToEncodeFrames(EncodingSession);
    });
}

- (void)setEncoderBitrateBps:(uint32_t)bitRate {
    
    if ((bitRate > _width * _height) || (bitRate < 10000) || (_encoderBitrateBps == bitRate) || (bitRate > MAX_BITRATE_LENGTH)) {
        return;
    }
    
    _encoderBitrateBps = bitRate;
    CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
    VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
    
    //设置码率，上限1.1倍平均码率，单位是bytes         1 Byte = 8 Bits
    NSArray *bitRateLimit = @[@(bitRate * 1.1 / 8),@(1)];
    VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFArrayRef)bitRateLimit);
}

- (void) encode:(CMSampleBufferRef )sampleBuffer
{
    if (EncodingSession == NULL) {
        NSLog(@"EncodingSession is null");
        return;
    }
    dispatch_sync(aQueue, ^{
        
        frameCount++;
        // Get the CV Image buffer
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // Create properties
        CMTime presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//        CMTime presentationTimeStamp = CMTimeMake(frameCount, 1000);
        CMTime duration = CMTimeMake(1, 15);
//        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
//        NSLog(@"presentationTimeStamp === %lld, scale === %d, flag === %d, epoch === %lld", presentationTimeStamp.value, presentationTimeStamp.timescale, presentationTimeStamp.flags, presentationTimeStamp.epoch);
        VTEncodeInfoFlags flags;
        
        // Pass it to the encoder
        OSStatus statusCode = VTCompressionSessionEncodeFrame(EncodingSession,
                                                              imageBuffer,
                                                              presentationTimeStamp,
                                                              kCMTimeInvalid,
                                                              NULL, NULL, &flags);
        // Check for error
        if (statusCode != noErr) {
            NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
            error = @"H264: VTCompressionSessionEncodeFrame failed ";
            
            if (statusCode == kVTInvalidSessionErr || statusCode == kVTParameterErr) {
                //kVTInvalidSessionErr = -12903Session失效 ，reset session
                [self End];
                [self initEncode:480 height:640];
            }

            return;
        }
    });
    
    
}


- (void) End
{
    // Mark the completion
    VTCompressionSessionCompleteFrames(EncodingSession, kCMTimeInvalid);
    
    // End the session
    VTCompressionSessionInvalidate(EncodingSession);
    CFRelease(EncodingSession);
    EncodingSession = NULL;
    error = NULL;
    
}

@end
