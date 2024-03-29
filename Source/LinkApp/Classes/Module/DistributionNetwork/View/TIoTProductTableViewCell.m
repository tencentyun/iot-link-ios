//
//  WCProductTableViewCell.m
//  TenextCloud
//
//

#import "TIoTProductTableViewCell.h"

@interface TIoTProductTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation TIoTProductTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"TIoTProductTableViewCell";
    TIoTProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTProductTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = kRGBColor(248, 248, 248);
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(self.contentView).offset(9);
            make.bottom.equalTo(self.contentView).offset(-9);
        }];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:16];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.text = @"MN583_15A2";
        [bgView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bgView).offset(15);
            make.centerY.top.equalTo(bgView);
            make.width.mas_equalTo(150);
        }];
        
        UIButton *connBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [connBtn setTitle:@"连接" forState:UIControlStateNormal];
        [connBtn setTitleColor:kRGBColor(0, 110, 255) forState:UIControlStateNormal];
        connBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [connBtn addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
        connBtn.enabled = NO;
        [bgView addSubview:connBtn];
        [connBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(bgView);
            make.width.mas_equalTo(59.5);
        }];
    }
    return self;
}

#pragma mark - event
- (void)connect {
    DDLogVerbose(@"连接");
    if (self.connectEvent) {
        self.connectEvent();
    }
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"title"]?:@"";
}

@end
