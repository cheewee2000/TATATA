//
//  Sparkline.m
//  tatata
//
//  Created by Che-Wei Wang on 12/14/14.
//
//

#import "Sparkline.h"

@implementation Sparkline


@synthesize yValues;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawBarGraphWithContext:(CGContextRef)ctx
{
    // Draw the bars
    int kBarWidth=self.frame.size.width/40.0;
    float maxBarHeight = self.frame.size.height;
    float maxValue = [[yValues valueForKeyPath:@"@max.integerValue"] integerValue];
    int nBars=self.frame.size.width/kBarWidth;
    if(nBars>yValues.count)nBars=(int)yValues.count;
    
    for (int i = 0; i < nBars; i++)
    {
        float barX = self.frame.size.width-(nBars-i) * kBarWidth * 1.5+kBarWidth/2.0;
        float barHeight = maxBarHeight * [yValues[i] integerValue]/maxValue;
        CGRect barRect = CGRectMake(barX, maxBarHeight, kBarWidth, -barHeight);
        UIColor *c=[UIColor colorWithWhite:.8 alpha:1];
        if([yValues[i] integerValue]==maxValue)c=[UIColor colorWithRed:255/255 green:163/255.0 blue:0 alpha:1];
        [self drawBar:barRect context:ctx color:c];
    }
}

- (void)drawBar:(CGRect)rect context:(CGContextRef)ctx color:(UIColor*)c
{
    CGContextBeginPath(ctx);
    CGContextSetFillColorWithColor(ctx, c.CGColor);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBarGraphWithContext:context];
}

@end
