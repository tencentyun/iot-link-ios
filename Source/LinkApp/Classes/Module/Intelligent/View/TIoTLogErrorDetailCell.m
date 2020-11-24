//
//  TIoTLogErrorDetailCell.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/25.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTLogErrorDetailCell.h"
#import "UILabel+TIoTExtension.h"

@interface TIoTLogErrorDetailCell ()
@property (nonatomic, strong) UILabel   *errorTitle;
@property (nonatomic, strong) UILabel   *errorDetail;
@end

@implementation TIoTLogErrorDetailCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * kTIoTLogErrorDetailCellID = @"kTIoTLogErrorDetailCellID";
    TIoTLogErrorDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:kTIoTLogErrorDetailCellID];
    if (!cell) {
        cell = [[TIoTLogErrorDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTIoTLogErrorDetailCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubiewUI];
    }
    return self;
}

- (void)setupSubiewUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    
    self.errorDetail = [[UILabel alloc]init];
    [self.errorDetail setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#FA5151" textAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:self.errorDetail];
    [self.errorDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    self.errorTitle = [[UILabel alloc]init];
    [self.errorTitle setLabelFormateTitle:@"" font:[UIFont wcPfRegularFontOfSize:12] titleColorHexString:@"#6C7078" textAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.errorTitle];
    [self.errorTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.errorDetail.mas_left);
        
    }];
    
}

- (void)setResultModel:(TIoTActionResultsModel *)resultModel {
    _resultModel = resultModel;
    
    self.errorDetail.text = resultModel.Result;
    self.errorTitle.text = resultModel.deviceName;
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
