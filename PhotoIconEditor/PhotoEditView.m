//
//  PhotoEditView.m
//  PhotoIconEditor
//
//  Created by Suryanarayan Sahu on 25/02/16.
//  Copyright © 2016 Suryanarayan Sahu. All rights reserved.
//

#import "PhotoEditView.h"
#define ScreenHeight    [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth     [[UIScreen mainScreen] bounds].size.width

@implementation PhotoEditView

#pragma mark UISetUp
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    
    //Add backgroundImage View and add scrollView to handle image zoom in and zoom out
    imageScrollView = [[UIScrollView alloc]initWithFrame:frame];
    [self addSubview:imageScrollView];
    imageScrollView.delegate = self;
    imageScrollView.scrollEnabled = YES;
    imageScrollView.userInteractionEnabled = NO;
    imageScrollView.minimumZoomScale = 1.0;
    imageScrollView.maximumZoomScale = 5.0;
    
    //Add zoom supported View with screen bounds
    supportView = [[UIImageView alloc]initWithFrame:frame];
    [imageScrollView addSubview:supportView];
    
    //Add imageview with superview as zoom supported view.
    //Note:-Ensure zoom supported view is given screen bounds
    backgroundImageView  = [[UIImageView alloc]init];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [supportView addSubview:backgroundImageView];
    
    //Add rectangle to clear
    CAShapeLayer *rectangleLayer = [CAShapeLayer layer];
    UIBezierPath *completeScreen = [UIBezierPath bezierPathWithRect:frame];
    [completeScreen setUsesEvenOddFillRule:YES];
    [rectangleLayer setPath:[completeScreen CGPath]];
    [rectangleLayer setFillColor:[[UIColor clearColor] CGColor]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, ScreenHeight/4, ScreenWidth, ScreenHeight/2)];
    [path appendPath:completeScreen];
    [path setUsesEvenOddFillRule:YES];
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.4;
    [self.layer addSublayer:fillLayer];
    
    //Draw outline
    outlineLayer = [CAShapeLayer layer];
    UIBezierPath *markPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, ScreenHeight/4, ScreenWidth, ScreenHeight/2)];
    [outlineLayer setPath:[markPath CGPath]];
    outlineLayer.lineWidth = 2.0;
    outlineLayer.fillColor = [[UIColor clearColor] CGColor];
    outlineLayer.strokeColor = [[UIColor whiteColor] CGColor];
    [self.layer addSublayer:outlineLayer];
    
    //Add choose button to handle action
    chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseButton.frame = CGRectMake(ScreenWidth*0.1, ScreenHeight*0.9, ScreenWidth*0.3, ScreenHeight*0.1);
    [chooseButton setTitle:@"OK" forState:UIControlStateNormal];
    [chooseButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self addSubview:chooseButton];
    [chooseButton addTarget:self action:@selector(chooseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:chooseButton];
    chooseButton.enabled = NO;
    
    
    //Add cancel button to handle action
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(ScreenWidth*0.6, ScreenHeight*0.9, ScreenWidth*0.3, ScreenHeight*0.1);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:cancelButton];
    
    UIImage *img = [UIImage imageNamed:@"new.png"];
    [self load:img];
    return self;
}

#pragma mark UILoading
-(void)load:(UIImage*)img
{
    chooseButton.enabled = YES;
    imageScrollView.userInteractionEnabled = YES;
    [backgroundImageView setImage:img];
    imageScrollView.contentInset = UIEdgeInsetsMake(1,1, 0, 0);
    [imageScrollView setShowsHorizontalScrollIndicator:NO];
    [imageScrollView setShowsVerticalScrollIndicator:NO];
    backgroundImageView.bounds = CGRectMake(0, 0,ScreenWidth, ScreenHeight/2);
    backgroundImageView.center = CGPointMake(CGRectGetMidX(imageScrollView.bounds), CGRectGetMidY(imageScrollView.bounds));
    imageScrollView.clipsToBounds = YES;
    imageScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
}

-(void)chooseButtonTouched:(id)sender
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [outlineLayer removeFromSuperlayer];
    if([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *imgViewScreenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = CGRectMake(0, ScreenHeight/4, ScreenWidth, ScreenHeight/2);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect finalImageRect = CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imgViewScreenshot CGImage], finalImageRect);
    UIImage* capturedImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    if([self.delegate respondsToSelector:@selector(returnCroppedImage:)])
    {
        [self.delegate returnCroppedImage:capturedImage];
    }
}

-(void)cancelButtonTouched:(id)sender
{
    if([self.delegate respondsToSelector:@selector(returnBacktoViewController)])
    {
        [self.delegate returnBacktoViewController];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return supportView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = supportView;
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
