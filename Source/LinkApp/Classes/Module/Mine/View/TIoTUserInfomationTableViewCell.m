//
//  WCUserInfomationTableViewCell.m
//  TenextCloud
//
//

#import "TIoTUserInfomationTableViewCell.h"

@interface TIoTUserInfomationTableViewCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *valueLab;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) MASConstraint *rightValueConstraint;
@property (nonatomic, strong) MASConstraint *rightImageConstraint;
@end

@implementation TIoTUserInfomationTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
//    static NSString *ID = @"TIoTUserInfomationTableViewCell";
    TIoTUserInfomationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[TIoTUserInfomationTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID
                ];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.textColor = [UIColor blackColor];
        self.titleLab.font = [UIFont wcPfRegularFontOfSize:14];
        [self.contentView addSubview:self.titleLab];
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
//            make.width.mas_equalTo(150);
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = kRGBColor(242, 244, 245);
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLab);
            make.bottom.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(0);
            make.height.mas_equalTo(1);
        }];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mineArrow"]];
        [self.contentView addSubview:self.arrowImageView];
        [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLab);
            make.right.equalTo(self.contentView).offset(-20);
            make.height.width.mas_equalTo(18);
        }];
        
        
        self.arrowSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 30, 50)];
        [self.arrowSwitch addTarget:self action:@selector(openAuth:) forControlEvents:UIControlEventValueChanged];
        self.arrowSwitch.hidden = YES;
        [self.contentView addSubview:self.arrowSwitch];
        [self.arrowSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-16);
        }];
        
        self.valueLab = [[UILabel alloc] init];
        self.valueLab.textColor = [UIColor colorWithHexString:kPhoneEmailHexColor];
        self.valueLab.font = [UIFont wcPfRegularFontOfSize:14];
        [self.contentView addSubview:self.valueLab];
        [self.valueLab mas_makeConstraints:^(MASConstraintMaker *make) {
            self.rightValueConstraint = make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.valueLab.mas_left);
        }];
        
        //国际化
        self.iconImageView = [[UIImageView alloc]init];
        self.iconImageView.layer.cornerRadius = 12;
        self.iconImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.rightImageConstraint = make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.height.width.mas_equalTo(24);
        }];
    }
    return self;
}

- (void)setDic:(NSDictionary *)dic{
    _dic = dic;
    
    self.titleLab.text = dic[@"title"]?:@"";
    self.valueLab.text = dic[@"value"]?:@"";
    if ([dic[@"haveArrow"] isEqualToString:@"1"]) {
        self.arrowImageView.hidden = NO;
    }else if ([dic[@"haveArrow"] isEqualToString:@"2"]) {
        self.arrowImageView.hidden = YES;
        self.arrowSwitch.hidden = NO;
    }
    else{
        self.arrowImageView.hidden = YES;
        [self.rightImageConstraint setOffset:20];
        [self.rightValueConstraint setOffset:20];
    }
    
    //国际化
    if ([NSString isNullOrNilWithObject:dic[@"Avatar"]]) {
        self.iconImageView.hidden = YES;
        self.valueLab.hidden = NO;
    }else {
        [self.iconImageView setImageWithURLStr:[TIoTCoreUserManage shared].avatar placeHolder:@"icon-avatar_man"];
        self.iconImageView.hidden = NO;
        self.valueLab.hidden = YES;
    }
    
    if ([dic[@"title"]?:@"" isEqualToString: NSLocalizedString(@"user_ID", @"用户ID")]) {
        self.valueLab.textColor = [UIColor colorWithHexString:kRegionHexColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)openAuth:(UISwitch *)sender {
    if (self.authSwitch) {
        self.authSwitch(sender.on);
    }
}
@end
