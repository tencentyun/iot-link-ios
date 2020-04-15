//
//  WCPhotoCell.m
//  TenextCloud
//
//  Created by Wp on 2019/11/27.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCPhotoCell.h"

@interface WCPhotoCell()
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end
@implementation WCPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)clearSelf:(UIButton *)sender {
    if (self.deleteTap) {
        self.deleteTap();
    }
}

- (void)setHiddenDeleteBtn:(BOOL)hiddenDeleteBtn
{
    self.deleteBtn.hidden = hiddenDeleteBtn;
}

@end
