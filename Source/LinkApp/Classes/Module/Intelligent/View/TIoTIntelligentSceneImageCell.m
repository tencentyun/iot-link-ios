//
//  TIoTIntelligentSceneImageCell.m
//  LinkApp
//
//  Created by ccharlesren on 2021/2/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTIntelligentSceneImageCell.h"

@interface TIoTIntelligentSceneImageCell ()
@property (nonatomic, strong) UIImageView *sceneImageView;
@end

@implementation TIoTIntelligentSceneImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUIViews];
    }
    return self;
}

- (void)setUIViews {
    self.sceneImageView = [[UIImageView alloc]init];
    self.sceneImageView.layer.cornerRadius = 8.0;
    self.sceneImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.sceneImageView];
    [self.sceneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self);
    }];
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    [self.sceneImageView setImageWithURLStr:self.imageUrl?:@""];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.sceneImageView.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
        self.sceneImageView.layer.borderWidth = 2;
    }else {
        self.sceneImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.sceneImageView.layer.borderWidth = 0.0;
    }
}

@end
