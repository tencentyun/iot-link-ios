#import "TIoTAACEncoder.h"

typedef struct {
    //pcm数据指针
    void *source;
    //pcm数据的长度
    UInt32 sourceSize;
    //声道数
    UInt32 channelCount;
    AudioStreamPacketDescription *packetDescription;
}FillComplexInputParm;

typedef struct {
    AudioConverterRef converter;
    int samplerate;
    int channles;
}ConverterContext;

//AudioConverter的提供数据的回调函数
OSStatus audioConverterComplexInputDataProc(AudioConverterRef inAudioConverter,UInt32 *ioNumberDataPacket,AudioBufferList *ioData,AudioStreamPacketDescription **outDataPacketDescription,void *inUserData) {
    //ioData用来接收需要转换的pcm数据給converter进行编码
    FillComplexInputParm *param = (FillComplexInputParm *)inUserData;
//    NSLog(@"ccccccccccc----->%d, ssss---->%d, cocococo--->%d",*ioNumberDataPacket, param->sourceSize,param->channelCount);
    if (param->sourceSize <= 0) {
        *ioNumberDataPacket = 0;
        return -1;
    }
    ioData->mBuffers[0].mData = param->source;
    ioData->mBuffers[0].mDataByteSize = param->sourceSize;
    ioData->mBuffers[0].mNumberChannels = param->channelCount;
    *ioNumberDataPacket = param->sourceSize/2;
    param->sourceSize = 0;
    return noErr;
}

@interface TIoTAACEncoder () {
    ConverterContext *convertContext;
    dispatch_queue_t encodeQueue;
    AudioStreamBasicDescription inAudioStreamBasicDescription;
}
@end

@implementation TIoTAACEncoder

- (instancetype)initWithAudioDescription:(AudioStreamBasicDescription)inAudioDes {
    if ( self = [super init]) {
        encodeQueue = dispatch_queue_create("com.audio.encode", DISPATCH_QUEUE_SERIAL);
        inAudioStreamBasicDescription = inAudioDes;
    }
    return self;
}

- (void)setUpConverter {
    //开始构造输出的asbd
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0};
    //对于压缩格式必须设置为0
    outAudioStreamBasicDescription.mBitsPerChannel = 0;
    outAudioStreamBasicDescription.mBytesPerFrame = 0;
    outAudioStreamBasicDescription.mFramesPerPacket = 1024;
    //设定声道数为1
    outAudioStreamBasicDescription.mChannelsPerFrame = inAudioStreamBasicDescription.mChannelsPerFrame;
    //设定采样率为16000
//    outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;
    if (self.audioType == TIoTAVCaptionFLVAudio_8) {
        outAudioStreamBasicDescription.mSampleRate = 8000;
    }else if (self.audioType == TIoTAVCaptionFLVAudio_16) {
        outAudioStreamBasicDescription.mSampleRate = 16000;
    }
    //设定输出音频的格式
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
    outAudioStreamBasicDescription.mReserved = 0;
    //填充输出的音频格式
    UInt32 size = sizeof(outAudioStreamBasicDescription);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &outAudioStreamBasicDescription);
    //选择aac的编码器（用来描述一个已经安装的编解码器）
    AudioClassDescription audioClassDes;
    //初始化为0
    memset(&audioClassDes, 0, sizeof(audioClassDes));
    //获取满足要求的aac编码器的总大小
    UInt32 countSize = 0;
    AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(outAudioStreamBasicDescription.mFormatID), &outAudioStreamBasicDescription.mFormatID, &countSize);
    //用来计算aac的编解码器的个数
    int cout = countSize/sizeof(audioClassDes);
    //创建一个包含有cout个数的编码器数组
    AudioClassDescription descriptions[cout];
    //将编码器数组信息写入到descriptions中
    AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(outAudioStreamBasicDescription.mFormatID), &outAudioStreamBasicDescription.mFormatID, &countSize, descriptions);
    for (int i = 0; i < cout; cout++) {
        AudioClassDescription temp = descriptions[i];
        if (temp.mManufacturer==kAppleSoftwareAudioCodecManufacturer
            &&temp.mSubType==outAudioStreamBasicDescription.mFormatID) {
            audioClassDes = temp;
            break;
        }
    }
    //创建convertcontext用来保存converter的信息
    ConverterContext *context = malloc(sizeof(ConverterContext));
    self->convertContext = context;
    
    OSStatus result = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, &audioClassDes, &(context->converter));
    if (result == noErr) {
        //创建编解码器成功
//        AudioConverterRef converter = context->converter;
//        //设置编码器属性
//        UInt32 temp = kAudioConverterQuality_Max;
//        AudioConverterSetProperty(converter, kAudioConverterCodecQuality, sizeof(temp), &temp);
//        //设置比特率
//        UInt32 bitRate = 64000;
//        result = AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate, sizeof(bitRate), &bitRate);
//        if (result != noErr) {
            NSLog(@"设置比特率成功");
//        }
    }else{
        //创建编解码器失败
        free(context);
        context = NULL;
        NSLog(@"创建编解码器失败");
    }
}

//编码samplebuffer数据
-(void)encodePCMData:(NSData *)pcmdata {
    if (!self->convertContext) {
        [self setUpConverter];
    }
    ConverterContext *cxt = self->convertContext;
    if (cxt && cxt->converter) {

//        dispatch_async(encodeQueue, ^{

            NSUInteger pcmLength = pcmdata.length;
            void *pcmData = pcmdata.bytes;
            
            if (pcmdata == nil) {
                NSLog(@"获取pcm数据失败");
                return;
            } else {
                //在堆区分配内存用来保存编码后的aac数据
                char *outputBuffer = malloc(pcmLength);
                memset(outputBuffer, 0, pcmLength);
                UInt32 packetSize = 1;
                AudioStreamPacketDescription *outputPacketDes = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) *packetSize);
                //使用fillcomplexinputparm来保存pcm数据
                FillComplexInputParm userParam;
                userParam.source = pcmData;
                userParam.sourceSize = (UInt32)pcmLength;
                userParam.channelCount = self->inAudioStreamBasicDescription.mChannelsPerFrame;
                userParam.packetDescription = NULL;
                //在堆区创建audiobufferlist
                AudioBufferList outputBufferList;
                outputBufferList.mNumberBuffers = 1;
                outputBufferList.mBuffers[0].mData = outputBuffer;
                outputBufferList.mBuffers[0].mDataByteSize = (UInt32)pcmLength;
                outputBufferList.mBuffers[0].mNumberChannels = self->inAudioStreamBasicDescription.mChannelsPerFrame;
                //编码
                OSStatus status = AudioConverterFillComplexBuffer(self->convertContext->converter, audioConverterComplexInputDataProc, &userParam, &packetSize, &outputBufferList, outputPacketDes);
                free(outputPacketDes);
                outputPacketDes = NULL;
                if (status == noErr) {
                    //获取原始的aac数据
                    NSData *rawAAC = [NSData dataWithBytes:outputBufferList.mBuffers[0].mData length:outputBufferList.mBuffers[0].mDataByteSize];
                    NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
                    NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
                    [fullData appendData:rawAAC];
                    [self.delegate getEncoderAACData:fullData];
                }
                free(outputBuffer);
                outputBuffer = NULL;
            }
//        });
    }
}


- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self->convertContext) {
        inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
        [self setUpConverter];
    }
    CFRetain(sampleBuffer);
    dispatch_async(encodeQueue, ^{
        
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        size_t pcmLength;
        char *pcmData = NULL;
        CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &pcmLength, &pcmData);
        if (pcmLength == 0 || !pcmData) {
            return;
        }
        
        
        
        //在堆区分配内存用来保存编码后的aac数据
        char *outputBuffer = malloc(pcmLength);
        memset(outputBuffer, 0, pcmLength);
        UInt32 packetSize = 1;
        AudioStreamPacketDescription *outputPacketDes = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) *packetSize);
        //使用fillcomplexinputparm来保存pcm数据
        FillComplexInputParm userParam;
        userParam.source = pcmData;
        userParam.sourceSize = (UInt32)pcmLength;
        userParam.channelCount = 1;
        userParam.packetDescription = NULL;
        //在堆区创建audiobufferlist
        AudioBufferList outputBufferList;
        outputBufferList.mNumberBuffers = 1;
        outputBufferList.mBuffers[0].mData = outputBuffer;
        outputBufferList.mBuffers[0].mDataByteSize = (UInt32)pcmLength;
        outputBufferList.mBuffers[0].mNumberChannels = 1;
        //编码
        OSStatus status = AudioConverterFillComplexBuffer(self->convertContext->converter, audioConverterComplexInputDataProc, &userParam, &packetSize, &outputBufferList, outputPacketDes);
        free(outputPacketDes);
        outputPacketDes = NULL;
        if (status == noErr) {
            //获取原始的aac数据
            NSData *rawAAC = [NSData dataWithBytes:outputBufferList.mBuffers[0].mData length:outputBufferList.mBuffers[0].mDataByteSize];
            NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
            NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
            [fullData appendData:rawAAC];
            [self.delegate getEncoderAACData:fullData];
        }
        free(outputBuffer);
        outputBuffer = NULL;
        
        
        
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
    });
}


#pragma mark - HEADER
/**
 *  Add ADTS header at the beginning of each and every AAC packet.
 *  This is needed as MediaCodec encoder generates a packet of raw
 *  AAC data.
 *
 *  Note the packetLen must count in the ADTS header itself.
 *  See: http://wiki.multimedia.cx/index.php?title=ADTS
 *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
 **/
- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 8;//16KHz
    if (self.audioType == TIoTAVCaptionFLVAudio_8) {
        freqIdx = 11;
    }else if (self.audioType == TIoTAVCaptionFLVAudio_16) {
        freqIdx = 8;
    }
//    else if (self.audioType == TIoTAVCaptionFLVAudio_441) {
//        freqIdx = 4;
//    }
    int chanCfg = inAudioStreamBasicDescription.mChannelsPerFrame;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = (char)0xFF; // 11111111     = syncword
    packet[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}
@end
