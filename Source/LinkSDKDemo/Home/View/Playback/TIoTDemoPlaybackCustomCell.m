//
//  TIoTDemoPlaybackCustomCell.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/6/5.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTDemoPlaybackCustomCell.h"

@interface TIoTDemoPlaybackCustomCell ()
@property (nonatomic, strong) UIView *contentCustomView;
@property (nonatomic, strong) UILabel *eventTimeabel;
@property (nonatomic, strong) UILabel *eventDescribe;
@property (nonatomic, strong) UIImageView *eventThumb;
@end

@implementation TIoTDemoPlaybackCustomCell

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
    
    self.contentCustomView = [[UILabel alloc]init];
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
    
    self.eventThumb = [[UIImageView alloc]init];
    self.eventThumb.backgroundColor = [UIColor blackColor];
    [self.contentCustomView addSubview:self.eventThumb];
    [self.eventThumb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentCustomView.mas_right).offset(-kWidthPadding);
        make.top.equalTo(self.contentCustomView.mas_top).offset(kTopThumbPadding);
        make.width.mas_equalTo(kThumbWidth);
        make.height.mas_equalTo(kThumbHeight);
    }];
    
    
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
