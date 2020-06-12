//
//Created by ESJsonFormatForMac on 19/12/27.
//

#import <Foundation/Foundation.h>


@interface RoomModel : NSObject

@property (nonatomic, assign) NSInteger UpdateTime;

@property (nonatomic, assign) NSInteger DeviceNum;

@property (nonatomic, assign) NSInteger CreateTime;

@property (nonatomic, copy) NSString *RoomId;

@property (nonatomic, copy) NSString *RoomName;

@end
