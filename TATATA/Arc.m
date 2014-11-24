//
//  Arc.m
//  TATATA
//
//  Created by Che-Wei Wang on 11/23/14.
//
//

#import "Arc.h"

@implementation Arc


 - (void)drawRect:(CGRect)rect
 {
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 //CGPoint point = CGPointMake(0, 100);
 
// CGContextMoveToPoint(context, point.x, point.y);
// point.x += lineLength;
// CGContextAddLineToPoint(context, point.x, point.y);
// point.x += _radius;
 CGContextAddArc(context, _point.x, _point.y, _radius, M_PI, M_PI*2.0, NO);
// point.x += _radius * 2.0;
// CGContextAddArc(context, point.x, point.y, _radius, M_PI, M_PI * 2.0, NO);
// point.x += _radius * 2.0;
// CGContextAddArc(context, point.x, point.y, _radius, M_PI, M_PI * 2.0, NO);
// point.x += _radius * 2.0;
// CGContextAddArc(context, point.x, point.y, _radius, M_PI, M_PI * 2.0, NO);
// point.x += lineLength + _radius;
// CGContextAddLineToPoint(context, point.x, point.y);
// 
 CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
 CGContextSetLineWidth(context, 1.0);
 
 CGContextDrawPath(context, kCGPathStroke);
 }

@end
