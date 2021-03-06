/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 Copyright (c) 2015, Bruce Duncan.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKScaleSliderView.h"

#import "ORKScaleRangeDescriptionLabel.h"
#import "ORKScaleRangeImageView.h"
#import "ORKScaleRangeLabel.h"
#import "ORKScaleSlider.h"
#import "ORKScaleValueLabel.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKHelpers_Internal.h"

#import "ORKSkin.h"
#import "LMSScaleLabel.h"
#import "FQScaleSlider.h"
// NOTE: what is better way to include our custom classes
#import "/Users/houpt/Programming_Github/FoodQuest/FoodQuest/ImageHedonicScaleAnswerFormat.h"

//#define LAYOUT_DEBUG 1


// NOTE: will need to pass in array of LMSScaleLabel scaleLabels and an NSString imageName

@implementation ORKScaleSliderView {
    id<ORKScaleAnswerFormatProvider> _formatProvider;
    FQScaleSlider *_slider;
//    ORKScaleRangeDescriptionLabel *_leftRangeDescriptionLabel;
//    ORKScaleRangeDescriptionLabel *_rightRangeDescriptionLabel;
    NSMutableArray<ORKScaleRangeLabel *> *_textChoiceLabels;
    NSNumber *_currentNumberValue;
    
    
    
    /* ADDED AS TEST */
    NSMutableArray<LMSScaleLabel *> *scaleLabels; 
    UIImageView *_imageView; // the image to be rated, once it has been opened from file
    NSString *_imageName; // a name of the image file, eg @"cheeseburger.png" ; should be in bundle
    NSString * _imageID; // an id for the image, e.g. index in foodpics database
    NSString * _scaleType; // lms or natick
    NSString *_currentRatingText; // 
   ORKScaleRangeDescriptionLabel *_imageLabel;

    /* END OF TEST */

}

- (instancetype)initWithFormatProvider:(id<ORKScaleAnswerFormatProvider>)formatProvider
                              delegate:(id<ORKScaleSliderViewDelegate>)delegate {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _formatProvider = formatProvider;
        _delegate = delegate;
        
        
        _slider = [[FQScaleSlider alloc] initWithFrame:CGRectZero];
        _slider.linearSteps = ((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).scaleValues;
        _slider.userInteractionEnabled = YES;
        _slider.contentMode = UIViewContentModeRedraw;
        [self addSubview:_slider];
        
        _slider.maximumValue = [formatProvider maximumNumber].floatValue;
        _slider.minimumValue = [formatProvider minimumNumber].floatValue;
        
        
        NSInteger numberOfSteps = [formatProvider numberOfSteps];
        _slider.numberOfSteps = numberOfSteps;
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

        BOOL isVertical = [formatProvider isVertical];
        _slider.vertical = isVertical;

        NSArray<ORKTextChoice *> *textChoices = [[self textScaleFormatProvider] textChoices];
        _slider.textChoices = textChoices;
        
        
 // TAH: if Hedonic Scale, then we're always vertical and set our own scale labels
 // Natick uses text choices
 
        if (isVertical && textChoices) {
            // Generate an array of labels for all the text choices
            _textChoiceLabels = [NSMutableArray new];
            for (int i = 0; i <= numberOfSteps; i++) {
                ORKTextChoice *textChoice = textChoices[i];
                ORKScaleRangeLabel *stepLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
                stepLabel.text = textChoice.text;
                stepLabel.textAlignment = NSTextAlignmentLeft;
                stepLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:stepLabel];
                [_textChoiceLabels addObject:stepLabel];
            }
        } 

// else { // not text choices        

           
// TAH: don't need left and rightRangeDescriptionLabels
//            _leftRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
//            _leftRangeDescriptionLabel.numberOfLines = -1;
//            [self addSubview:_leftRangeDescriptionLabel];
//            
//
//            _rightRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
//            _rightRangeDescriptionLabel.numberOfLines = -1;
//            [self addSubview:_rightRangeDescriptionLabel];
//            
//            if (textChoices) {
//                _leftRangeDescriptionLabel.textColor = [UIColor blackColor];
//                _rightRangeDescriptionLabel.textColor = [UIColor blackColor];
//            }




#if LAYOUT_DEBUG
            self.backgroundColor = [UIColor greenColor];
            _slider.backgroundColor = [UIColor redColor];
            _leftRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
            _rightRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
#endif
            
                   
//            if (isVertical) {
//                _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//                _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//            } else {
//                _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//                _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
//            }
//            
//            _leftRangeDescriptionLabel.text = [formatProvider minimumValueDescription];
//            _rightRangeDescriptionLabel.text = [formatProvider maximumValueDescription];
//
//           
//            
//
//            _leftRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
//            _rightRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;




 //       } // not textChoices
        
        


// add imageView

        NSInteger _imageIndex =((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).imageIndex;
        NSString * _extension =((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).imageType;
        _imageName = [NSString stringWithFormat:@"%ld.%@", (long)_imageIndex,_extension];
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imageName]];
        _imageID = [NSString stringWithFormat:@"%ld", ((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).imageIndex];
       [self addSubview:_imageView];
       _imageView.translatesAutoresizingMaskIntoConstraints = NO;

// add image Label

            _imageLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
            
            _imageLabel.font = ORKMediumFontWithSize(12);
            _imageLabel.numberOfLines = 0;
            _imageLabel.adjustsFontSizeToFitWidth = YES;
            _imageLabel.minimumScaleFactor = 0.2;
            _imageLabel.textAlignment = NSTextAlignmentCenter;
            if (((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).showImageLabel) {
                _imageLabel.text = ((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).imageLabel;

            }
            else { _imageLabel.text = @""; }
            [self addSubview:_imageLabel];
            
            _imageLabel.translatesAutoresizingMaskIntoConstraints = NO;


        self.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        
        
// add scale labels


        NSArray *hedonicLabels = ((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).scaleLabels;
        NSArray *hedonicValues = ((ImageHedonicScaleAnswerFormat *)(self.formatProvider)).scaleValues;
        
        scaleLabels = [NSMutableArray array];

        for (int i = 0; i< [hedonicLabels count]; i++) {
            LMSScaleLabel *scale_label = [[LMSScaleLabel alloc] initWithText:[hedonicLabels objectAtIndex:i ] andPosition:  [[hedonicValues objectAtIndex:i ] floatValue]];
            scale_label.translatesAutoresizingMaskIntoConstraints = NO;
            [scaleLabels addObject: scale_label];
            [self addSubview:scale_label];

        }
  
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
//    BOOL isVertical = [_formatProvider isVertical];
    NSArray<ORKTextChoice *> *textChoices = _slider.textChoices;
    NSDictionary *views = nil;
//    if (isVertical && textChoices) {
//        views = NSDictionaryOfVariableBindings(_slider);
//    } else {
//    
//        if (isVertical) {
//
//        views = NSDictionaryOfVariableBindings(_slider, _leftRangeDescriptionLabel, _rightRangeDescriptionLabel,_imageView);
//        
//        }
//        else {
//           views = NSDictionaryOfVariableBindings(_slider, _leftRangeDescriptionLabel, _rightRangeDescriptionLabel,_imageView);     
//        }
//    }
//    

    views = NSDictionaryOfVariableBindings(_slider,_imageView);

    NSMutableArray *constraints = [NSMutableArray new];
//    if (isVertical) {
//        _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//        _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        
        // Vertical slider constraints
        // Keep the thumb the same distance from the value label as in horizontal mode
        const CGFloat ValueLabelSliderMargin = 23.0;
        // Keep the shadow of the thumb inside the bounds
        const CGFloat SliderMargin = 20.0;
        const CGFloat SideLabelMargin = 24;
        
//        if (textChoices) {
//            [constraints addObject:[NSLayoutConstraint constraintWithItem:_slider
//                                                                attribute:NSLayoutAttributeCenterY
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:self
//                                                                attribute:NSLayoutAttributeCenterY
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//            
//            [constraints addObjectsFromArray:
//             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-kSliderMargin-[_slider]-kSliderMargin-|"
//                                                     options:NSLayoutFormatDirectionLeadingToTrailing
//                                                     metrics:@{@"kSliderMargin": @(SliderMargin)}
//                                                       views:views]];
//            
//            
//            for (int i = 0; i < _textChoiceLabels.count; i++) {
//                // Put labels to the right side of the slider.
//                [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
//                                                                 attribute:NSLayoutAttributeLeading
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:_slider
//                                                                 attribute:NSLayoutAttributeCenterX
//                                                                multiplier:1.0
//                                                                  constant:SideLabelMargin]];
//                
//                if (i == 0) {
//                    // First label
//                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
//                                                                        attribute:NSLayoutAttributeCenterY
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:_slider
//                                                                        attribute:NSLayoutAttributeBottom
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                        relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                           toItem:self
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                       multiplier:0.5
//                                                                         constant:0.0]];
//                } else {
//                    // Middle labels
//                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i - 1]
//                                                                        attribute:NSLayoutAttributeTop
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:_textChoiceLabels[i]
//                                                                        attribute:NSLayoutAttributeBottom
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i - 1]
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:_textChoiceLabels[i]
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i - 1]
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:_textChoiceLabels[i]
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                       multiplier:1.0
//                                                                         constant:0.0]];
//                    
//                    // Last label
//                    if (i == (_textChoiceLabels.count - 1)) {
//                        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
//                                                                            attribute:NSLayoutAttributeCenterY
//                                                                            relatedBy:NSLayoutRelationEqual
//                                                                               toItem:_slider
//                                                                            attribute:NSLayoutAttributeTop
//                                                                           multiplier:1.0
//                                                                             constant:0.0]];
//                    }
//                }
//            }
//        }  // text choices
//        else {
        
                                                              
     
        // vertical slider constraints
        
        
// make  imageview  0.4 times the width of self
                                              
 [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:0.4
                                                                 constant:0.0]];  

// set aspect ratio of imageView
[constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_imageView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:(_imageView.frame.size.height/_imageView.frame.size.width)
                                                                 constant:0.0]];   
                                                                 
                                                                 
                                                                 
//  Align the self  left with the imageView's left (with slight inset of 8 pixels)
[constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_imageView
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0
                                                                 constant:-8]]; 
                                                                 
//  vertically center the imageView
[constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]]; 
               
 // put image label centered, underneath imageView                                                
[constraints addObject:[NSLayoutConstraint constraintWithItem:_imageLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_imageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];  
                                                                  
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_imageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant: 0]];
                                                                  
//      [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageLabel
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:_imageView
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                multiplier:2.0
//                                                                  constant: 0]];                                                                      
                                                                                                                                   
 
         [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_imageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant: 10]];     

   // set the slider a little to the right of the midline
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1
                                                                // constant:(SideLabelMargin/2)]];
                                                                 constant:0]];


                                       
// put the slider equidistant from top and bottom of self view

        [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-kSliderMargin-[_slider]-kSliderMargin-|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:@{@"kSliderMargin": @(SliderMargin)}
                                                       views:views]];
  
            
// put description labels at least a set margin of 8 from top edge and left edge and bottom edge

//            [constraints addObjectsFromArray:
//             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=8)-[_rightRangeDescriptionLabel]"
//                                                     options:NSLayoutFormatDirectionLeadingToTrailing
//                                                     metrics:nil
//                                                       views:views]];
//                                                       
//            [constraints addObjectsFromArray:
//             [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightRangeDescriptionLabel]-(>=8)-|"
//                                                     options:NSLayoutFormatDirectionLeadingToTrailing
//                                                     metrics:nil
//                                                       views:views]];
//            [constraints addObjectsFromArray:
//             [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_leftRangeDescriptionLabel(==_rightRangeDescriptionLabel)]-(>=8)-|"
//                                                     options:NSLayoutFormatDirectionLeadingToTrailing
//                                                     metrics:nil
//                                                       views:views]];
//            
//            [constraints addObjectsFromArray:
//             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightRangeDescriptionLabel]-(>=8)-[_leftRangeDescriptionLabel]-(>=8)-|"
//                                                     options:NSLayoutFormatDirectionLeadingToTrailing
//                                                     metrics:nil
//                                                       views:views]];
//            
//    // Set the margin between the slider and the descriptionLabels
//            [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeDescriptionLabel
//                                                                attribute:NSLayoutAttributeLeft
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:_slider
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:SideLabelMargin]];
//            
//            [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeDescriptionLabel
//                                                                attribute:NSLayoutAttributeLeft
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:_slider
//                                                                attribute:NSLayoutAttributeCenterX
//                                                               multiplier:1.0
//                                                                 constant:SideLabelMargin]];
//            
//    // Limit the height of the descriptionLabels
//            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeDescriptionLabel
//                                                             attribute:NSLayoutAttributeHeight
//                                                             relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                toItem:_slider
//                                                             attribute:NSLayoutAttributeHeight
//                                                            multiplier:0.5
//                                                              constant:SliderMargin]];
//            
//            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeDescriptionLabel
//                                                             attribute:NSLayoutAttributeHeight
//                                                             relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                toItem:_slider
//                                                             attribute:NSLayoutAttributeHeight
//                                                            multiplier:0.5
//                                                              constant:SliderMargin]];
//            
//            
//    // Align the descriptionLabels with the slider view
//            [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeDescriptionLabel
//                                                                attribute:NSLayoutAttributeCenterY
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:_slider
//                                                                attribute:NSLayoutAttributeTop
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//            
//            [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeDescriptionLabel
//                                                                attribute:NSLayoutAttributeCenterY
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:_slider
//                                                                attribute:NSLayoutAttributeBottom
//                                                               multiplier:1.0
//                                                                 constant:0.0]];
//                                                
                                                                 
                                                                        
        for (int i = 0; i < [scaleLabels count]; i++) {
           
            LMSScaleLabel *scaleLabel = [scaleLabels objectAtIndex:i];
            
             CGFloat multiplier =  scaleLabel.axisRelativePosition; // -100 to 100
             multiplier += 100; // 0 to 200
             multiplier = 200 - multiplier; //200 t0 0
             multiplier /= 100; // 2.0 to 0
             multiplier *= 0.87;
             if (multiplier < 0.01) { multiplier = 0.01; }
            
            
            
// -100 to 100 -> 0 to 200 -> 0 -> 2


            
             [constraints addObject:[NSLayoutConstraint
                constraintWithItem: scaleLabel
                attribute: NSLayoutAttributeCenterY
                relatedBy: NSLayoutRelationEqual
                toItem: _slider
                attribute: NSLayoutAttributeCenterY
                multiplier: multiplier
                constant: SliderMargin
                ]];  
                // axis relative poition runs from -100 to +100
   
            [constraints addObject:[NSLayoutConstraint 
                constraintWithItem:scaleLabel
                attribute:NSLayoutAttributeLeft
                relatedBy:NSLayoutRelationEqual
                toItem:_slider
                attribute:NSLayoutAttributeCenterX
                multiplier:1.0
                constant:SideLabelMargin]];                                                                                              
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                      
            } // scale labels
                                                                                                 
//        } // not text choices, vertical
//    } 
    [NSLayoutConstraint activateConstraints:constraints];
}

- (id<ORKTextScaleAnswerFormatProvider>)textScaleFormatProvider {
    if ([[_formatProvider class] conformsToProtocol:@protocol(ORKTextScaleAnswerFormatProvider)]) {
        return (id<ORKTextScaleAnswerFormatProvider>)_formatProvider;
    }
    return nil;
}

- (void)setCurrentNumberValue:(NSNumber *)value {
    
    _currentNumberValue = value ? [_formatProvider normalizedValueForNumber:value] : nil;
    _slider.showThumb = _currentNumberValue ? YES : NO;
    
    [self updateCurrentValueLabel];
    _slider.value = _currentNumberValue.floatValue;
}

- (NSUInteger)currentTextChoiceIndex {
    return _currentNumberValue.unsignedIntegerValue - 1;
}

- (void)updateCurrentValueLabel {
    
    if (_currentNumberValue) {
        if ([self textScaleFormatProvider]) {
            ORKTextChoice *textChoice = [[self textScaleFormatProvider] textChoiceAtIndex:[self currentTextChoiceIndex]];
            self.valueLabel.text = textChoice.text;
        } else {
            NSNumber *newValue = [_formatProvider normalizedValueForNumber:_currentNumberValue];
            _valueLabel.text = [_formatProvider localizedStringForNumber:newValue];
        }
    } else {
        _valueLabel.text = @"";
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    
    _currentNumberValue = [_formatProvider normalizedValueForNumber:@(_slider.value)];
    [self updateCurrentValueLabel];
    [self notifyDelegate];
}

- (void)notifyDelegate {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scaleSliderViewCurrentValueDidChange:)]) {
        [self.delegate scaleSliderViewCurrentValueDidChange:self];
    }
}

- (void)setCurrentTextChoiceValue:(id<NSCopying, NSCoding, NSObject>)currentTextChoiceValue {
    
    if (currentTextChoiceValue) {
        NSUInteger index = [[self textScaleFormatProvider] textChoiceIndexForValue:currentTextChoiceValue];
        if (index != NSNotFound) {
            [self setCurrentNumberValue:@(index + 1)];
        } else {
            [self setCurrentNumberValue:nil];
        }
    } else {
        [self setCurrentNumberValue:nil];
    }
}

- (id<NSCopying, NSCoding, NSObject>)currentTextChoiceValue {
    id<NSCopying, NSCoding, NSObject> value = [[self textScaleFormatProvider] textChoiceAtIndex:[self currentTextChoiceIndex]].value;
    return value;
}

- (id)currentAnswerValue {
    if ([self textScaleFormatProvider]) {
        id<NSCopying, NSCoding, NSObject> value = [self currentTextChoiceValue];
        return value ? @[value] : @[];
    } else {

        
       //  return _currentNumberValue;
        
        // NOTE: want to modify for hedonic scale to return @"<item_id>=<currentNumberValue>"
        // so should be moved to subclass
        // only works if we can return a string
        
        // NOTE: as a hack, encode imageID as imageID * 1000 + currentNumberValue
        // currentNumberValue ranges from -100 to +100, so can put imageID in 1000s
        // 
         
        double currentRating = [_currentNumberValue doubleValue];
        
        if (currentRating < 0.0) { 
            currentRating = currentRating + (-1.0 * [_imageID doubleValue] * 1000.0); 
        }
        else { currentRating = currentRating + ([_imageID doubleValue] * 1000.0); }
        
        return [NSNumber numberWithDouble:currentRating];
   

    }
}

- (void)setCurrentAnswerValue:(id)currentAnswerValue {
    if ([self textScaleFormatProvider]) {
        
        if (ORKIsAnswerEmpty(currentAnswerValue)) {
            [self setCurrentTextChoiceValue:nil];
        } else {
            [self setCurrentTextChoiceValue:[currentAnswerValue firstObject]];
        }
    } else {
        return [self setCurrentNumberValue:currentAnswerValue];
    }
}

#pragma mark - Accessibility

// Since the slider is the only interesting thing within this cell, we make the
// cell a container with only one element, i.e. the slider.

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return (_slider != nil ? 1 : 0);
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return _slider;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return (element == _slider ? 0 : NSNotFound);
}

@end
