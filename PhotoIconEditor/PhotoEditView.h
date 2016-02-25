//
//  PhotoEditView.h
//  PhotoIconEditor
//
//  Created by Suryanarayan Sahu on 25/02/16.
//  Copyright © 2016 Suryanarayan Sahu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoEditViewDelegate<NSObject>

-(void)returnCroppedImage:(UIImage*)image;
-(void)returnBacktoViewController;

@end

@interface PhotoEditView : UIView<UIScrollViewDelegate>
{
    UIImageView *backgroundImageView;
    CAShapeLayer *outlineLayer;
    UIButton *chooseButton;
    UIButton *cancelButton;
    UIScrollView *imageScrollView ;
    UIView *supportView;
}

@property(nonatomic,assign)id<PhotoEditViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

@end
