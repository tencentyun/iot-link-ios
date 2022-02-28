//
//  TIoTDemoPlaybackCustomCell.m
//  LinkSDKDemo
//
//

#import "TIoTDemoLocalDayCustomCell.h"
#import "UIImageView+TIoTDemoWebImage.h"
#import "NSString+Extension.h"

@interface TIoTDemoLocalDayCustomCell ()
@property (nonatomic, strong) UIView *contentCustomView;
@property (nonatomic, strong) UILabel *eventTimeabel;
@property (nonatomic, strong) UILabel *eventDescribe;
@property (nonatomic, strong) UIButton *eventThumb;
@property (nonatomic, strong) UIImageView *thumbActionImage;
@end

@implementation TIoTDemoLocalDayCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCellViews];
    }
    return self;
}

- (void)setupCellViews {
    
    CGFloat kWidthPadding = 16;
    CGFloat kTopPadding = 4;
    CGFloat kContentHeight = 76;
    CGFloat kTopThumbPadding = 10;
    CGFloat kThumbWidth = 100;
    CGFloat kThumbHeight = kContentHeight-2*kTopThumbPadding;
    
    self.contentView.backgroundColor = [UIColor colorWithHexString:KActionSheetBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentCustomView = [[UIView alloc]init];
    self.contentCustomView.backgroundColor = [UIColor whiteColor]
    ;    [self.contentView addSubview:self.contentCustomView];
    [self.contentCustomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kTopPadding);
        make.left.equalTo(self.contentView.mas_left).offset(kWidthPadding);
        make.right.equalTo(self.contentView.mas_right).offset(-kWidthPadding);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kTopPadding);
    }];
    
    self.eventTimeabel = [[UILabel alloc]init];
    [self.eventTimeabel setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:17] titleColorHexString:@"#000000" textAlignment:NSTextAlignmentLeft];
    [self.contentCustomView addSubview:self.eventTimeabel];
    [self.eventTimeabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentCustomView);
        make.left.equalTo(self.contentCustomView.mas_left).offset(kWidthPadding);
    }];
    
    self.eventDescribe = [[UILabel alloc]init];
    [self.eventDescribe setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:14] titleColorHexString:kVideoDemoTextContentColor textAlignment:NSTextAlignmentLeft];
    [self.contentCustomView addSubview:self.eventDescribe];
    [self.eventDescribe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.eventTimeabel.mas_right).offset(8);
        make.centerY.equalTo(self.contentCustomView);
        make.right.equalTo(self.contentCustomView.mas_right).offset(2*kWidthPadding+100);
    }];
    
    self.eventThumb = [[UIButton alloc]init];
    [self.eventThumb setBackgroundImage:[UIImage imageNamed:@"res_download"] forState:UIControlStateNormal];
    [self.eventThumb addTarget:self action:@selector(downLoadCell) forControlEvents:UIControlEventTouchUpInside];
    [self.contentCustomView addSubview:self.eventThumb];
    [self.eventThumb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentCustomView);
        make.right.equalTo(self.contentCustomView.mas_right).offset(-kWidthPadding);
        make.width.height.mas_equalTo(32);
    }];
    
    /*self.eventThumb = [[UIImageView alloc]init];
    self.eventThumb.backgroundColor = [UIColor blackColor];
    [self.contentCustomView addSubview:self.eventThumb];
    [self.eventThumb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentCustomView.mas_right).offset(-kWidthPadding);
        make.top.equalTo(self.contentCustomView.mas_top).offset(kTopThumbPadding);
        make.width.mas_equalTo(kThumbWidth);
        make.height.mas_equalTo(kThumbHeight);
    }];
    
    self.thumbActionImage = [[UIImageView alloc]init];
    self.thumbActionImage.image = [UIImage imageNamed:@"thumbImage_action"];
    [self.eventThumb addSubview:self.thumbActionImage];
    [self.thumbActionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.eventThumb);
        make.width.height.mas_equalTo(32);
    }];*/
    
}

- (void)downLoadCell {
    if ([self.delegate respondsToSelector:@selector(downLoadResWithModel:)]) {
        [self.delegate downLoadResWithModel:_model];
    }
}

- (void)setModel:(TIoTDemoLocalFileModel *)model {
    _model = model;
    /*NSString *timeString = [NSString convertTimestampToTime:model.start_time?:@"" byDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *dayTime = [timeString componentsSeparatedByString:@" "].lastObject;
    NSString *hourString = [dayTime componentsSeparatedByString:@":"].firstObject;
    NSString *minuteString = [dayTime componentsSeparatedByString:@":"][1];
    self.eventTimeabel.text = [NSString stringWithFormat:@"%@:%@",hourString,minuteString];
    self.eventDescribe.text = model.file_name?:@"";*/
    
    NSString *startString = [NSString convertTimestampToTime:model.start_time?:@"" byDateFormat:@"HH:mm:ss"];
    NSString *endString = [NSString convertTimestampToTime:model.end_time?:@"" byDateFormat:@"HH:mm:ss"];
    self.eventTimeabel.text = [NSString stringWithFormat:@"%@ - %@",startString,endString];
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
