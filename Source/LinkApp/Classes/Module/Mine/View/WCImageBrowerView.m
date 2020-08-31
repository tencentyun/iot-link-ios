//
//  WCImageBrowerView.m
//  TenextCloud
//
//  Created by 侯兴宇 on 2019/9/26.
//  Copyright © 2019 Winext. All rights reserved.
//

#import "WCImageBrowerView.h"

@interface WCImageBrowerView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation WCImageBrowerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark publicMethods
- (void)showView{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

#pragma mark privateMethods
- (void)setupUI{
    self.backgroundColor = [UIColor blackColor];
    
    self.scrollview = [[UIScrollView alloc] init];
    self.scrollview.bouncesZoom = YES;
    self.scrollview.maximumZoomScale = 2.5;
    self.scrollview.minimumZoomScale = 1.0;
    self.scrollview.multipleTouchEnabled = YES;
    self.scrollview.delegate = self;
    self.scrollview.scrollsToTop = NO;
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.showsVerticalScrollIndicator = YES;
    self.scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollview.delaysContentTouches = NO;
    self.scrollview.canCancelContentTouches = YES;
    self.scrollview.alwaysBounceVertical = NO;
    if (@available(iOS 11, *)) {
        self.scrollview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.scrollview];
    
    self.imageContainerView = [[UIView alloc] init];
    self.imageContainerView.clipsToBounds = YES;
    self.imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollview addSubview:self.imageContainerView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.imageContainerView addSubview:self.imageView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.numberOfTapsRequired = 2;
    [tap1 requireGestureRecognizerToFail:tap2];
    [self addGestureRecognizer:tap2];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollview.frame = CGRectMake(0, 0, self.width, self.height);

    [self recoverSubviews];
}

- (void)recoverSubviews {
    [self.scrollview setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    self.imageContainerView.origin = CGPointZero;
    self.imageContainerView.width = self.scrollview.width;
    
    UIImage *image = self.imageView.image;
    if (image.size.height / image.size.width > self.height / self.scrollview.width) {
        self.imageContainerView.height = floor(image.size.height / (image.size.width / self.scrollview.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollview.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        self.imageContainerView.height = height;
        self.imageContainerView.centerY = self.height / 2;
    }
    if (self.imageContainerView.height > self.height && _imageContainerView.height - self.height <= 1) {
        self.imageContainerView.height = self.height;
    }
    CGFloat contentSizeH = MAX(self.imageContainerView.height, self.height);
    self.scrollview.contentSize = CGSizeMake(self.scrollview.width, contentSizeH);
    [self.scrollview scrollRectToVisible:self.bounds animated:NO];
    self.scrollview.alwaysBounceVertical = self.imageContainerView.height <= self.height ? NO : YES;
    self.imageView.frame = self.imageContainerView.bounds;

}

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (self.scrollview.width > self.scrollview.contentSize.width) ? ((self.scrollview.width - self.scrollview.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (self.scrollview.height > self.scrollview.contentSize.height) ? ((self.scrollview.height - self.scrollview.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(self.scrollview.contentSize.width * 0.5 + offsetX, self.scrollview.contentSize.height * 0.5 + offsetY);
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (self.scrollview.zoomScale > 1.0) {
        self.scrollview.contentInset = UIEdgeInsetsZero;
        [self.scrollview setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollview.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self.scrollview zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    [self removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
   
}

#pragma mark setter or getter
- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
    [self.scrollview setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

@end
