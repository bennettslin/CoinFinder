//
//  IndentedTextField.m
//  DetectorLog
//
//  Created by Bennett Lin on 9/11/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "IndentedTextField.h"

#define kHorizontalPadding 5.f
#define kVerticalPadding 7.f

@implementation IndentedTextField

-(CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.origin.x + kHorizontalPadding,
                    bounds.origin.y + kVerticalPadding,
                    bounds.size.width - kHorizontalPadding * 2,
                    bounds.size.height - kVerticalPadding * 2);
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
  return [self textRectForBounds:bounds];
}

-(void)drawPlaceholderInRect:(CGRect)rect {
  UIColor *colour = [UIColor lightGrayColor];
  if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)])
    { // iOS7 and later
      NSDictionary *attributes = @{NSForegroundColorAttributeName: colour, NSFontAttributeName: self.font};
      CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
      [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes]; }
  else { // iOS 6
    [colour setFill];
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
  }
}

@end
