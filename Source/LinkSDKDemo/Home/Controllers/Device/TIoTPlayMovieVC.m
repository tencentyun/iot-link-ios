//
//  TIoTPlayMovieVC.m
//  LinkSDKDemo
//
//  Created by eagleychen on 2021/1/19.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TIoTPlayMovieVC.h"
#import "LVRTSPPlayer.h"
#import "TIoTCoreXP2PBridge.h"

@interface TIoTPlayMovieVC ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic, strong) LVRTSPPlayer *video;
@property (nonatomic, strong) NSTimer *nextFrameTimer;
@end

@implementation TIoTPlayMovieVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configVideo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)configVideo {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width * 320 / 426)];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    self.imageView.userInteractionEnabled = YES;
    
    self.video = [[LVRTSPPlayer alloc] initWithVideo:self.videoUrl usesTcp:YES];
    self.video.outputWidth = 426;
    self.video.outputHeight = 320;
    
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo:nil
                                                          repeats:YES];
}


- (void)viewDidDisappear:(BOOL)animated {
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
}

-(void)displayNextFrame:(NSTimer *)timer{
    if (![self.video stepFrame]) {
        [timer invalidate];
        [self.video closeAudio];
        return;
    }
    self.imageView.image = self.video.currentImage;
}

- (void)stopPlayMovie {
    [_nextFrameTimer invalidate];
    self.nextFrameTimer = nil;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.video closeAudio];
    self.video = nil;
}

- (IBAction)sendFLV:(UIButton *)sender {
    
    if ([sender.currentTitle isEqualToString:@"开始对讲"]) {
        
        [sender setTitle:@"结束对讲" forState:UIControlStateNormal];
        [[TIoTCoreXP2PBridge sharedInstance] sendVoiceToServer];
    
    }else {
        
        [sender setTitle:@"开始对讲" forState:UIControlStateNormal];
        [[TIoTCoreXP2PBridge sharedInstance] stopVoiceToServer];
    }
    
}

- (IBAction)dismiss:(id)sender {
    [[TIoTCoreXP2PBridge sharedInstance] stopService];
    
    [self stopPlayMovie];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
