

#import "AWAACEncoder.h"

typedef struct {
    //pcm数据指针
    void *source;
    //pcm数据的长度
    UInt32 sourceSize;
    //声道数
    UInt32 channelCount;
    //输入的pcm的包大小
    UInt32 inBytesPerPacket;
    
    AudioStreamPacketDescription *packetDescription;
}FillComplexInputParm;

typedef struct {
    AudioConverterRef converter;
    int samplerate;
    int channles;
    UInt32 inBytesPerPacket;
}ConverterContext;

//AudioConverter的提供数据的回调函数
OSStatus audioConverterComplexInputDataProc(AudioConverterRef inAudioConverter,UInt32 *ioNumberDataPacket,AudioBufferList *ioData,AudioStreamPacketDescription **outDataPacketDescription,void *inUserData) {
    //ioData用来接收需要转换的pcm数据給converter进行编码
    FillComplexInputParm *param = (FillComplexInputParm *)inUserData;
    if (param->sourceSize <= 0) {
        *ioNumberDataPacket = 0;
        return -1;
    }
    
    ioData->mBuffers[0].mData = param->source;
    ioData->mBuffers[0].mDataByteSize = param->sourceSize;
    ioData->mBuffers[0].mNumberChannels = param->channelCount;

    *ioNumberDataPacket = param->sourceSize/param->inBytesPerPacket;
    param->sourceSize = 0;
    return noErr;
}

@interface AWAACEncoder () {
    ConverterContext *convertContext;
    dispatch_queue_t encodeQueue;
}

@end
@implementation AWAACEncoder

- (void) dealloc {
    AudioConverterDispose(convertContext->converter);
}

- (instancetype)init {
    if ( self = [super init]) {
        encodeQueue = dispatch_queue_create("tiotaacencoder", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setUpConverter:(CMSampleBufferRef)sampleBuffer {
    //获取audioformat的描述信息
    CMAudioFormatDescriptionRef audioFormatDes =  (CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer);
    //获取输入的asbd的信息
    AudioStreamBasicDescription inAudioStreamBasicDescription = *(CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDes));
    NSLog(@"pcm_audio_description_sample_rate ===> %f, channels ===> %d, bytesPerPacket ===> %d", inAudioStreamBasicDescription.mSampleRate, inAudioStreamBasicDescription.mChannelsPerFrame, inAudioStreamBasicDescription.mBytesPerPacket);
    
    //开始构造输出的asbd
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0};
    //对于压缩格式必须设置为0
    outAudioStreamBasicDescription.mBitsPerChannel = 0;
    outAudioStreamBasicDescription.mBytesPerFrame = 0;
    outAudioStreamBasicDescription.mBytesPerPacket = 0;
    outAudioStreamBasicDescription.mReserved = 0;
    //设定声道数为1
    outAudioStreamBasicDescription.mChannelsPerFrame = 1;
    //
    outAudioStreamBasicDescription.mFramesPerPacket = 1024;
    //设定采样率为16000
    outAudioStreamBasicDescription.mSampleRate = self.sample_rate;
    //设定输出音频的格式
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC;
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC;
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
    context->inBytesPerPacket = inAudioStreamBasicDescription.mBytesPerPacket;
    self->convertContext = context;
    OSStatus result = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, &audioClassDes, &(context->converter));
    if (result == noErr) {
        /*//创建编解码器成功
        AudioConverterRef converter = context->converter;
        //设置编码器属性
        UInt32 temp = kAudioConverterQuality_Low;
        AudioConverterSetProperty(converter, kAudioConverterCodecQuality, sizeof(temp), &temp);
        //设置比特率,需要注意，AAC并不是随便的码率都可以支持。比如如果PCM采样率是44100KHz，那么码率可以设置64000bps，如果是16K，可以设置为32000bps。
        UInt32 bitRate = 32000;
        if (self.sample_rate == 44100) {
            bitRate = 64000;//bps
        }else if (self.sample_rate == 16000) {
            bitRate = 32000;
        }else {
            return;
        }
        result = AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate, sizeof(bitRate), &bitRate);
        if (result != noErr) {
            NSLog(@"设置比特率失败");
        }*/
    }else{
        //创建编解码器失败
        free(context);
        context = NULL;
        NSLog(@"创建编解码器失败");
    }
}

//编码samplebuffer数据
- (void)encodeSmapleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (!self->convertContext) {
        [self setUpConverter:sampleBuffer];
    }
    ConverterContext *cxt = self->convertContext;
    if (cxt && cxt->converter) {
        //从samplebuffer中提取数据
        CFRetain(sampleBuffer);
        dispatch_async(encodeQueue, ^{
            //从samplebuffer中获取blockbuffer
            CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
            size_t pcmLength = 0;
            char *pcmData = NULL;
            //获取blockbuffer中的pcm数据的指针和长度
            OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &pcmLength, &pcmData);
            if (status != noErr) {
                NSLog(@"从block中获取pcm数据失败");
                CFRelease(sampleBuffer);
                return;
            } else {
//                if (pcmLength == 0 || pcmData == NULL || pcmData[0] == '\0') {
//                    NSLog(@"无效数据");
//                    return;
//                }
                //在堆区分配内存用来保存编码后的aac数据
                char *outputBuffer = malloc(pcmLength);
                memset(outputBuffer, 0, pcmLength);
                UInt32 packetSize = 1;
                AudioStreamPacketDescription *outputPacketDes = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription) *packetSize);
                
                //使用fillcomplexinputparm来保存pcm数据
                FillComplexInputParm userParam = {0};
                userParam.source = pcmData;
                userParam.sourceSize = (UInt32)pcmLength;
                userParam.channelCount = 1;
                userParam.inBytesPerPacket = cxt->inBytesPerPacket;
                userParam.packetDescription = NULL;
                            
                //在堆区创建audiobufferlist
                AudioBufferList outputBufferList;
                outputBufferList.mNumberBuffers = 1;
                outputBufferList.mBuffers[0].mData = outputBuffer;
                outputBufferList.mBuffers[0].mDataByteSize = (unsigned int)pcmLength;
                outputBufferList.mBuffers[0].mNumberChannels = 1;
                //编码
                status = AudioConverterFillComplexBuffer(self->convertContext->converter, audioConverterComplexInputDataProc, &userParam, &packetSize, &outputBufferList, outputPacketDes);
                free(outputPacketDes);
                outputPacketDes = NULL;
                if (status == noErr) {
//                    NSLog(@"编码成功");
                    //获取原始的aac数据
                    NSData *rawAAC = [NSData dataWithBytes:outputBufferList.mBuffers[0].mData length:outputBufferList.mBuffers[0].mDataByteSize];
                    free(outputBuffer);
                    outputBuffer = NULL;
                    //设置adts头
                    NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
                    NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
                    [fullData appendData:rawAAC];
                    
                    //发送数据
                    [self.delegate sendData:fullData];
                    
                    fullData = nil;
                    rawAAC = nil;
                }else {
//                    NSLog(@"pcm转aac失败，无效数据不影响");
                }
                free(outputBuffer);
                CFRelease(sampleBuffer);
            }
        });
    }
}



#pragma mark - HEADER
- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 4;  //44.1KHz
    if (_sample_rate == 44100) {
        freqIdx = 4;
    }else if (_sample_rate == 16000) {
        freqIdx = 8;
    }else if (_sample_rate == 8000) {
        freqIdx = 11;
    }
    /* 其中，samplingFreguencyIndex 对应关系如下：
    0 - 96000
    1 - 88200
    2 - 64000
    3 - 48000
    4 - 44100
    5 - 32000
    6 - 24000
    7 - 22050
    8 - 16000
    9 - 12000
    10 - 11025
    11 - 8000
    12 - 7350
    13 - Reserved
    14 - Reserved
    15 - frequency is written explictly
*/
    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
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
