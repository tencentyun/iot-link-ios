//
//  FeedbackVC.m
//  QCFrameworkDemo
//
//

#import "FeedbackVC.h"


@interface FeedbackVC ()
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak, nonatomic) IBOutlet UITextField *contact;

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (IBAction)submit:(id)sender {
    
    if (self.content.hasText && self.url.hasText) {
        [[TIoTCoreAccountSet shared] setFeedbackWithText:self.content.text contact:self.contact.text ?: @"" imageURLs:@[self.url.text] success:^(id  _Nonnull responseObject) {
            [MBProgressHUD showSuccess:NSLocalizedString(@"feedback_success", @"反馈成功")];
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
        }];
    }
    
}



@end
