//
//  LMSScaleLabel.m
//  ResearchKit
//
//  Created by Tom Houpt on 16/10/7.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "LMSScaleLabel.h"
#import "ORKHelpers_Internal.h"

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
        [self setFont:ORKMediumFontWithSize(kLMSScaleLabelFontSize)];
    }
    
    return self;


}


+ (UIFont *)defaultFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
   //  return [UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
    
    return [UIFont systemFontOfSize:kLMSScaleLabelFontSize];
}

        

@end
