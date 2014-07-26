//
//  UPDPreProcessingView.m
//  Updates
//
//  Created by Bryce Pauken on 7/21/14.
//  Copyright (c) 2014 Kingfish. All rights reserved.
//

#import "UPDPreProcessingView.h"

typedef NS_ENUM(NSInteger, UPDFoldingViewSide) {
    UPDFoldingViewSideBottom,
    UPDFoldingViewSideLeft,
    UPDFoldingViewSideRight,
    UPDFoldingViewSideTop
};

@interface UPDPreProcessingView()

@property (nonatomic, strong) UIImageView *browserImageView;
@property (nonatomic, strong) UIImageView *checkmark;
@property (nonatomic, strong) UIView *checkmarkBackground;
@property (nonatomic, strong) UIImageView *outline;
@property (nonatomic, strong) UIImageView *outlineQuarter;

@property (nonatomic, copy) void (^individualAnimationCompletionBlock)();
@property (nonatomic) CGRect individualAnimationFinalFrame;
@property (nonatomic, strong) CALayer *individualAnimationFoldingLayer;
@property (nonatomic, strong) NSString *individualAnimationKeyPath;
@property (nonatomic) int lastFoldWasHorizontal;

@property (nonatomic, strong) CADisplayLink *foldedViewVerticalAnimationDisplayLink;
@property (nonatomic) CGFloat foldedViewVerticalAnimationStartVelocity;
@property (nonatomic) CGFloat foldedViewVerticalAnimationStartY;
@property (nonatomic) CFTimeInterval foldedViewVerticalAnimationTimestamp;

@end

@implementation UPDPreProcessingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor UPDLightBlueColor]];
        
        self.browserImageView = [[UIImageView alloc] init];
        [self.browserImageView setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self addSubview:self.browserImageView];
        
        self.outlineQuarter = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.outlineQuarter setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outlineQuarter setImage:[UIImage imageNamed:@"ButtonOutlineQuarter"]];
        [self.outlineQuarter setHidden:YES];
        [self addSubview:self.outlineQuarter];
        
        self.outline = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.outline setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.outline setImage:[UIImage imageNamed:@"ButtonOutline"]];
        [self addSubview:self.outline];
        
        CGFloat checkmarkBackgroundSize = UPD_CONFIRM_BUTTON_SIZE*0.9;
        self.checkmarkBackground = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-checkmarkBackgroundSize)/2, (self.bounds.size.height-checkmarkBackgroundSize)/2, checkmarkBackgroundSize, checkmarkBackgroundSize)];
        [self.checkmarkBackground setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.checkmarkBackground setBackgroundColor:self.backgroundColor];
        [self.checkmarkBackground setHidden:YES];
        [self.checkmarkBackground.layer setCornerRadius:checkmarkBackgroundSize/2];
        [self addSubview:self.checkmarkBackground];
        
        self.checkmark = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width-UPD_CONFIRM_BUTTON_SIZE)/2, (self.bounds.size.height-UPD_CONFIRM_BUTTON_SIZE)/2, UPD_CONFIRM_BUTTON_SIZE, UPD_CONFIRM_BUTTON_SIZE)];
        [self.checkmark setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
        [self.checkmark setImage:[UIImage imageNamed:@"AcceptLarge"]];
        [self addSubview:self.checkmark];
    }
    return self;
}

- (void)beginPreProcessingWithBrowserImage:(UIImage *)browserImage {
    [self.browserImageView setTransform:CGAffineTransformIdentity];
    [self.browserImageView setFrame:CGRectMake((self.bounds.size.width-browserImage.size.width)/2, (self.bounds.size.height-browserImage.size.height)/2, browserImage.size.width, browserImage.size.height)];
    [self.browserImageView setImage:browserImage];
    
    UIView *browserImageOverlay = [[UIView alloc] initWithFrame:self.browserImageView.frame];
    [browserImageOverlay setAlpha:UPD_BROWSER_IMAGE_OPACITY];
    [browserImageOverlay setAutoresizingMask:UIViewAutoresizingFlexibleMargins];
    [browserImageOverlay setBackgroundColor:[UIColor UPDOffBlackColor]];
    [browserImageOverlay setUserInteractionEnabled:NO];
    [self addSubview:browserImageOverlay];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(browserImage.size.width*UPD_BROWSER_IMAGE_SCALE, browserImage.size.height*UPD_BROWSER_IMAGE_SCALE), YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, UPD_BROWSER_IMAGE_SCALE, UPD_BROWSER_IMAGE_SCALE);
    [self.browserImageView.layer renderInContext:context];
    [browserImageOverlay.layer renderInContext:context];
    UIImage *firstImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [browserImageOverlay removeFromSuperview];
    [self.browserImageView setFrame:CGRectMake((self.bounds.size.width-firstImage.size.width)/2, (self.bounds.size.height-firstImage.size.height)/2, firstImage.size.width, firstImage.size.height)];
    [self.browserImageView setImage:firstImage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DELAY*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        /*find max size for diagonal to fit in 0.8 of checkmark button diameter*/
        CGFloat maxSize = (UPD_CONFIRM_BUTTON_SIZE*0.8)/sqrt(2);
        
        /*find the point that the folding should contain—must not intersect the confirmation button*/
        CGPoint goalPoint;
        if(self.browserImageView.frame.origin.x+maxSize+20<self.outline.frame.origin.x) {
            goalPoint = CGPointMake(1, self.browserImageView.frame.size.height/2);
        }
        else {
            goalPoint = CGPointMake(1, self.browserImageView.frame.size.height/2-sqrt(abs(UPD_CONFIRM_BUTTON_SIZE*UPD_CONFIRM_BUTTON_SIZE - (self.outline.frame.origin.x + maxSize)*(self.outline.frame.origin.x + maxSize))));
        }
        [self foldBrowserImageUntilLessThanOrEqualsSize:CGSizeMake(maxSize, maxSize) containingPoint:goalPoint animationDuration:UPD_TRANSITION_DURATION_FAST];
    });
}

- (void)foldAnimationCompleted {
    [self.checkmarkBackground setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DELAY*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CAKeyframeAnimation *horizontalAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        [horizontalAnimation setCalculationMode:kCAAnimationLinear];
        [horizontalAnimation setDuration:UPD_FOLDED_VIEW_ANIMATION_TIME];
        [horizontalAnimation setFillMode:kCAFillModeForwards];
        [horizontalAnimation setRemovedOnCompletion:NO];
        [horizontalAnimation setValues:@[@(self.browserImageView.frame.origin.x+self.browserImageView.frame.size.width/2),@(self.outline.frame.origin.x+self.outline.frame.size.width/2)]];
        [self.browserImageView.layer addAnimation:horizontalAnimation forKey:@"horizontalAnimation"];
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        [rotationAnimation setCumulative:YES];
        [rotationAnimation setDuration:UPD_FOLDED_VIEW_ANIMATION_TIME];
        [rotationAnimation setToValue:@(M_PI*2)];
        [rotationAnimation setRepeatCount:MAXFLOAT];
        [self.browserImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        
        self.foldedViewVerticalAnimationStartY = self.browserImageView.center.y;
        self.foldedViewVerticalAnimationStartVelocity = (self.outline.center.y-self.browserImageView.center.y)/UPD_FOLDED_VIEW_ANIMATION_TIME - 0.5*UPD_FOLDED_VIEW_GRAVITY*UPD_FOLDED_VIEW_ANIMATION_TIME;
        
        self.foldedViewVerticalAnimationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(foldedViewAnimateVertical)];
        [self.foldedViewVerticalAnimationDisplayLink setFrameInterval:1];
        [self.foldedViewVerticalAnimationDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        /*the time until the bottom of the folded view hits the top of the checkmark button*/
        CGFloat timeUntilBounce = (-self.foldedViewVerticalAnimationStartVelocity+sqrt(self.foldedViewVerticalAnimationStartVelocity*self.foldedViewVerticalAnimationStartVelocity+2*UPD_FOLDED_VIEW_GRAVITY*(self.outline.frame.origin.y-(self.browserImageView.center.y+self.browserImageView.frame.size.height/2))))/UPD_FOLDED_VIEW_GRAVITY;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeUntilBounce*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            
            CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
            CATransform3D scale2 = CATransform3DMakeScale(1.1, 1.1, 1);
            CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
            CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
            
            NSArray *frameValues = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:scale1],[NSValue valueWithCATransform3D:scale2],[NSValue valueWithCATransform3D:scale3],[NSValue valueWithCATransform3D:scale4], nil];
            [animation setValues:frameValues];
            
            NSArray *frameTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.6],[NSNumber numberWithFloat:0.9],[NSNumber numberWithFloat:1.0], nil];
            [animation setKeyTimes:frameTimes];
            
            animation.fillMode = kCAFillModeForwards;
            animation.removedOnCompletion = YES;
            animation.duration = UPD_TRANSITION_DURATION;
            
            [self.checkmark.layer addAnimation:animation forKey:@"popup"];
            [self.checkmarkBackground.layer addAnimation:animation forKey:@"popupCopy"];
            [self.outline.layer addAnimation:animation forKey:@"popupCopy"];
        });
    });
}

- (void)foldedViewAnimateVertical {
    if(!self.foldedViewVerticalAnimationTimestamp) {
        self.foldedViewVerticalAnimationTimestamp = self.foldedViewVerticalAnimationDisplayLink.timestamp;
    }
    CFTimeInterval elapsedTime = (self.foldedViewVerticalAnimationDisplayLink.timestamp - self.foldedViewVerticalAnimationTimestamp);
    
    [self.browserImageView setCenter:CGPointMake(self.browserImageView.center.x, self.foldedViewVerticalAnimationStartY+(self.foldedViewVerticalAnimationStartVelocity*elapsedTime + 0.5*UPD_FOLDED_VIEW_GRAVITY*elapsedTime*elapsedTime))];

    if(self.browserImageView.center.y >= self.outline.center.y) {
        [self.foldedViewVerticalAnimationDisplayLink invalidate];
        
        if(self.completionBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, UPD_TRANSITION_DELAY*2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               self.completionBlock();
            });
        }
    }
}

#pragma mark - Folding Animation


- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if([[animation valueForKey:@"id"] isEqualToString:@"fold"]) {
        [self.browserImageView setFrame:CGRectMake(self.browserImageView.frame.origin.x+self.individualAnimationFinalFrame.origin.x, self.browserImageView.frame.origin.y+self.individualAnimationFinalFrame.origin.y, self.individualAnimationFinalFrame.size.width, self.individualAnimationFinalFrame.size.height)];
        if(self.individualAnimationFinalFrame.origin.x!=0||self.individualAnimationFinalFrame.origin.y!=0) {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            for(CALayer *layer in self.browserImageView.layer.sublayers) {
                CGRect layerFrame = layer.frame;
                layerFrame.origin.x -= self.individualAnimationFinalFrame.origin.x;
                layerFrame.origin.y -= self.individualAnimationFinalFrame.origin.y;
                [layer setFrame:layerFrame];
            }
            [CATransaction commit];
        }
        
        UIGraphicsBeginImageContext(self.browserImageView.frame.size);
        CGContextRef c = UIGraphicsGetCurrentContext();
        BOOL flipHorizontal = [self.individualAnimationKeyPath isEqualToString:@"transform.rotation.y"];
        CGContextTranslateCTM (c, self.browserImageView.bounds.size.width/2, self.browserImageView.bounds.size.height/2);
        CGContextScaleCTM(c, flipHorizontal?-1:1, !flipHorizontal?-1:1);
        CGContextTranslateCTM (c, -self.browserImageView.bounds.size.width/2, -self.browserImageView.bounds.size.height/2);
        [self.individualAnimationFoldingLayer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.browserImageView setImage:viewImage];
        
        for(int i=0;i<self.browserImageView.layer.sublayers.count;i++) {
            if([((CALayer *)[self.browserImageView.layer.sublayers objectAtIndex:i]).name isEqualToString:@"backgroundLayer"]) {
                [[self.browserImageView.layer.sublayers objectAtIndex:i] removeFromSuperlayer];
                break;
            }
        }
        
        if(self.individualAnimationCompletionBlock) {
            self.individualAnimationCompletionBlock();
        }
    }
}

- (void)foldBrowserImageSideOver:(UPDFoldingViewSide)side withDuration:(NSTimeInterval)duration {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.browserImageView.frame.size.width, self.browserImageView.frame.size.height), YES, 0.0);
    [self.browserImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.browserImageView setImage:nil];
    
    CGFloat halfWidth = self.browserImageView.frame.size.width/2.0;
    CGFloat halfHeight = self.browserImageView.frame.size.height/2.0;
    UPDFoldingViewSide oppositeSide = [self sideOppositeOfSide:side];
    
    CGRect foldingHalfFrame = CGRectMake(side==UPDFoldingViewSideRight?halfWidth:0, side==UPDFoldingViewSideBottom?halfHeight:0, side==UPDFoldingViewSideLeft||side==UPDFoldingViewSideRight?halfWidth:self.browserImageView.frame.size.width, side==UPDFoldingViewSideBottom||side==UPDFoldingViewSideTop?halfHeight:self.browserImageView.frame.size.height);
    CGRect stationaryHalfFrame = CGRectMake(oppositeSide==UPDFoldingViewSideRight?halfWidth:0, oppositeSide==UPDFoldingViewSideBottom?halfHeight:0, oppositeSide==UPDFoldingViewSideLeft||oppositeSide==UPDFoldingViewSideRight?halfWidth:self.browserImageView.frame.size.width, oppositeSide==UPDFoldingViewSideBottom||oppositeSide==UPDFoldingViewSideTop?halfHeight:self.browserImageView.frame.size.height);
    self.individualAnimationFinalFrame = stationaryHalfFrame;
    
    CATransform3D transform = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
    transform.m34 = 1.0f / 2500.0f;
    
    CALayer *foldingLayer = [CALayer layer];
    [foldingLayer setDoubleSided:YES];
    [foldingLayer setMasksToBounds:YES];
    switch (side) {
        case UPDFoldingViewSideBottom:
            [foldingLayer setAnchorPoint:CGPointMake(0.5, 0.0)];
            break;
        case UPDFoldingViewSideLeft:
            [foldingLayer setAnchorPoint:CGPointMake(1.0, 0.5)];
            break;
        case UPDFoldingViewSideRight:
            [foldingLayer setAnchorPoint:CGPointMake(0.0, 0.5)];
            break;
        case UPDFoldingViewSideTop:
            [foldingLayer setAnchorPoint:CGPointMake(0.5, 1.0)];
            break;
    }
    [foldingLayer setFrame:foldingHalfFrame];
    self.individualAnimationFoldingLayer = foldingLayer;
    CALayer *stationaryLayer = [CALayer layer];
    [stationaryLayer setMasksToBounds:YES];
    [stationaryLayer setFrame:stationaryHalfFrame];
    CALayer *stationaryLayerShadowOverlay = [CALayer layer];
    [stationaryLayerShadowOverlay setMasksToBounds:YES];
    [stationaryLayerShadowOverlay setFrame:stationaryHalfFrame];
    
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setName:@"backgroundLayer"];
    [backgroundLayer setFrame:self.browserImageView.bounds];
    
    CGImageRef foldingImage = CGImageCreateWithImageInRect([self scaledCGImage:fullImage.CGImage], foldingHalfFrame);
    CGImageRef stationaryImage = CGImageCreateWithImageInRect([self scaledCGImage:fullImage.CGImage], stationaryHalfFrame);
    
    [foldingLayer setContents:(__bridge id)(foldingImage)];
    [stationaryLayer setContents:(__bridge id)(stationaryImage)];
    [stationaryLayerShadowOverlay setBackgroundColor:[UIColor blackColor].CGColor];
    [stationaryLayerShadowOverlay setOpacity:0];
    [backgroundLayer addSublayer:stationaryLayerShadowOverlay];
    [backgroundLayer addSublayer:stationaryLayer];
    [backgroundLayer addSublayer:foldingLayer];
    
    [stationaryLayerShadowOverlay setZPosition:MAX(self.bounds.size.width,self.bounds.size.height*2)];
    [foldingLayer setZPosition:MAX(self.bounds.size.width,self.bounds.size.height*4)];
    
    [self.browserImageView.layer addSublayer:backgroundLayer];
    
    self.individualAnimationKeyPath = oppositeSide==UPDFoldingViewSideLeft||oppositeSide==UPDFoldingViewSideRight?@"transform.rotation.y":@"transform.rotation.x";
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:self.individualAnimationKeyPath];
    [flipAnimation setDelegate:self];
    [flipAnimation setDuration:duration];
    [flipAnimation setFillMode:kCAFillModeForwards];
    [flipAnimation setFromValue:[NSNumber numberWithDouble:0.0f]];
    [flipAnimation setToValue:[NSNumber numberWithDouble:M_PI]];
    [flipAnimation setRepeatCount:1];
    [flipAnimation setRemovedOnCompletion:NO];
    [flipAnimation setValue:@"fold" forKey:@"id"];
    
    [foldingLayer addAnimation:flipAnimation forKey:@"fold"];
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [shadowAnimation setBeginTime:CACurrentMediaTime()+duration/2.0f];
    [shadowAnimation setDuration:duration/2.0f];
    [shadowAnimation setFillMode:kCAFillModeForwards];
    [shadowAnimation setFromValue:[NSNumber numberWithDouble:0.0f]];
    [shadowAnimation setToValue:[NSNumber numberWithDouble:0.5f]];
    [shadowAnimation setRepeatCount:1];
    [shadowAnimation setRemovedOnCompletion:NO];
    
    [stationaryLayerShadowOverlay addAnimation:shadowAnimation forKey:@"shadow"];
}

- (void)foldBrowserImageUntilLessThanOrEqualsSize:(CGSize)size containingPoint:(CGPoint)point animationDuration:(CGFloat)duration {
    self.lastFoldWasHorizontal = -1;
    __unsafe_unretained UPDPreProcessingView *weakSelf = self;
    __unsafe_unretained UIImageView *weakImageView = self.browserImageView;
    [self setIndividualAnimationCompletionBlock:^{
        BOOL canFoldWidth = weakImageView.frame.size.width > size.width;
        BOOL canFoldHeight = weakImageView.frame.size.height > size.height;
        
        if(canFoldWidth || canFoldHeight) {
            BOOL horizontalFold;
            if(canFoldWidth&&canFoldHeight) {
                if(weakSelf.lastFoldWasHorizontal == -1) {
                    horizontalFold = arc4random_uniform(2);
                    weakSelf.lastFoldWasHorizontal = horizontalFold;
                }
                else {
                    /*
                     We want a larger chance of changing the folding direction than not
                     */
                    if(arc4random_uniform(1/UPD_DOUBLE_FOLD_CHANCE)>0) {
                        horizontalFold = !weakSelf.lastFoldWasHorizontal;
                        weakSelf.lastFoldWasHorizontal = horizontalFold;
                    }
                }
            }
            else if(canFoldWidth) {
                horizontalFold = YES;
            }
            else {
                horizontalFold = NO;
            }
            
            UPDFoldingViewSide foldingSide;
            if(horizontalFold) {
                if(point.x <= weakImageView.frame.origin.x + weakImageView.frame.size.width/2) {
                    foldingSide = UPDFoldingViewSideRight;
                }
                else {
                    foldingSide = UPDFoldingViewSideLeft;
                }
            }
            else {
                if(point.y <= weakImageView.frame.origin.y + weakImageView.frame.size.height/2) {
                    foldingSide = UPDFoldingViewSideBottom;
                }
                else {
                    foldingSide = UPDFoldingViewSideTop;
                }
            }
            [weakSelf foldBrowserImageSideOver:foldingSide withDuration:duration];
        }
        else {
            [weakSelf foldAnimationCompleted];
        }
    }];
    self.individualAnimationCompletionBlock();
}

- (CGImageRef)scaledCGImage:(CGImageRef)image {
    CGContextRef context = NULL;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    int width = CGImageGetWidth(image) / (float)([[UIScreen mainScreen] scale]);
    int height = CGImageGetHeight(image) / (float)([[UIScreen mainScreen] scale]);
    
    bitmapBytesPerRow   = (width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * height);
    
    bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        return nil;
    }
    
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    context = CGBitmapContextCreate(bitmapData,width,height,8,bitmapBytesPerRow, colorspace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context, CGRectMake(0,0,width, height), image);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    
    return imgRef;
}

- (UPDFoldingViewSide)sideOppositeOfSide:(UPDFoldingViewSide)side {
    switch (side) {
        case UPDFoldingViewSideBottom:
            return UPDFoldingViewSideTop;
        case UPDFoldingViewSideLeft:
            return UPDFoldingViewSideRight;
        case UPDFoldingViewSideRight:
            return UPDFoldingViewSideLeft;
        case UPDFoldingViewSideTop:
            return UPDFoldingViewSideBottom;
    }
}

@end
