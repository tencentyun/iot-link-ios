//
//  WCTimerListCell.m
//  TenextCloud
//
//

#import "TIoTCoreTimerListCell.h"

@interface TIoTCoreTimerListCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UISwitch *turn;


@end

@implementation TIoTCoreTimerListCell

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
        
        [[TIoTCoreDeviceSet shared] modifyTimerStatusWithTimerId:_info[@"TimerId"] productId:_info[@"ProductId"] deviceName:_info[@"DeviceName"] status:status success:^(id  _Nonnull responseObject) {
            
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            
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
        con = NSLocalizedString(@"weekend", @"周末");
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') == NO && (BOOL)(repeats[0] - '0') == NO) {
        con = NSLocalizedString(@"work_day", @"工作日");
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con =NSLocalizedString(@"everyday", @"每天");
    }
    else
    {
        
        for (unsigned int i = 0; i < 7; i ++) {
            if ((BOOL)(repeats[i] - '0')) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = NSLocalizedString(@"sunday", @"周日");
                        break;
                    case 1:
                        weakday = NSLocalizedString(@"monday", @"周一") ;
                        break;
                    case 2:
                        weakday = NSLocalizedString(@"tuesday", @"周二");
                        break;
                    case 3:
                        weakday = NSLocalizedString(@"wednesday", @"周三");
                        break;
                    case 4:
                        weakday = NSLocalizedString(@"thursday", @"周四");
                        break;
                    case 5:
                        weakday = NSLocalizedString(@"friday", @"周五");
                        break;
                    case 6:
                        weakday = NSLocalizedString(@"saturday", @"周六");
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
