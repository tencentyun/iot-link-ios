//
//  UIDevice+QCloudFCUUID.m
//
//  Created by Fabio Caccamo on 19/11/15.
//  Copyright © 2015 Fabio Caccamo. All rights reserved.
//

#import "UIDevice+QCloudFCUUID.h"

@implementation UIDevice (QCloudFCUUID)

-(NSString *)qcloud_uuid
{
    return [QCloudFCUUID uuidForDevice];
}

@end
