//
//  TIoTAVP2PPlayCaptureVC.m
//  LinkApp
//

#import "TIoTAVP2PPlayCaptureVC.h"

#import "AWAVCaptureManager.h"

@implementation TIoTVideoDeviceCollectionView

@end

@interface TIoTAVP2PPlayCaptureVC ()<AWAVCaptureDelegate>
//按钮
@property (nonatomic, strong) UIButton *startCapture;
@property (nonatomic, strong) UIButton *switchCameras;
//预览
@property (nonatomic, strong) UIView *previewBottomView;
@property (nonatomic, strong) AWAVCaptureManager *avCaptureManager;

@end

@implementation TIoTAVP2PPlayCaptureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
}

-(void) setupUI{
    
    [self.previewBottomView addSubview: self.avCapture.preview];
    
    self.avCapture.preview.center = self.previewBottomView.center;
    
    self.startCapture = [[UIButton alloc] init];
    [self.startCapture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startCapture setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    self.startCapture.backgroundColor = [UIColor blackColor];
    [self.startCapture setTitle:@"开始" forState:UIControlStateNormal];
    [self.startCapture addTarget:self action:@selector(onStartClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startCapture];
    
    self.startCapture.layer.borderWidth = 0.5;
    self.startCapture.layer.borderColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] CGColor];
    self.startCapture.layer.cornerRadius = 5;
    
    self.switchCameras = [[UIButton alloc] init];
    UIImage *switchImage = [self imageWithPath:@"" scale:2];
    switchImage = [switchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.switchCameras setImage:switchImage forState:UIControlStateNormal];
    [self.switchCameras setTintColor:[UIColor whiteColor]];
    [self.switchCameras addTarget:self action:@selector(onSwitchClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.switchBtn];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    self.startCapture.frame = CGRectMake(40, screenSize.height - 150 - 40, screenSize.width - 80, 40);
    
    self.switchCameras.frame = CGRectMake(screenSize.width - 30 - self.switchCameras.currentImage.size.width, 130, self.switchCameras.currentImage.size.width, self.switchCameras.currentImage.size.height);
    
//    self.preview.frame = self.view.bounds;
//    self.avCapture.preview.frame = self.preview.bounds;
}

-(UIImage *)imageWithPath:(NSString *)path scale:(CGFloat)scale{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:path ofType:nil];
    if (imagePath) {
        NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData scale:scale];
            return image;
        }
    }
    
    return nil;
}

#pragma mark 事件

-(void)onStartClick{
    if (self.avCapture.isCapturing) {
        [self.startCapture setTitle:@"开始" forState:UIControlStateNormal];
        [self.avCapture stopCapture];
    }else{
        if ([self.avCapture startCapture]) {
            [self.startCapture setTitle:@"停止" forState:UIControlStateNormal];
        }
    }
}

- (void)open {
    [self.avCapture startCapture];
}

- (void)close {
    [self.avCapture stopCapture];
}

-(void)onSwitchClick{
    [self.avCapture switchCamera];
}

-(void)capture:(uint8_t *)data len:(size_t)size {
    
}

-(void)avCapture:(uint8_t *)data len:(size_t)size {
    
}

#pragma mark 懒加载
-(AWAVCaptureManager *)avCaptureManager{
    if (!_avCaptureManager) {
        _avCaptureManager = [[AWAVCaptureManager alloc] init];
        //必须设置采样类型
        _avCaptureManager.captureType = AWAVCaptureTypeSystem;
        _avCaptureManager.audioEncoderType = AWAudioEncoderTypeHWAACLC;
        _avCaptureManager.videoEncoderType = AWVideoEncoderTypeHWH264;
        _avCaptureManager.audioConfig = [[AWAudioConfig alloc] init];
        _avCaptureManager.videoConfig = [[AWVideoConfig alloc] init];
        
        [_avCaptureManager setCaptureManagerPreviewFrame:CGRectMake(100, 100, 350, 200)];
        
        //设置竖屏
        _avCaptureManager.videoConfig.orientation = UIInterfaceOrientationPortrait;
    }
    return _avCaptureManager;
}

-(AWAVCapture *)avCapture{
    AWAVCapture *capture = self.avCaptureManager.avCapture;
    capture.delegate = self;
    return capture;
}

-(UIView *)previewBottomView{
    if (!_previewBottomView) {
        _previewBottomView = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_previewBottomView];
        [self.view sendSubviewToBack:_previewBottomView];
    }
    return _previewBottomView;
}
@end
