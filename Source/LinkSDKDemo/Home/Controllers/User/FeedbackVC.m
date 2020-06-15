//
//  FeedbackVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/6.
//  Copyright © 2020 Reo. All rights reserved.
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
        [[QCAccountSet shared] setFeedbackWithText:self.content.text contact:self.contact.text ?: @"" imageURLs:@[self.url.text] success:^(id  _Nonnull responseObject) {
            [MBProgressHUD showSuccess:@"反馈成功"];
        } failure:^(NSString * _Nullable reason, NSError * _Nullable error) {
            [MBProgressHUD showError:reason];
        }];
    }
    
}



@end
