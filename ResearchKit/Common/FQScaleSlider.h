//
//  FQScaleSlider.h
//  FoodQuest
//
//  Created by Tom Houpt on 16/10/8.
//  Copyright © 2016 Behavioral Cybernetics. All rights reserved.
//

#import "ORKScaleSlider.h"

@interface FQScaleSlider : ORKScaleSlider {

    NSArray *_linearSteps;
}

-(void)setLinearSteps:(NSArray *)linearSteps ;
-(NSArray *)linearSteps ;

@end
