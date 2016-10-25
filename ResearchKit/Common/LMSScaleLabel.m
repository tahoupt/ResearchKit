//
//  LMSScaleLabel.m
//  ResearchKit
//
//  Created by Tom Houpt on 16/10/7.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "LMSScaleLabel.h"

@implementation LMSScaleLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithText:(NSString *)text andPosition:(CGFloat)x; {

    self = [super init];
    
    if (self) {
    
        self.text  = text;
        self.axisRelativePosition =x;
    
    }
    
    return self;


}
        

@end
