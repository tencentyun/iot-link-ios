//
//  UserVC.m
//  QCFrameworkDemo
//
//  Created by Wp on 2020/3/4.
//  Copyright © 2020 Reo. All rights reserved.
//

#import "UserVC.h"
#import "UserInfoVC.h"

#import <ifaddrs.h>
#import <sys/socket.h>
#import <arpa/inet.h>

#import "getgateway.h"


@interface UserVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic,strong) NSArray *titles;

@property (nonatomic,copy) NSMutableDictionary *tp2;

@end

@implementation UserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"poi"];
    self.table.tableFooterView = [UIView new];
    
    NSLog(@"网关==%f",[@"16.0" floatValue]);
    [self fork];
    
}
- (NSString *)getGateway
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    NSLog(@"本机地址：%@",address);
                    
                    //routerIP----192.168.1.255 广播地址
                    NSLog(@"广播地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    
                    //--255.255.255.0 子网掩码地址
                    NSLog(@"子网掩码地址：%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    
                    //--en0 接口
                    //  en0       Ethernet II    protocal interface
                    //  et0       802.3             protocal interface
                    //  ent0      Hardware device interface
                    NSLog(@"接口名：%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    in_addr_t i = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x = &i;
    unsigned char *s = getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    free(s);
    return ip;
}

- (void)fork
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSInteger success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Get NSString from C String
                NSString* ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                NSString* mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_netmask)->sin_addr)];
                NSString* gb = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_dstaddr)->sin_addr)];
                NSLog(@"%@;%@;%@;%@",ifaName,address,mask,gb);
            }
//            else if (temp_addr->ifa_addr->sa_family == AF_INET6)
//            {
//
//                struct sockaddr_in6 addr6,mask6,gateway6;
//                memcpy(&addr6, temp_addr->ifa_addr, sizeof(addr6));
//                memcpy(&mask6, temp_addr->ifa_netmask, sizeof(mask6));
////                memcpy(&gateway6, temp_addr->ifa_dstaddr, sizeof(gateway6));
//
//                char ip[INET6_ADDRSTRLEN],ip2[INET6_ADDRSTRLEN],ip3[INET6_ADDRSTRLEN];
//                inet_ntop(AF_INET6, &addr6.sin6_addr, ip, sizeof(ip));
//                inet_ntop(AF_INET6, &mask6.sin6_addr, ip2, sizeof(ip2));
//                inet_ntop(AF_INET6, &gateway6.sin6_addr, ip3, sizeof(ip3));
//
//                NSString* ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
//                NSString* address = [NSString stringWithUTF8String:ip];
//                NSString* mask = [NSString stringWithUTF8String:ip2];
//                NSString* gateway = [NSString stringWithUTF8String:ip3];
//                NSLog(@"6666==%@;%@;%@;%@",ifaName,address,mask,gateway);
//            }
            temp_addr = temp_addr->ifa_next;
        }
    }
}


#pragma mark -


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poi" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row][@"name"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController *vc = [[NSClassFromString(self.titles[indexPath.row][@"vc"]) alloc] init];
    vc.title = self.titles[indexPath.row][@"name"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getter

- (NSArray *)titles
{
    if (!_titles) {
        _titles = @[@{@"name":@"个人信息",@"vc":@"UserInfoVC"},
                    @{@"name":@"家庭管理",@"vc":@"WCFamiliesVC"},
                    @{@"name":@"消息通知",@"vc":@"MessageVC"},
                    @{@"name":@"意见反馈",@"vc":@"FeedbackVC"}];
    }
    return _titles;
}


@end
