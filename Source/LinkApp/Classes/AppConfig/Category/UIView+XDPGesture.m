//
//  UIView+XDPGesture.m
//  TestGesture
//
//  Created by cievon on 2017/9/8.
//  Copyright © 2017年 cievon. All rights reserved.
//

#import "UIView+XDPGesture.h"
#import "objc/runtime.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


static char const * kTargetKey = "kTargetKey";
static char const * kTapActionKey = "kTapActionKey";
static char const * kDBActionKey = "kDBActionKey";
static char const * kSimpleTapRecognizerKey = "kSimpleTapRecognizerKey";
static char const * kLongPressStartActionKey = "kLongPressStartActionKey";
static char const * kLongPressEndActionKey = "kLongPressEndActionKey";
static char const * kLongPressCancelActionKey = "kLongPressCancelActionKey";

@implementation UIView (XDPGesture)


- (void)xdp_addTarget:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tap];
    
    objc_setAssociatedObject(self, kSimpleTapRecognizerKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kTargetKey, target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, kTapActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)xdp_addHighlightedTarget:(id)target action:(SEL)action{
    
    self.userInteractionEnabled = YES;
    XDPTouchesGestureRecognizer *touches = [[XDPTouchesGestureRecognizer alloc] initWithTarget:self action:@selector(touchesGesture:)];
    touches.cancelsTouchesInView = NO;
    [self addGestureRecognizer:touches];
    
    objc_setAssociatedObject(self, kSimpleTapRecognizerKey, touches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kTargetKey, target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, kTapActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)xdp_addDBclick:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *dbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    dbTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:dbTap];
    
    objc_setAssociatedObject(self, kTargetKey, target, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self, kDBActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UITapGestureRecognizer *simpleTapGesture = objc_getAssociatedObject(self, kSimpleTapRecognizerKey);
    if (simpleTapGesture) {
        [simpleTapGesture requireGestureRecognizerToFail:dbTap];
    }
}

- (void)xdp_addLongPressTarget:(id)target action:(SEL)action event:(XDPLongPressEvents)event {
    self.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:longPress];
    
    objc_setAssociatedObject(self, kTargetKey, target, OBJC_ASSOCIATION_ASSIGN);
    
    switch (event) {
        case XDPLongPressEventsStart:
            objc_setAssociatedObject(self, kLongPressStartActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        case XDPLongPressEventsEnd:
            objc_setAssociatedObject(self, kLongPressEndActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        case XDPLongPressEventsCancel:
            objc_setAssociatedObject(self, kLongPressCancelActionKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
        default:
            break;
    }
}

- (void)touchesGesture:(XDPTouchesGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        const char *actionKey;
        actionKey = kTapActionKey;
        
        gesture.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            gesture.enabled = YES;
        });
        
        id target = objc_getAssociatedObject(self, kTargetKey);
        SEL tapAction = NSSelectorFromString(objc_getAssociatedObject(self, actionKey));
        
        if (!target && tapAction) return;

        SuppressPerformSelectorLeakWarning([target performSelector:tapAction withObject:self]);
    }
    
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    const char *actionKey;
    switch (gesture.numberOfTapsRequired) {
        case 1:
        {
            gesture.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                gesture.enabled = YES;
            });
            actionKey = kTapActionKey;
        }
            break;
        case 2:
        {
            actionKey = kDBActionKey;
        }
            break;
        default:
            break;
    }
    
    id target = objc_getAssociatedObject(self, kTargetKey);
    SEL tapAction = NSSelectorFromString(objc_getAssociatedObject(self, actionKey));
    
    if (!target && tapAction) return;
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        SuppressPerformSelectorLeakWarning([target performSelector:tapAction withObject:self]);
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    SuppressPerformSelectorLeakWarning(
       id target = objc_getAssociatedObject(self, kTargetKey);
       SEL longPressStartAction = NSSelectorFromString(objc_getAssociatedObject(self, kLongPressStartActionKey));
       SEL longPressEndAction = NSSelectorFromString(objc_getAssociatedObject(self, kLongPressEndActionKey));
       SEL longPressCancelAction = NSSelectorFromString(objc_getAssociatedObject(self, kLongPressCancelActionKey));
       
       if (gesture.state == UIGestureRecognizerStateBegan) {
           if (!(target && longPressStartAction)) return;
           [target performSelector:longPressStartAction withObject:self];
       }else if (gesture.state == UIGestureRecognizerStateEnded) {
           if (!(target && longPressEndAction)) return;
           [target performSelector:longPressEndAction withObject:self];
       }else if (gesture.state == UIGestureRecognizerStateCancelled){
           if (!(target && longPressCancelAction)) return;
           [target performSelector:longPressCancelAction withObject:self];
       }
    );
}

@end

@interface XDPTouchesGestureRecognizer () <UIGestureRecognizerDelegate>

@property (nonatomic , assign) BOOL touchEffect;

@property (nonatomic , assign) BOOL otherGesture;

@property (nonatomic , assign) float highLightalpha;

@end

@implementation XDPTouchesGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action{
    if (self = [super initWithTarget:target action:action]) {
        self.delegate = self;
        self.highLightalpha = 0.3;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
     [super touchesBegan:touches withEvent:event];
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateBegan;
        
        if (self.view.alpha == 1) {
            self.view.alpha = self.highLightalpha;
            self.touchEffect = YES;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject] ;
    CGPoint point = [touch locationInView:self.view];
    
    if (self.touchEffect) {
        if (point.x > self.view.frame.size.width || point.y > self.view.frame.size.height)  {
            self.view.alpha = 1;
        }else{
            self.view.alpha = self.highLightalpha;
        }
    }
     self.otherGesture = YES;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject] ;
    CGPoint point = [touch locationInView:self.view];
    
    if (self.touchEffect) {
        self.view.alpha = 1;
    }
    
    if (point.x > self.view.frame.size.width || point.y > self.view.frame.size.height || self.otherGesture) {
        self.state = UIGestureRecognizerStateFailed;
    }else{
        self.state = UIGestureRecognizerStateEnded;
       
    }
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    if (self.touchEffect) {
        self.view.alpha = 1;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer{
    // 解决scrollview 冲突
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        self.otherGesture = YES;
        return YES;
    }
    return NO;
}

@end
