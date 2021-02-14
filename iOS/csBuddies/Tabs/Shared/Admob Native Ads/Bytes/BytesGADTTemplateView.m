// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//  Copyright © 2018 Google. All rights reserved.

#import "BytesGADTTemplateView.h"
#import <QuartzCore/QuartzCore.h>

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyCallToActionFont =
@"call_to_action_font";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyCallToActionFontColor =
@"call_to_action_font_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyCallToActionBackgroundColor =
@"call_to_action_background_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeySecondaryFont = @"secondary_font";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeySecondaryFontColor =
@"secondary_font_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeySecondaryBackgroundColor =
@"secondary_background_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyPrimaryFont = @"primary_font";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyPrimaryFontColor = @"primary_font_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyPrimaryBackgroundColor =
@"primary_background_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyTertiaryFont = @"tertiary_font";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyTertiaryFontColor =
@"tertiary_font_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyTertiaryBackgroundColor =
@"tertiary_background_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyMainBackgroundColor =
@"main_background_color";

BytesGADTNativeTemplateStyleKey const BytesGADTNativeTemplateStyleKeyCornerRadius = @"corner_radius";

static NSString* const BytesGADTBlue = @"#5C84F0";

@implementation BytesGADTTemplateView {
    NSDictionary<BytesGADTNativeTemplateStyleKey, NSObject*>* _defaultStyles;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        
        _rootView = [NSBundle.mainBundle loadNibNamed:NSStringFromClass([self class])
                                                owner:self
                                              options:nil]
        .firstObject;
        
        [self addSubview:_rootView];
        
        [self
         addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|[_rootView]|"
                         options:0
                         metrics:nil
                         views:NSDictionaryOfVariableBindings(_rootView)]];
        [self
         addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"V:|[_rootView]|"
                         options:0
                         metrics:nil
                         views:NSDictionaryOfVariableBindings(_rootView)]];
        [self applyStyles];
        [self styleAdBadge];
    }
    return self;
}

- (NSString *)getTemplateTypeName {
    return @"root";
}

/// Returns the style value for the provided key or the default style if no styles dictionary
/// was set.
- (id)styleForKey:(BytesGADTNativeTemplateStyleKey)key {
    return _styles[key] ?: nil;
}

// Goes through all recognized style keys and updates the views accordingly, overwriting the
// defaults.
- (void)applyStyles {
    [self.mediaView sizeToFit];
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyCornerRadius]) {
        float roundedCornerRadius =
        ((NSNumber*)[self styleForKey:BytesGADTNativeTemplateStyleKeyCornerRadius]).floatValue;
        
        // Rounded corners
        self.iconView.layer.cornerRadius = roundedCornerRadius;
        self.iconView.clipsToBounds = YES;
        ((UIButton*)self.callToActionView).layer.cornerRadius = roundedCornerRadius;
        ((UIButton*)self.callToActionView).clipsToBounds = YES;
    }
    
    // Fonts
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryFont]) {
        ((UILabel*)_primaryTextView).font =
        (UIFont*)[self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryFont];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeySecondaryFont]) {
        ((UILabel*)_secondaryTextView).font =
        (UIFont*)[self styleForKey:BytesGADTNativeTemplateStyleKeySecondaryFont];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyTertiaryFont]) {
        ((UILabel*)_tertiaryTextView).font =
        (UIFont*)[self styleForKey:BytesGADTNativeTemplateStyleKeyTertiaryFont];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyCallToActionFont]) {
        ((UIButton*)self.callToActionView).titleLabel.font =
        (UIFont*)[self styleForKey:BytesGADTNativeTemplateStyleKeyCallToActionFont];
    }
    
    // Font colors
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryFontColor])
        ((UILabel*)_primaryTextView).textColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryFontColor];
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeySecondaryFontColor]) {
        ((UILabel*)_secondaryTextView).textColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeySecondaryFontColor];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyTertiaryFontColor]) {
        ((UILabel*)_tertiaryTextView).textColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyTertiaryFontColor];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyCallToActionFontColor]) {
        [((UIButton*)self.callToActionView)
         setTitleColor:(UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyCallToActionFontColor]
         forState:UIControlStateNormal];
    }
    
    // Background colors
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryBackgroundColor]) {
        ((UILabel*)_primaryTextView).backgroundColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryBackgroundColor];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeySecondaryBackgroundColor]) {
        ((UILabel*)_secondaryTextView).backgroundColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeySecondaryBackgroundColor];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyTertiaryBackgroundColor]) {
        ((UILabel*)_tertiaryTextView).backgroundColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyTertiaryBackgroundColor];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyCallToActionBackgroundColor]) {
        ((UIButton*)self.callToActionView).backgroundColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyCallToActionBackgroundColor];
    }
    
    if ([self styleForKey:BytesGADTNativeTemplateStyleKeyMainBackgroundColor]) {
        self.backgroundColor = (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyMainBackgroundColor];
    }
    
    if (_backgroundView && [self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryBackgroundColor]) {
        _backgroundView.backgroundColor =
        (UIColor*)[self styleForKey:BytesGADTNativeTemplateStyleKeyPrimaryBackgroundColor];
    }
}

/// Styles the Ad Badge according to best practices.
- (void)styleAdBadge {
    /*_adBadge.layer.borderColor = _adBadge.textCGColor;
     _adBadge.layer.borderWidth = 1.0;
     _adBadge.layer.cornerRadius = 3.0;*/
}

- (void)setStyles:(NSDictionary<BytesGADTNativeTemplateStyleKey, NSObject*>*)styles {
    _styles = [styles copy];
    [self applyStyles];
}

- (void)setNativeAd:(GADUnifiedNativeAd*)nativeAd {
    [super setNativeAd:nativeAd];
    self.headlineView = _primaryTextView;
    NSString* adBody = nativeAd.body;
    NSString* cta = nativeAd.callToAction;
    NSString* headline = nativeAd.headline;
    NSString* tertiaryText;
    
    if (nativeAd.store.length && !nativeAd.advertiser.length) {
        // Ad has store but not advertiser
        self.storeView = _tertiaryTextView;
        tertiaryText = nativeAd.store;
    } else if (!nativeAd.store.length && nativeAd.advertiser.length) {
        // Ad has advertiser but not store
        self.advertiserView = _tertiaryTextView;
        tertiaryText = nativeAd.advertiser;
    } else if (!nativeAd.store.length && !nativeAd.advertiser.length) {
        // Ad has both store and advertiser, default to showing advertiser.
        self.advertiserView = _tertiaryTextView;
        tertiaryText = nativeAd.advertiser;
    }
    
    ((UILabel*)_primaryTextView).text = headline;
    ((UILabel*)_tertiaryTextView).text = tertiaryText;
    [((UIButton*)self.callToActionView) setTitle:cta forState:UIControlStateNormal];
    // Body text
    // We either show the number of stars an app has, or show the body of the ad.
    // Use the unicode characters for filled in or empty stars.
    if (nativeAd.starRating.floatValue > 0) {
        NSMutableString* stars = [[NSMutableString alloc] initWithString:@""];
        int count = 0;
        for (; count < nativeAd.starRating.intValue; count++) {
            NSString* filledStar = [NSString stringWithUTF8String:"\u2605"];
            [stars appendString:filledStar];
        }
        for (; count < 5; count++) {
            NSString* emptyStar = [NSString stringWithUTF8String:"\u2606"];
            [stars appendString:emptyStar];
        }
        adBody = stars;
        self.starRatingView = _secondaryTextView;
    } else {
        self.bodyView = _secondaryTextView;
    }
    
    ((UILabel*)_secondaryTextView).text = adBody;
    
    if (nativeAd.icon) {
        ((UIImageView*)self.iconView).image = nativeAd.icon.image;
    }
    [self.mediaView setMediaContent:nativeAd.mediaContent];
}

- (void)addHorizontalConstraintsToSuperviewWidth {
    // Add an autolayout constraint to make sure our template view stretches to fill the
    // width of its parent.
    if (self.superview) {
        UIView* child = self;
        [self.superview
         addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|[child]|"
                         options:0
                         metrics:nil
                         views:NSDictionaryOfVariableBindings(child)]];
    }
}

- (void)addVerticalCenterConstraintToSuperview {
    if (self.superview) {
        UIView* child = self;
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.superview
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:child
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
    }
}

/// Creates an opaque UIColor object from a byte-value color definition.
+ (UIColor*)colorFromHexString:(NSString*)hexString {
    if (hexString == nil) {
        return nil;
    }
    NSRange range = [hexString rangeOfString:@"^#[0-9a-fA-F]{6}$" options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return nil;
    }
    unsigned rgbValue = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];  // Bypass '#' character.
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xff0000) >> 16) / 255.0f
                           green:((rgbValue & 0xff00) >> 8) / 255.0f
                            blue:(rgbValue & 0xff) / 255.0f
                           alpha:1];
}
@end
