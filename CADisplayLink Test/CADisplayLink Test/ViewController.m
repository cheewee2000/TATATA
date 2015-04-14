//
//  ViewController.m
//  CADisplayLink Test
//
//  Created by Che-Wei Wang on 3/27/15.
//  Copyright (c) 2015 CW&T. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}
- (void) update {
    double currentTime = [displayLink timestamp];
    //double renderTime = currentTime - frameTimestamp;
    frameTimestamp = currentTime;
    
    //    double speed = 10.0 * renderTime * 60.0;
    //    [myView moveWithSpeed: speed];
    NSLog(@"frame %f",frameTimestamp);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
