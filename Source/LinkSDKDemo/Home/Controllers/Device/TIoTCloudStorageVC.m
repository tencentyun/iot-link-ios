//
//  TIoTCloudStorageVC.m
//  LinkSDKDemo
//
//  Created by ccharlesren on 2021/1/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTCloudStorageVC.h"
#import "TIoTCustomCalendar.h"

@interface TIoTCloudStorageVC ()

@end

@implementation TIoTCloudStorageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUIViews];
}

- (void)setupUIViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *calendarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    calendarBtn.frame = CGRectMake(kScreenWidth/2 - 50, kScreenHeight/2 - 50,100, 60);
    [calendarBtn setTitle:@"日历" forState:UIControlStateNormal];
    calendarBtn.layer.borderColor = [UIColor blueColor].CGColor;
    calendarBtn.layer.borderWidth = 1;
    [calendarBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [calendarBtn addTarget:self action:@selector(chooseDate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:calendarBtn];
}

- (void)chooseDate {
    TIoTCustomCalendar *view = [[TIoTCustomCalendar alloc] initCalendarFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 470)];
    [self.view addSubview:view];
    view.selectedDateBlock = ^(NSString *dateString) {
        NSLog(@"%@",dateString);
    };
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
