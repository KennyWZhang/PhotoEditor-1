//
//  ViewController.m
//  PhotoIconEditor
//
//  Created by Suryanarayan Sahu on 25/02/16.
//  Copyright © 2016 Suryanarayan Sahu. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()
{
    UIImageView *displayImageView ;
    PhotoEditView *photo;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    displayImageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 50, 200, 200)];
    [self.view addSubview:displayImageView];
    
    UIButton *mybutton = [UIButton buttonWithType:UIButtonTypeCustom];
    mybutton.frame =CGRectMake(100, 300, 100, 100);
    [mybutton setTitle:@"Edit" forState:UIControlStateNormal];
    [mybutton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [self.view addSubview:mybutton];
    [mybutton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)buttonTapped:(id)sender
{
    if(!photo)
    {
       photo = [[PhotoEditView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    photo.delegate = self;
    [self.view addSubview:photo];
}

-(void)returnCroppedImage:(UIImage*)image
{
    [photo removeFromSuperview];
    displayImageView.image = image;
    photo = nil;
}

-(void)returnBacktoViewController
{
    [photo removeFromSuperview];
    photo = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
