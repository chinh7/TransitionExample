/*
 * Copyright (c) 2013 Krzysztof Profic
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "UIViewControllerContextTransitioning+UIModalPresentationCustom.h"

@implementation NSObject (CustomTransitionContextPatch)

- (void)patchUIModalPresentationCustomIfNeeded
{
    if ([self conformsToProtocol:@protocol(UIViewControllerContextTransitioning)] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Patch is supposed to work only on objects implementing UIViewControllerContextTransitioning protocol"];
        return;
    }
    
    UIViewController *fromController = [(id)self viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [(id)self viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *to = [toController view];
    UIView *container = [(id)self containerView];
    
    // Fixing autosizing
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) && toController.modalPresentationStyle == UIModalPresentationCustom) {
        to.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    if (UIInterfaceOrientationIsLandscape(fromController.interfaceOrientation) && (toController.modalPresentationStyle == UIModalPresentationCustom || fromController.modalPresentationStyle == UIModalPresentationCustom)) {
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
}

- (void)restoreFromUIModalPresentationCustomIfNeeded
{
    if ([self conformsToProtocol:@protocol(UIViewControllerContextTransitioning)] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Patch is supposed to work only on objects implementing UIViewControllerContextTransitioning protocol"];
        return;
    }
    
    UIViewController *fromController = [(id)self viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toController = [(id)self viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [(id)self containerView];
    
    // remove bound / frame / transform adjustments I've made before animation
    if (UIInterfaceOrientationIsLandscape(toController.interfaceOrientation) && (toController.modalPresentationStyle == UIModalPresentationCustom || fromController.modalPresentationStyle == UIModalPresentationCustom)) {
        container.transform = CGAffineTransformIdentity;  // rotate
        container.frame = CGRectMake(0, 0, container.bounds.size.height, container.bounds.size.width); // swap width & height
        CGFloat angle = 0.f;
        if (toController.interfaceOrientation == UIDeviceOrientationLandscapeLeft) {
            angle = M_PI_2;
        }
        else if (toController.interfaceOrientation == UIDeviceOrientationLandscapeRight) {
            angle = -M_PI_2;
        }
        
        for (UIView * subview in container.subviews) {
            subview.transform = CGAffineTransformMakeRotation(angle);
            subview.frame = CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height);
        }
    }
}

@end