//
//  WCPopoverVC.m
//  TenextCloud
//
//  Created by Wp on 2020/1/11.
//  Copyright © 2020 Winext. All rights reserved.
//

#import "TIoTPopoverVC.h"
#import "FamilyModel.h"

static NSString *cellId = @"ry4555";
@interface TIoTPopoverVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TIoTPopoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
}


#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.families) {
        return self.families.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyModel *model = self.families[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = model.FamilyName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.update) {
        self.update(indexPath.row);
    }
}


@end
