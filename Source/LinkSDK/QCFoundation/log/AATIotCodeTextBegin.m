//
//  CodeTextBegin.m
//  QCloudSDK
//
//  Created by Larry Tin on 2020/4/22.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIoTCodeAddress.h"
#import <mach-o/dyld.h>
#import <mach-o/loader.h>

// 返回这个方法的地址
extern void * getSDKStartAddress(void) {
    return &getSDKStartAddress;
}

// 获取可执行模块的slide
extern long getExecuteImageSlide(void) {
    long slide = -1;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return slide;
}
