//
//  FQScaleSlider.m
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/8.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "FQScaleSlider.h"

@implementation FQScaleSlider

-(void)setLinearSteps:(NSArray *)linearSteps {

    _linearSteps = linearSteps;
}

-(NSArray *)linearSteps {

    return _linearSteps;
}

static CGFloat LineWidth = 1.0;
- (void)drawRect:(CGRect)rect {

    [super drawRect:rect];
    CGRect bounds = self.bounds;
    CGRect trackRect = [self trackRectForBounds:bounds];
    CGFloat centerY = bounds.size.height / 2.0;
    
    [[UIColor blackColor] set];
    
    NSInteger numberOfLinearSteps = [_linearSteps count];
    
    if (numberOfLinearSteps > 0) {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path setLineWidth:LineWidth];
        
#define kTickWidth 5 // originally 3.5
        for (int index = 0; index < numberOfLinearSteps; index++) {
            CGFloat linearOffset = (([[_linearSteps objectAtIndex:index] floatValue] + 100) / 200.0);
            CGFloat x = trackRect.origin.x + (trackRect.size.width - LineWidth) * linearOffset;
            x += LineWidth / 2; // Draw in center of line (center of pixel on 1x devices)
            [path moveToPoint:CGPointMake(x, centerY - kTickWidth)];
            [path addLineToPoint:CGPointMake(x, centerY + kTickWidth)];
        }
        [path stroke];
        // make sure there is a 0 line
        CGFloat x = trackRect.origin.x + (trackRect.size.width - LineWidth) * 0.5;
        [path moveToPoint:CGPointMake(x, centerY - kTickWidth)];
        [path addLineToPoint:CGPointMake(x, centerY + kTickWidth)];
        
    }
    [[UIBezierPath bezierPathWithRect:trackRect] fill];
}


@end
