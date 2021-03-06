/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


/*

Behavioral Cybernetics 2016 T. Houpt
Heavily modified to allow forced 2 choice preference test...


*/

#import "ORKImageSelectionView.h"

#import "ORKImageChoiceLabel.h"

#import "ORKChoiceAnswerFormatHelper.h"

#import "ORKBorderedButton.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

//#import "/Users/houpt/Programming_Github/FoodQuest/FoodQuest/ImagePreferenceChoiceAnswerFormat.h"


@interface ORKChoiceButtonView : UIView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice andButtonLabelText:(NSString *)buttonLabelText;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy) NSString *labelText;

// add a label view underneath
@property (nonatomic, copy) NSString *buttonLabelText;
@property (nonatomic, strong) UILabel *buttonLabelView;

@end


@implementation ORKChoiceButtonView

- (instancetype)initWithImageChoice:(ORKImageChoice *)choice andButtonLabelText:(NSString *)buttonLabelText;{
    self = [super init];
    if (self) {
        _labelText = choice.text.length > 0 ? choice.text: @" ";
        _buttonLabelText = buttonLabelText;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.exclusiveTouch = YES;
       
        if (choice.selectedStateImage) {
            [_button setImage:choice.selectedStateImage forState:UIControlStateSelected];
        }
        
        [_button setImage:choice.normalStateImage forState:UIControlStateNormal];
        
        _button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_button];
        
           _buttonLabelView = [[UILabel alloc] init];
            [_buttonLabelView setText:_buttonLabelText];
            [_buttonLabelView setTextColor:[UIColor grayColor]];
            _buttonLabelView.numberOfLines = 0;
            _buttonLabelView.adjustsFontSizeToFitWidth = YES;
            _buttonLabelView.minimumScaleFactor = 0.2;
            [_buttonLabelView setTextAlignment:NSTextAlignmentCenter];
            [_buttonLabelView setFont:[UIFont italicSystemFontOfSize:14]];
        
        [self addSubview:_buttonLabelView];
        
        
        // add button labelview
        ORKEnableAutoLayoutForViews(@[_button, _button.imageView, _buttonLabelView]);
        [self setUpConstraints];
        
        // Accessibility
        NSString *trimmedText = [self.labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( trimmedText.length == 0 ) {
            self.button.accessibilityLabel = ORKLocalizedString(@"AX_UNLABELED_IMAGE", nil);
        } else {
            self.button.accessibilityLabel = self.labelText;
        }
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{ @"button": _button ,@"buttonLabelView":_buttonLabelView};
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]-5-[buttonLabelView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    UIImage *image = [_button imageForState:UIControlStateNormal];
    if (image.size.height > 0 && image.size.width > 0) {
        // Keep Aspect ratio
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button.imageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:image.size.height / image.size.width
                                                             constant:0.0]];
        // button's height <= image
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:nil attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:image.size.height]];
    } else {
        // Keep Aspect ratio
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_button
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_button.imageView
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:0.0]];
        ORK_Log_Warning(@"The size of imageChoice's normal image should not be zero. %@", image);
    }
    
     [constraints addObject:[NSLayoutConstraint constraintWithItem:_buttonLabelView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end


static const CGFloat SpacerWidth = 10.0;

@implementation ORKImageSelectionView {
    ORKChoiceAnswerFormatHelper *_helper;
    NSArray *_buttonViews;
    NSArray *_imageIndexes;
    ORKImageChoiceLabel *_choiceLabel;
    ORKImageChoiceLabel *_placeHolderLabel;
    UIButton *_noPrefButton;
    UILabel *_noPrefLabel;
    BOOL _showSelectedAnswer;
}

- (ORKImageChoiceLabel *)makeLabel {
    ORKImageChoiceLabel *label = [[ORKImageChoiceLabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

- (instancetype)initWithImageChoiceAnswerFormat:(ORKImageChoiceAnswerFormat *)answerFormat answer:(id)answer {
    self = [self init];
    if (self) {
        
        NSAssert([answerFormat isKindOfClass:[ORKImageChoiceAnswerFormat class]], @"answerFormat should be an instance of ORKImageChoiceAnswerFormat");
        
        _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
        
        _placeHolderLabel = [self makeLabel];
        _placeHolderLabel.text = [ORKLocalizedString(@"PLACEHOLDER_IMAGE_CHOICES", nil) stringByAppendingString:@""];
        _placeHolderLabel.textColor = [UIColor ork_midGrayTintColor];
        
        _choiceLabel = [self makeLabel];
        
        [self resetLabelText];
        
        [self addSubview:_choiceLabel];
        [self addSubview:_placeHolderLabel];
        
        NSMutableArray *buttonViews = [NSMutableArray new];
        NSMutableArray *labelTextArray = [NSMutableArray new];
        
         BOOL showImageLabels = NO;
        if ([answerFormat respondsToSelector:@selector(showImageLabels)]) {
            showImageLabels = [answerFormat performSelector:@selector(showImageLabels)];
        }

        NSArray *imageChoices = answerFormat.imageChoices;
        for (ORKImageChoice *imageChoice in imageChoices) {
                    
            NSString *buttonLabelText;
            if (showImageLabels) {
                buttonLabelText = [imageChoice.text copy];
            }
            else {
                buttonLabelText  = @"";
            }
        
            if (imageChoice.text) {
                [labelTextArray addObject:imageChoice.text];
            }
            
            ORKChoiceButtonView *buttonView = [[ORKChoiceButtonView alloc] initWithImageChoice:imageChoice andButtonLabelText:buttonLabelText];
            [buttonView.button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttonViews addObject:buttonView];
            [self addSubview:buttonView];
            
//            UILabel *buttonLabelView = [[UILabel alloc] init];
//            if (imageChoice.text) {
//                [buttonLabelView setText:imageChoice.text];
//            }
//            [buttonLabelView setTextColor:[UIColor grayColor]];
//            [buttonLabelView setTextAlignment:NSTextAlignmentCenter];
//            [buttonLabelView setFont:[UIFont italicSystemFontOfSize:12]];
//            [buttonLabelViews addObject:buttonLabelView];
//            [self addSubview:buttonLabelView];

            
        }
        
        _choiceLabel.textArray = labelTextArray;
        // make a copy of the image indexes for later use by answer
        _imageIndexes = @[[[answerFormat.imageChoices firstObject] value],[[answerFormat.imageChoices objectAtIndex:1] value]];
        _buttonViews = buttonViews;
       // _buttonLabelViews = buttonLabelViews;
        
        
        
        
        for (UILabel *label in @[_choiceLabel, _placeHolderLabel]) {
            label.isAccessibilityElement = NO;
        }
        
        //-------------------------------------------------------------------
        
// NOTE: added code for "no preference label"
// so need to pass in a flag to turn button on or off...
// because we don't want to explictly include a subclass, 
// we'll just see if the answerFormat responds to the appropriate selectors


            _noPrefButton = [ORKBorderedButton new];
                    _noPrefButton.exclusiveTouch = YES;

            [_noPrefButton setTitle:@"No Preference" forState:UIControlStateNormal];
            _noPrefButton.contentEdgeInsets = (UIEdgeInsets){12, 12, 12, 12};

            CGFloat x = (self.bounds.size.width - 200)/2;
            [_noPrefButton setFrame:CGRectMake(x,0,200,50)];


       [_noPrefButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside]; 
       [self addSubview:_noPrefButton];
        
        ORKEnableAutoLayoutForViews(@[_noPrefButton]);
        
        _noPrefLabel = [[UILabel alloc] init];
        [_noPrefLabel setText:@"(equally good or equally bad)"];
        [_noPrefLabel setTextColor:[UIColor grayColor]];
        [_noPrefLabel setTextAlignment:NSTextAlignmentCenter];
        
        [_noPrefLabel setFont:[UIFont italicSystemFontOfSize:12]];

        if ([answerFormat respondsToSelector:@selector(allowNoPreference)]) {
            _noPrefButton.hidden = ![answerFormat performSelector:@selector(allowNoPreference)];
            _noPrefLabel.hidden = _noPrefButton.hidden;
        }

     
        [self addSubview:_noPrefLabel];
        ORKEnableAutoLayoutForViews(@[_noPrefLabel]);

        
        
        //-------------------------------------------------------------------

        
        ORKEnableAutoLayoutForViews(@[_placeHolderLabel, _choiceLabel]);
        ORKEnableAutoLayoutForViews(_buttonViews);
        [self setUpConstraints];
        
        
        if ([answerFormat respondsToSelector:@selector(showSelectedAnswer)]) {
            _showSelectedAnswer = [answerFormat performSelector:@selector(showSelectedAnswer)];
        }


    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_choiceLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_choiceLabel": _choiceLabel}]];
                                               

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_noPrefLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_noPrefLabel": _noPrefLabel}]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_placeHolderLabel]-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:@{@"_placeHolderLabel": _placeHolderLabel}]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_placeHolderLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_choiceLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];

    ORKChoiceButtonView *previousView = nil;
    for (ORKChoiceButtonView *buttonView in _buttonViews) {
        
   //     UILabel *button_label = [_buttonLabelViews objectAtIndex:[_buttonViews indexOfObject:buttonView]];
        NSDictionary *views = NSDictionaryOfVariableBindings(buttonView,_choiceLabel,_noPrefButton,_noPrefLabel);
        
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonView(<=200)]-15-[_noPrefButton(<=48)]-[_noPrefLabel(<=30)]-30-[_choiceLabel(<=60)]-30@999-|"
                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:nil
                                                   views:views]];
                                                   
            
        
        if (previousView) {
            // ButtonView left trailing
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:previousView
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0
                                                                 constant:SpacerWidth]];
            
            // All ButtonViews has equal width
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:previousView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
        } else {
            // ButtonView left trailing
            [constraints addObject:[NSLayoutConstraint constraintWithItem:buttonView
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0
                                                                 constant:SpacerWidth]];
        }
        previousView = buttonView;
    
    
    
    
    }
    
    if (previousView) {
        // ButtonView right trailing
        [constraints addObject:[NSLayoutConstraint constraintWithItem:previousView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-SpacerWidth]];
    }
    


    [constraints addObject:[NSLayoutConstraint constraintWithItem:_noPrefButton
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0]];    

  
      
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setAnswer:(id)answer {
    _answer = answer;
    
    NSArray *selectedIndexes = [_helper selectedIndexesForAnswer:answer];
    
    [self setSelectedIndexes:selectedIndexes];
}

- (void)resetLabelText {
    _placeHolderLabel.hidden = NO;
    _choiceLabel.hidden = !_placeHolderLabel.hidden;
    
}

- (void)setLabelText:(NSString *)text {

    
    if (_showSelectedAnswer) {
        // original code
        _choiceLabel.text = text;
        _choiceLabel.textColor = [UIColor blackColor];
        
        _choiceLabel.hidden = NO;
        _placeHolderLabel.hidden = !_choiceLabel.hidden;

    }
    else {
        // keep choice label hidden
        _placeHolderLabel.hidden = NO;
        _choiceLabel.hidden = !_placeHolderLabel.hidden;

    
    }
    
}

- (IBAction)buttonTapped:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.selected) {
        [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             ORKChoiceButtonView *buttonView = obj;
             if (buttonView.button != button) {
                 buttonView.button.selected = NO;
             } else {
                 [self setLabelText:buttonView.labelText];
                 //set label text display under image buttons, e.g. the seleted item label
             }
             
         }];
         
        
    } else {
        [self resetLabelText];
    }
    
    
    
   // _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];
    
    if (button == _noPrefButton) {
    
#define kNoPreferenceAnswer @[@(-1)]

        [self setLabelText:@"No Preference"];
        // choice label is image description (e.g. "cheeseburger", imageIndexes are image numbers (i.e. index into image array),e.g. "768"
   //     NSString *no_pref_answer = [NSString stringWithFormat:@"%@=%@",_choiceLabel.textArray[0],_choiceLabel.textArray[1]];
        NSString *no_pref_answer = [NSString stringWithFormat:@"%@=%@",_imageIndexes[0],_imageIndexes[1]];

        _answer = [NSArray arrayWithObject:no_pref_answer];
    }
    else {
        _noPrefButton.selected = NO;
        
        
        NSInteger more_pref_index = [[[self selectedIndexes] firstObject] integerValue];
        NSInteger less_pref_index = [[[self unselectedIndexes] firstObject]  integerValue];
      //  NSString *pref_answer = [NSString stringWithFormat:@"%@>%@",_choiceLabel.textArray[more_pref_index],_choiceLabel.textArray[less_pref_index]];
        NSString *pref_answer = [NSString stringWithFormat:@"%@>%@",_imageIndexes[more_pref_index],_imageIndexes[less_pref_index]];

        [self setLabelText:pref_answer];
        
         _answer = [NSArray arrayWithObject:pref_answer];
        
       // _answer = [_helper answerForSelectedIndexes:[self selectedIndexes]];

    }

    
    if ([_delegate respondsToSelector:@selector(selectionViewSelectionDidChange:)]) {
        [_delegate selectionViewSelectionDidChange:self];
    }
    
    }


- (NSArray *)selectedIndexes {
    NSMutableArray *array = [NSMutableArray new];
    
    [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         ORKChoiceButtonView *buttonView = obj;
         if (buttonView.button.selected)
         {
             [array addObject:@(idx)];
         }
     }];
    
    return [array copy];
}
- (NSArray *)unselectedIndexes {
    NSMutableArray *array = [NSMutableArray new];
    
    [_buttonViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         ORKChoiceButtonView *buttonView = obj;
         if (!buttonView.button.selected)
         {
             [array addObject:@(idx)];
         }
     }];
    
    return [array copy];
}

- (void)setSelectedIndexes:(NSArray *)selectedIndexes {
    [selectedIndexes enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (![object isKindOfClass:[NSNumber class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"selectedIndexes should only containt objects of the NSNumber kind" userInfo:nil];
        }
        NSNumber *number = object;
        if (number.unsignedIntegerValue < _buttonViews.count) {
            ORKChoiceButtonView *buttonView = _buttonViews[number.unsignedIntegerValue];
            [buttonView button].selected = YES;
            [self setLabelText:buttonView.labelText];
        }
    }];
}

- (BOOL)isAccessibilityElement {
    return NO;
}

@end
