//
//  WCPhotoCell.m
//  TenextCloud
//
//

#import "TIoTPhotoCell.h"

@interface TIoTPhotoCell()
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end
@implementation TIoTPhotoCell

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
