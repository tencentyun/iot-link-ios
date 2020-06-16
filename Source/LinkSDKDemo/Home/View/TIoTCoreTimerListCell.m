//
//  WCTimerListCell.m
//  TenextCloud
//
//  Created by Wp on 2020/1/10.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "WCTimerListCell.h"

@interface WCTimerListCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UISwitch *turn;


@end

@implementation WCTimerListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)statusChange:(UISwitch *)sender {
    [self update:sender.on];
}

- (void)update:(NSInteger)status
{
    if (_info) {
        
        [[QCDeviceSet shared] modifyTimerStatusWithTimerId:_info[@"TimerId"] productId:_info[@"ProductId"] deviceName:_info[@"DeviceName"] status:status success:^(id  _Nonnull responseObject) {
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
            
        }];
        
    }
    
}


- (void)setInfo:(NSDictionary *)info
{
    _info = info;
    self.name.text = info[@"TimerName"];
    self.detailL.text = [NSString stringWithFormat:@"%@ %@",[self getShowResultForRepeat:info[@"Days"]],info[@"TimePoint"]];
    self.turn.on = [info[@"Status"] boolValue];
}

- (NSString *)getShowResultForRepeat:(NSString *)days
{
    const char *repeats = [days UTF8String];
    
    NSString *con = @"";
    
    if ((BOOL)(repeats[1] - '0') == NO && (BOOL)(repeats[2] - '0') == NO && (BOOL)(repeats[3] - '0') == NO && (BOOL)(repeats[4] - '0') == NO && (BOOL)(repeats[5] - '0') == NO && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = @"周末";
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') == NO && (BOOL)(repeats[0] - '0') == NO) {
        con = @"工作日";
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = @"每天";
    }
    else
    {
        
        for (unsigned int i = 0; i < 7; i ++) {
            if ((BOOL)(repeats[i] - '0')) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = @"周日";
                        break;
                    case 1:
                        weakday = @"周一";
                        break;
                    case 2:
                        weakday = @"周二";
                        break;
                    case 3:
                        weakday = @"周三";
                        break;
                    case 4:
                        weakday = @"周四";
                        break;
                    case 5:
                        weakday = @"周五";
                        break;
                    case 6:
                        weakday = @"周六";
                        break;

                    default:
                        break;
                }

                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    return con;
}

@end
