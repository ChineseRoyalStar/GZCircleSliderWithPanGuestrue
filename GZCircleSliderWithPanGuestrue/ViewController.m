//
//  ViewController.m
//  GZCircleSliderWithPanGuestrue
//
//  Created by armada on 2016/11/29.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "ViewController.h"

#import "GZCircleSlider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    GZCircleSlider *slider = [[GZCircleSlider alloc]initWithFrame:CGRectMake(0, 0, 400, 400) lineWidth:(float)11 currentIndex:4];
    slider.center = self.view.center;
    [self.view addSubview:slider];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
