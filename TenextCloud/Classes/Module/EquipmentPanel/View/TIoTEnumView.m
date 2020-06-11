//
//  WCEnumView.m
//  TenextCloud
//
//  Created by Wp on 2019/12/31.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "TIoTEnumView.h"
#import "TIoTEnumItem.h"

static NSString *itemId = @"gggddd";

@interface TIoTEnumView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UIImageView *bgView;
@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UILabel *contentLab;
@property (nonatomic,strong) UICollectionView *coll;

@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,copy) NSString *currentValue;
@property (nonatomic,weak) NSIndexPath *currentIndexPath;
@end

@implementation TIoTEnumView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUIForLarge];
    }
    return self;
}


- (void)setupUIForLarge
{
    [self addSubview:self.bgView];
    
    UILabel *titlab = [[UILabel alloc] init];
    titlab.text = @" ";
    titlab.textColor = kFontColor;
    titlab.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    [self addSubview:titlab];
    self.nameLab = titlab;
    [titlab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    
    UILabel *colorLab = [[UILabel alloc] init];
    colorLab.text = @" ";
    colorLab.textColor = kFontColor;
    colorLab.font = [UIFont systemFontOfSize:36 weight:UIFontWeightMedium];
    [self addSubview:colorLab];
    self.contentLab = colorLab;
    [colorLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titlab.mas_bottom).offset(20);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(110, 150);
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    UICollectionView *col = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    col.delegate = self;
    col.dataSource = self;
    col.backgroundColor = [UIColor clearColor];
    [self addSubview:col];
    self.coll = col;
    [col mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorLab.mas_bottom).offset(40);
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(150);
        make.bottom.mas_equalTo(-40);
    }];
    
    [col registerNib:[UINib nibWithNibName:@"TIoTEnumItem" bundle:nil] forCellWithReuseIdentifier:itemId];
}


#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray) {
        return self.dataArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TIoTEnumItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemId forIndexPath:indexPath];
    
    if ([self.currentValue isEqualToString:self.dataArray[indexPath.row][@"value"]]) {
        self.currentIndexPath = indexPath;
        cell.isSelected = YES;
    }
    else
    {
        cell.isSelected = NO;
    }
    cell.name = self.dataArray[indexPath.row][@"title"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.currentValue isEqualToString:self.dataArray[indexPath.row][@"value"]]) {
        self.currentValue = self.dataArray[indexPath.row][@"value"];
        [collectionView reloadItemsAtIndexPaths:@[self.currentIndexPath,indexPath]];
        if (self.update) {
            self.update(@{self.info[@"id"]:@([self.currentValue integerValue])});
        }
    }
}


#pragma mark -

- (void)setInfo:(NSDictionary *)info
{
    [super setInfo:info];
    self.nameLab.text = info[@"name"];
    NSString *key = [NSString stringWithFormat:@"%@",info[@"status"][@"Value"]];
    self.currentValue = key;
    
    NSDictionary *map = info[@"define"][@"mapping"];
    self.contentLab.text = map[key];
    
    NSMutableArray *source = [NSMutableArray arrayWithCapacity:map.count];
    for (int i = 0; i < map.count; i ++) {
        NSDictionary *obj = @{@"title":map[[NSString stringWithFormat:@"%i",i]],@"value":[NSString stringWithFormat:@"%i",i]};
        [source addObject:obj];
    }
    self.dataArray = source;
    [self reloadColletion:source];
    
}

- (void)setStyle:(WCThemeStyle)style
{
    if (style == WCThemeSimple) {
        self.bgView.hidden = YES;
        self.nameLab.textColor = kFontColor;
        self.contentLab.textColor = kFontColor;
    }
    else if (style == WCThemeStandard)
    {
        self.bgView.hidden = YES;
        self.nameLab.textColor = [UIColor whiteColor];
        self.contentLab.textColor = [UIColor whiteColor];
    }
    else if (style == WCThemeDark)
    {
        self.nameLab.textColor = [UIColor whiteColor];
        self.contentLab.textColor = [UIColor whiteColor];
    }
}

- (UIImageView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_enum"]];
        _bgView.frame = CGRectMake(0, 0, kScreenWidth, 400);
    }
    return _bgView;
}

#pragma mark -

- (void)reloadColletion:(NSArray *)datas
{
    if (datas.count > 0) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.coll.collectionViewLayout;
        CGFloat contentWidth = datas.count * layout.itemSize.width + layout.minimumLineSpacing * (datas.count - 1);
        if (contentWidth + layout.sectionInset.left + layout.sectionInset.right < kScreenWidth) {
            CGFloat space = (kScreenWidth - contentWidth) * 0.5;
            layout.sectionInset = UIEdgeInsetsMake(0, space, 0, space);
        }
        
        [self.coll reloadData];
    }
}
@end
