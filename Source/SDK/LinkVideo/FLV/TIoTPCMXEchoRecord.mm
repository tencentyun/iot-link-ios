
#import "TIoTPCMXEchoRecord.h"

#include <thread>
#include <queue>
#include <memory>

#import <AudioUnit/AudioUnit.h>

@interface TIoTPCMXEchoRecord()
{
    AudioUnit audioUnit;
    RecordCallback callback;
    void *user;
}

@end

@implementation TIoTPCMXEchoRecord
- (instancetype)initWithChannel:(int)channel isEcho:(BOOL)isEcho
{
    self = [super init];
    if (!self) return nil;
    
    AudioComponentDescription des;
    des.componentFlags = 0;
    des.componentFlagsMask = 0;
    des.componentManufacturer = kAudioUnitManufacturer_Apple;
    des.componentType = kAudioUnitType_Output;
    if (isEcho) {
        des.componentSubType = kAudioUnitSubType_VoiceProcessingIO; //kAudioUnitSubType_RemoteIO;
    }else {
        des.componentSubType = kAudioUnitSubType_RemoteIO;
    }
    
    AudioComponent audioComponent;
    audioComponent = AudioComponentFindNext(NULL, &des);
    OSStatus ret = AudioComponentInstanceNew(audioComponent, &audioUnit);
    if (ret != noErr)
        return nil;
    
    AudioStreamBasicDescription outStreamDes;
    if (@available(iOS 18.0, *)) {
        outStreamDes.mSampleRate = 48000;
        outStreamDes.mFormatFlags = kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
        
    }else {
        outStreamDes.mSampleRate = 16000;
        outStreamDes.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    }
    outStreamDes.mFormatID = kAudioFormatLinearPCM;
    outStreamDes.mFramesPerPacket = 1;
    outStreamDes.mChannelsPerFrame = channel;
    outStreamDes.mBitsPerChannel = 16;
    outStreamDes.mBytesPerFrame = 2 * channel;
    outStreamDes.mBytesPerPacket = 2 * channel;
    outStreamDes.mReserved = 0;
    _pcmStreamDescription = outStreamDes;
    
    UInt32 flags = 1;
    ret = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flags, sizeof(flags));
    if (ret != noErr)
        return nil;
    
    ret = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &outStreamDes, sizeof(outStreamDes));
    if (ret != noErr)
        return nil;
    
    AURenderCallbackStruct callback;
    callback.inputProc = record_callback;
    callback.inputProcRefCon = (__bridge void * _Nullable)(self);
    ret = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &callback, sizeof(callback));
    if (ret != noErr)
        return nil;

    AURenderCallbackStruct output;
    output.inputProc = outputRender_cb;
    output.inputProcRefCon = (__bridge void *)(self);
    ret = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &output, sizeof(output));
    if (ret != noErr)
        return nil;
    
    AudioUnitInitialize(audioUnit);
    return self;
}

TPCircularBuffer pcm_circularBuffer;

/**
 * 线性插值法重采样 48000Hz -> 16000Hz
 * 转换比例 3:1，适合实时处理
 */
uint8_t bufferData16[8192];
- (void)resample48000To16000_Linear:(int16_t *)input
                            output:(int16_t *)output
                       inputFrames:(UInt32)inputFrames
                      outputFrames:(UInt32 *)outputFrames {
    
    float ratio = 48000.0f / 16000.0f; // 3.0
    *outputFrames = (UInt32)(inputFrames / ratio);
    
    for (UInt32 i = 0; i < *outputFrames; i++) {
        float inputIndex = i * ratio;
        UInt32 index1 = (UInt32)inputIndex;
        UInt32 index2 = MIN(index1 + 1, inputFrames - 1);
        float fraction = inputIndex - index1;
        
        // 线性插值
        float sample1 = input[index1];
        float sample2 = input[index2];
        float interpolated = sample1 + (sample2 - sample1) * fraction;
        
        output[i] = (int16_t)interpolated;
    }
}

static OSStatus record_callback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrame, AudioBufferList *__nullable ioData)
{
    TIoTPCMXEchoRecord *r = (__bridge TIoTPCMXEchoRecord *)(inRefCon);
    int channel = r->_pcmStreamDescription.mChannelsPerFrame;

    AudioBufferList list;
    list.mNumberBuffers = 1;
    list.mBuffers[0].mData = NULL;
    list.mBuffers[0].mDataByteSize = 0;
    list.mBuffers[0].mNumberChannels = 1;
    
    OSStatus error = AudioUnitRender(r->audioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrame, &list);
    if (error != noErr)
        NSLog(@"record_callback error : %d", error);
    
    UInt32   bufferSize = list.mBuffers[0].mDataByteSize;
    uint8_t *bufferData = (uint8_t *)list.mBuffers[0].mData;
//    NSLog(@"record_callback__________size : %d", bufferSize);
    if (@available(iOS 18.0, *)) {
        UInt32 bufferData16Size = 0;
        [r resample48000To16000_Linear:(int16_t *)bufferData output:(int16_t *)bufferData16 inputFrames:bufferSize outputFrames:&bufferData16Size];
        [r addData:&pcm_circularBuffer :bufferData16 :bufferData16Size];
        if (r->callback)
            r->callback(bufferData16, bufferData16Size, r->user);
    }else{
        [r addData:&pcm_circularBuffer :bufferData :bufferSize];
        if (r->callback)
            r->callback(bufferData, bufferSize, r->user);
    }
    
    return error;
}

OSStatus outputRender_cb(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    return noErr;
}

- (void)start_record
{
    [self Init_buffer:&pcm_circularBuffer :8192];
    AudioOutputUnitStart(audioUnit);
}

- (void)stop_record
{
    AudioOutputUnitStop(audioUnit);
    [self Destory_buffer:&pcm_circularBuffer];
}

- (void)set_record_callback:(RecordCallback)c user:(nonnull void *)u
{
    callback = c;
    user = u;
}

- (void)dealloc
{
    callback = NULL;
    user = NULL;
    [self stop_record];
    AudioComponentInstanceDispose(audioUnit);
}



-(BOOL) Init_buffer:(TPCircularBuffer*)buffer_ :(UInt32)size_
{
     return TPCircularBufferInit(buffer_, size_ );
}

-(void) Destory_buffer:(TPCircularBuffer*)buffer_
{
    TPCircularBufferCleanup(buffer_ );
}

-(UInt32)addData:(TPCircularBuffer*)buffer_ :(void *)buf_ :(UInt32)size_
{
    uint32_t availableBytes = 0;
    TPCircularBufferHead(buffer_, &availableBytes);
    if (availableBytes <= 0)
          return 0;
     
    UInt32 len =  (availableBytes >= size_ ? size_ : availableBytes);
    TPCircularBufferProduceBytes(buffer_, (void*)buf_, size_);
    return len;
}

-(UInt32)getData:(TPCircularBuffer*)buffer_ :(void *)buf_ :(UInt32)size_
{
    uint32_t availableBytes = 0;
    void *bufferTail = TPCircularBufferTail(buffer_, &availableBytes);
    if (availableBytes >= size_)
    {
        UInt32 len = 0;
        len = (size_ > availableBytes ? availableBytes : size_);
        memcpy(buf_, bufferTail, len);
        TPCircularBufferConsume(buffer_, len);
//        NSLog(@"ggggggggggg=====len = %ld", len);
        return len;
    }
    return 0;
}

@end
