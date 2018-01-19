//
//  JPCARLayer.m
//  AudioRecorderPlayer
//
//  Created by JPMEENAA on 09/12/17.
//  Copyright © 2017 JPMEENAA. All rights reserved.
//

#import "JPCARLayer.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface JPCARLayer () <CAAnimationDelegate>
#else
@interface JPCARLayer ()
#endif

{

}
@property (nonatomic, strong) CALayer *effect;
@property (nonatomic, strong) CAAnimationGroup *animationGroup;

@end

@implementation JPCARLayer
@dynamic repeatCount;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.effect = [CALayer new];
        self.effect.contentsScale = [UIScreen mainScreen].scale;
//        self.effect.borderWidth = 5;
//        self.effect.borderColor = [UIColor blueColor].CGColor;
        self.effect.opacity = 0;
        [self.effect masksToBounds];
        [self.effect setMasksToBounds:YES];
        
//[[UIColor lightGrayColor] colorWithAlphaComponent:0.6]
//        CALayer *coverLayer = [CALayer layer];
//        coverLayer.frame = CGRectMake(30.0f, -30.0f, 540.0f, 660.0f);
//        coverLayer.borderColor = [UIColor redColor].CGColor;
//        coverLayer.borderWidth = 5;
//        coverLayer.backgroundColor = [UIColor redColor].CGColor;
//        [self.effect addSublayer:coverLayer];

        
        CALayer *leftLayer = [CALayer layer];
        leftLayer.frame = CGRectMake(30.0f, -10.0f, 540.0f, 620.0f);
        leftLayer.borderColor = [UIColor blueColor].CGColor;
        leftLayer.borderWidth = 5;
        [self.effect addSublayer:leftLayer];
        

        
        [self addSublayer:self.effect];
        [self _setupDefaults];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// =============================================================================
#pragma mark - Accessor

- (void)start {
    [self _setupAnimationGroup];
    [self.effect addAnimation:self.animationGroup forKey:@"pulse"];
    
}



//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    self.effect.frame = frame;
//}

- (void)setBackgroundColor:(CGColorRef)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.effect.backgroundColor = backgroundColor;
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    
    CGFloat diameter = self.radius * 2;
    
    self.effect.bounds = CGRectMake(0, 0, diameter, diameter);
    self.effect.cornerRadius = self.radius;
}

- (void)setHaloLayerNumber:(NSInteger)haloLayerNumber {
    _haloLayerNumber = haloLayerNumber;
    self.instanceCount = haloLayerNumber;
    self.instanceDelay = (self.animationDuration + self.pulseInterval) / haloLayerNumber;
}


- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    
    self.instanceDelay = (self.animationDuration + self.pulseInterval) / self.haloLayerNumber;
}

- (void)setRepeatCount:(float)repeatCount {
    [super setRepeatCount:repeatCount];
    self.animationGroup.repeatCount = repeatCount;
}


// =============================================================================
#pragma mark - Private

- (void)_setupDefaults
{
    _useTimingFunction = YES;
    self.repeatCount = INFINITY;
    
    _keyTimeForHalfOpacity = 0.5;
    _pulseInterval = 0.5;
    
    self.haloLayerNumber = 20.0;
    self.radius = 300;
    self.animationDuration = 5;
    [self setBackgroundColor:[[UIColor clearColor] CGColor] ];
    
}

- (void)_setupAnimationGroup {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = self.animationDuration + self.pulseInterval;
    animationGroup.repeatCount = self.repeatCount;
    if (self.useTimingFunction) {
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        animationGroup.timingFunction = defaultCurve;
    }
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue =@1.0;
    scaleAnimation.toValue =  @(self.fromValueForRadius);
    scaleAnimation.duration = self.animationDuration;
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = self.animationDuration;
    CGFloat fromValueForAlpha = CGColorGetAlpha(self.backgroundColor);
    opacityAnimation.values = @[@(fromValueForAlpha), @0.8,@0.6,@0.4,@0.2, @0];
    opacityAnimation.keyTimes = @[@0, @(self.keyTimeForHalfOpacity), @1];
    
    NSArray *animations = @[scaleAnimation, opacityAnimation];
    
    animationGroup.animations = animations;
    
    self.animationGroup = animationGroup;
    self.animationGroup.delegate = self;
}


// =============================================================================
#pragma mark - CAAnimationDelegate

-(void)stop
{
    if ([self.effect.animationKeys count]) {
        [self.effect removeAllAnimations];
    }
    [self.effect removeFromSuperlayer];
    [self removeFromSuperlayer];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([self.effect.animationKeys count]) {
        [self.effect removeAllAnimations];
    }
    [self.effect removeFromSuperlayer];
    [self removeFromSuperlayer];
}

@end
