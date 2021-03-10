//
//  WCWebVC.h
//  TenextCloud
//
//  Created by Wp on 2019/12/19.
//  Copyright © 2019 Winext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN
@class TIoTWebVC;
typedef void(^requestTicketRefreshURL)(TIoTWebVC *webController);

@interface TIoTWebVC : UIViewController

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) NSString *urlPath;
@property (nonatomic,assign) BOOL needJudgeJump;//需要判断跳转
@property (nonatomic,assign) BOOL needRefresh;//刷新当前页

- (void)loadUrl:(NSString *)urlString;
//定点刷新评测内容
- (void)refushEvaluationContent;
- (void)appEventWithH5Response:(NSString *)event;

@property (nonatomic, strong) NSDictionary *sharedMessageDic;
@property (nonatomic, strong) NSString *sharedURLString;
@property (nonatomic, strong) NSString *sharedPathString;
@property (nonatomic, copy) requestTicketRefreshURL requestTicketRefreshURLBlock;

@property (nonatomic, strong) NSMutableDictionary *deviceDic;//h5自定义面板
@property (nonatomic, strong,readonly) WKWebView *webView;

/**
 蓝牙部分
 */

/// 设备列表
@property (nonatomic, strong) NSArray<CBPeripheral *>* peripheralDeviceArray;
/// 扫描蓝牙设备 自定义数据
@property (nonatomic, strong) NSMutableArray <NSMutableDictionary*>*peripheralInfoArray;
/// 蓝牙适配器是否可以 返回标志
@property (nonatomic, assign) BOOL adapterAvailable;
/// 蓝牙是否可用
@property (nonatomic, assign) BOOL bluetoothAvailable;

- (void)webViewInvokeJavaScript:(NSDictionary *)responseDic port:(NSString *)portString;

//转换
// NSData 转 16进制
- (NSString *)transformStringWithData:(NSData *)data;
/// 16进制 转 data
- (NSData *)convertHexStrToData:(NSString *)str;
//16进制字符串 获取外设Mac地址
- (NSString *)macAddressWith:(NSString *)aString;
@end

NS_ASSUME_NONNULL_END
