//
//  WCDistributionNetCollectionViewCell.m
//  TenextCloud
//
//

#import "TIoTDistributionNetCollectionViewCell.h"

@interface TIoTDistributionNetCollectionViewCell()
@property (nonatomic,strong) UIImageView *imgView;
@end
@implementation TIoTDistributionNetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    self.alpha = 0.8;
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.layer.shadowRadius = 16;
    self.layer.shadowOpacity = 1;
    self.layer.cornerRadius = 10;
    
    self.imgView = [[UIImageView alloc] init];
    [self addSubview:_imgView];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(40);
        make.trailing.bottom.mas_equalTo(-40);
    }];
}

- (void)setImgName:(NSString *)imgName
{
    _imgName = imgName;
    [self.imgView setImage:[UIImage imageNamed:imgName]];
}

@end
