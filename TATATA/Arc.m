//
//  Arc.m
//  TATATA
//
//  Created by Che-Wei Wang on 11/23/14.
//
//

#import "Arc.h"

@implementation Arc

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        //self.frame=theFrame;
        point=CGPointMake(self.center.x, self.center.y);
    }
    return self;
}


 - (void)drawRect:(CGRect)rect
 {
 CGContextRef context = UIGraphicsGetCurrentContext();

 CGContextAddArc(context, point.x, point.y, self.frame.size.width*.5, M_PI, M_PI*2.0, NO);
 CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
 CGContextSetLineWidth(context, 1.0);
 
 CGContextDrawPath(context, kCGPathStroke);
 }

@end
