
#import "TIoTPCMXEchoRecord.h"

#include <thread>
#include <queue>
#include <memory>

#import <AudioUnit/AudioUnit.h>

@interface TIoTPCMXEchoRecord()
{
    AudioUnit audioUnit;
    std::queue<std::pair<std::shared_ptr<char>, int>> queue;
    std::mutex mutex;
    RecordCallback callback;
    void *user;
}

@end
@implementation TIoTPCMXEchoRecord
- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    AudioComponentDescription des;
    des.componentFlags = 0;
    des.componentFlagsMask = 0;
    des.componentManufacturer = kAudioUnitManufacturer_Apple;
    des.componentType = kAudioUnitType_Output;
    des.componentSubType = kAudioUnitSubType_VoiceProcessingIO; //kAudioUnitSubType_RemoteIO;
    
    AudioComponent audioComponent;
    audioComponent = AudioComponentFindNext(NULL, &des);
    OSStatus ret = AudioComponentInstanceNew(audioComponent, &audioUnit);
    if (ret != noErr)
        return nil;
    
    AudioStreamBasicDescription outStreamDes;
    outStreamDes.mSampleRate = 16000;
    outStreamDes.mFormatID = kAudioFormatLinearPCM;
    outStreamDes.mFormatFlags = kAudioFormatFlagIsSignedInteger;
    outStreamDes.mFramesPerPacket = 1;
    outStreamDes.mChannelsPerFrame = 1;
    outStreamDes.mBitsPerChannel = 16;
    outStreamDes.mBytesPerFrame = 2;
    outStreamDes.mBytesPerPacket = 2;
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
    
    return self;
}

#define kTVURecoderPCMMaxBuffSize 2048
static int          pcm_buffer_size = 0;
static uint8_t      pcm_buffer[kTVURecoderPCMMaxBuffSize*2];

static OSStatus record_callback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrame, AudioBufferList *__nullable ioData)
{
    TIoTPCMXEchoRecord *r = (__bridge TIoTPCMXEchoRecord *)(inRefCon);

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
    
//    if (size > 0 && src)
//    {
//        char *dst = (char*)calloc(1, size);
//        memcpy(dst, src, size);
//        if (r->callback)
//            r->callback(dst, size, r->user);
//    }
    
    // 由于PCM转成AAC的转换器每次需要有1024个采样点（每一帧2个字节）才能完成一次转换，所以每次需要2048大小的数据，这里定义的pcm_buffer用来累加每次存储的bufferData
    memcpy(pcm_buffer+pcm_buffer_size, bufferData, bufferSize);
    pcm_buffer_size = pcm_buffer_size + bufferSize;
    
    if(pcm_buffer_size >= kTVURecoderPCMMaxBuffSize) {
        if (r->callback)
            r->callback(pcm_buffer, pcm_buffer_size, r->user);
        
        // 因为采样不可能每次都精准的采集到1024个样点，所以如果大于2048大小就先填满2048，剩下的跟着下一次采集一起送给转换器
        memcpy(pcm_buffer, pcm_buffer + kTVURecoderPCMMaxBuffSize, pcm_buffer_size - kTVURecoderPCMMaxBuffSize);
        pcm_buffer_size = pcm_buffer_size - kTVURecoderPCMMaxBuffSize;
    }
    
    return error;
}

OSStatus outputRender_cb(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    return noErr;
}

- (void)start_record
{
    AudioOutputUnitStart(audioUnit);
}

- (void)stop_record
{
    AudioOutputUnitStop(audioUnit);
    std::unique_lock<std::mutex> lock(mutex);
    decltype(queue) empty;
    std::swap(empty, queue);
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
}
@end
