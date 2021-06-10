//
//  WaveView.h
//  MemoryProgress
//
//

#import <UIKit/UIKit.h>


@interface CHDWaveView : UIView
/**
 *  进度 0-1
 */
@property (nonatomic,assign)CGFloat progress;

/**
 *  波动速度，默认 1
 */
@property (nonatomic,assign)CGFloat speed;

/**
 *  波纹填充颜色
 */
@property (nonatomic,strong)UIColor * firstWaveColor;
@property (nonatomic,strong)UIColor * secondWaveColor;

/**
 *  波动幅度，默认 5
 */
@property (nonatomic,assign)CGFloat waveHeight;

/**
 *  进度文字
 */
@property (nonatomic,strong)UILabel * progressLabel;
@property (nonatomic,strong)UILabel * fpsLabel;

/**
 *  是否显示单层波浪，默认NO
 */
@property (nonatomic,assign)BOOL isShowSingleWave;
@end
