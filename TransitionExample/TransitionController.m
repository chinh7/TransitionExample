//
//  LoginAnimationController.m
//  TransitionExample
//
//  Created by Ryan Nystrom on 7/12/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "TransitionController.h"
#import "AppDelegate.h"

static NSTimeInterval const AnimatedTransitionDuration = 0.5f;

@interface TransitionController ()
@property (nonatomic, weak) UIViewController *presenting;

@end

@implementation TransitionController

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return AnimatedTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)ctx {
    UIViewController *fromController = [ctx viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [ctx viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *from = [fromController view];
    UIView *to = [toController view];
    UIView *container = [ctx containerView];
    

    // Fixing autosizing
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) && toController.modalPresentationStyle == UIModalPresentationCustom) {
        to.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    // if the modalPresentationStyle is set to Custom then the containerView will not have bounds that reflect device orientation
    // this view will be always in portrait mode (Apple BUG?)
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) && (toController.modalPresentationStyle == UIModalPresentationCustom || fromController.modalPresentationStyle == UIModalPresentationCustom)) {
        container.transform = [[[UIApplication sharedApplication] delegate] window].rootViewController.view.transform;  // rotate
        container.bounds = CGRectMake(0, 0, container.bounds.size.height, container.bounds.size.width); // swap width & height
        
        // fromView(s)
        for (UIView * subview in container.subviews) {
            subview.transform = CGAffineTransformIdentity;
            subview.frame = CGRectMake(0, 0, subview.bounds.size.width, subview.bounds.size.height);
        }
        
        // Fixing autosizing
        to.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // toView
        if (to.superview != container) {
            to.transform = CGAffineTransformIdentity;
            to.bounds = CGRectMake(0, 0, to.bounds.size.height, to.bounds.size.width); // frame ?
        }
    }
    
    BOOL animateSlide = NO;
    
    if (animateSlide) {
        CGRect fromFrame = from.frame;
        CGRect toFrame = to.frame;
        
        if (self.isPresenting) {
            toFrame.origin.x = container.bounds.size.width;
            fromFrame.origin.x = -container.bounds.size.width;
        }
        else {
            toFrame.origin.x = - container.bounds.size.width;
            fromFrame.origin.x = container.bounds.size.width;
        }
        
        to.frame = toFrame;
        
        [container addSubview:to];
        
        [UIView animateWithDuration:[self transitionDuration:ctx] delay:0 usingSpringWithDamping:0.8  initialSpringVelocity:5 options:kNilOptions animations:^{
            to.center = CGPointMake(CGRectGetWidth(container.bounds)/2, CGRectGetHeight(container.bounds)/2);
            from.frame = fromFrame;
        }completion:^(BOOL finished){ [ctx completeTransition:YES]; }];
    }
    else {
        // Corrected code from Double Encore
        // http://www.doubleencore.com/2013/09/ios-7-custom-transitions/
        to.frame = container.bounds;
        from.frame = container.bounds;
        
        if (! self.isPresenting) {
            [container insertSubview:to belowSubview:from];
        }
        else {
            if (toController.modalPresentationStyle == UIModalPresentationCustom) {
                to.alpha = 0.f;
            }
            to.transform = CGAffineTransformScale(to.transform, 0, 0);
            [container addSubview:to];
        }
        
        [UIView animateKeyframesWithDuration:AnimatedTransitionDuration delay:0 options:0 animations:^{
            if (! self.isPresenting) {
                from.transform = CGAffineTransformScale(from.transform, 0, 0);
                if (fromController.modalPresentationStyle == UIModalPresentationCustom) {
                    to.alpha = 1.0f;
                    from.alpha = 0.f;
                }
            }
            else {
                to.transform = CGAffineTransformIdentity;
                if (toController.modalPresentationStyle == UIModalPresentationCustom) {
                    to.alpha = 0.7f;
                }
            }
        } completion:^(BOOL finished) {
            // remove bound / frame / transform adjustments I've made before animation
            if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]) && (toController.modalPresentationStyle == UIModalPresentationCustom || fromController.modalPresentationStyle == UIModalPresentationCustom)) {
                container.transform = CGAffineTransformIdentity;  // rotate
                container.frame = CGRectMake(0, 0, container.bounds.size.height, container.bounds.size.width); // swap width & height
                CGFloat angle = 0.f;
                if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
                    angle = M_PI_2;
                }
                else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
                    angle = -M_PI_2;
                }
                
                for (UIView * subview in container.subviews) {
                    subview.transform = CGAffineTransformMakeRotation(angle);
                    subview.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
                }
            }

            [ctx completeTransition:finished];
        }];
    }
}

@end
