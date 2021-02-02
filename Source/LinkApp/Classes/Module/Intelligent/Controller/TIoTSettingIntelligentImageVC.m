//
//  TIoTSettingIntelligentImageVC.m
//  LinkApp
//
//  Created by ccharlesren on 2020/11/4.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TIoTSettingIntelligentImageVC.h"
#import "TIoTIntelligentSceneImageCell.h"
#import "UIButton+LQRelayout.h"
#import "TIoTUIProxy.h"

static NSString * const kIntelligentSceneImageCellID = @"kIntelligentSceneImageCellID";

@interface TIoTSettingIntelligentImageVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) UIButton *saveImageButton;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat kButtonWidth;
@property (nonatomic, assign) CGFloat kButtonHeight;
@property (nonatomic, assign) CGFloat kPadding;
@property (nonatomic, assign) CGFloat kInterval;
@end

@implementation TIoTSettingIntelligentImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self requestImageSceneList];
}

- (void)requestImageSceneList {
    [[TIoTRequestObject shared] get:TIoTAPPConfig.intelligentSceneImageList success:^(id responseObject) {
        self.imageArray = [responseObject yy_modelToJSONObject];
        [self.collectionView reloadData];
    } failure:^(NSString *reason, NSError *error, NSDictionary *dic) {
        
    }];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
    self.title = NSLocalizedString(@"choose_Intelligent_Image", @"选择智能图片");
    
    self.kButtonWidth = 107 * kScreenAllWidthScale;
    self.kButtonHeight = 54 * kScreenAllHeightScale;
    self.kPadding = 15 * kScreenAllWidthScale;
    self.kInterval = 12 * kScreenAllHeightScale;
    
    self.saveImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveImageButton setButtonFormateWithTitlt:NSLocalizedString(@"save", @"保存") titleColorHexString:@"ffffff" font:[UIFont wcPfRegularFontOfSize:16]];
    [self.saveImageButton setBackgroundColor:[UIColor colorWithHexString:kIntelligentMainHexColor]];
    self.saveImageButton.layer.cornerRadius = 20;
    [self.saveImageButton addTarget:self action:@selector(saveSelectedImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveImageButton];
    [self.saveImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(40);
        
        if ([TIoTUIProxy shareUIProxy].iPhoneX) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_bottom).offset(-[UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom);
            }else {
                make.bottom.equalTo(self.view.mas_bottom).offset(-20);
            }
        }else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.leading.equalTo(self.view);
        make.bottom.equalTo(self.saveImageButton.mas_top);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_bottom).offset(64);
        }
    }];
    
}

- (void)selectedSceneBackImage:(UIButton *)sender {
    for (int i = 101; i<109; i++) {
        if (sender.tag == i) {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i];
            btn.layer.borderColor = [UIColor colorWithHexString:kIntelligentMainHexColor].CGColor;
            btn.layer.borderWidth = 2;
        }else {
            UIButton *btn = (UIButton *)[self.view viewWithTag:i];
            btn.layer.borderColor = [UIColor clearColor].CGColor;
            btn.layer.borderWidth = 0.0;
        }
    }
    
     self.number = sender.tag -101;
    
}

- (void)saveSelectedImage {
    
    if (self.selectedIntelligentImageBlock) {
        
        self.selectedIntelligentImageBlock(self.imageArray[self.number]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TIoTIntelligentSceneImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIntelligentSceneImageCellID forIndexPath:indexPath];
    cell.imageUrl = self.imageArray[indexPath.row];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.number = indexPath.row;
    
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat itemWidth = self.kButtonWidth;
        CGFloat itemHeight = self.kButtonHeight;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(20, self.kPadding, self.kInterval, self.kPadding);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor colorWithHexString:kBackgroundHexColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[TIoTIntelligentSceneImageCell class] forCellWithReuseIdentifier:kIntelligentSceneImageCellID];
    }
    return _collectionView;
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
