//
//  TIoTAreaNetworkDeviceCell.m
//  LinkSDKDemo
//

#import "TIoTAreaNetworkDeviceCell.h"

@interface TIoTAreaNetworkDeviceCell ()
@property (nonatomic, strong) UILabel *areaTitle;
@property (nonatomic, strong) UILabel *areaSubtitle;
@property (nonatomic, strong) UIButton *previewButton;
@end

@implementation TIoTAreaNetworkDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUISunViews];
    }
    return self;
}

- (void)setupUISunViews {
    self.areaTitle = [[UILabel alloc]init];
    [self.areaTitle setLabelFormateTitle:@"testTitle" font:[UIFont wcPfRegularFontOfSize:15] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.areaTitle];
    [self.areaTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.right.mas_equalTo(-kScreenWidth/5);
    }];
    
    self.areaSubtitle = [[UILabel alloc]init];
    [self.areaSubtitle setLabelFormateTitle:@"testSubTiele" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#A1A7B2" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.areaSubtitle];
    [self.areaSubtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.areaTitle.mas_bottom);
        make.left.right.equalTo(self.areaTitle);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
    }];

    self.previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.previewButton setButtonFormateWithTitlt:@"预览" titleColorHexString:@"#0066FF" font:[UIFont wcPfRegularFontOfSize:14]];
    [self.previewButton addTarget:self action:@selector(previewAreaNetWorkLive) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.previewButton];
    [self.previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.top.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(50);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)previewAreaNetWorkLive {
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewAreaNetworkDetectDevice:)]) {
        [self.delegate previewAreaNetworkDetectDevice:_rspDetectionDeviceModel];
    }
}

- (void)setRspDetectionDeviceModel:(TIoTAreaNetDetectionModel *)rspDetectionDeviceModel {
    _rspDetectionDeviceModel = rspDetectionDeviceModel;
    self.areaTitle.text = rspDetectionDeviceModel.params.deviceName?:@"";
    self.areaSubtitle.text = rspDetectionDeviceModel.params.port?:@"";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
