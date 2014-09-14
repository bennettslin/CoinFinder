//
//  UIImage+Resize.m
//  CoinFinder
//
//  Created by Bennett Lin on 9/13/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

-(UIImage *)resizedImageWithBounds:(CGSize)bounds {
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio = MIN(horizontalRatio, verticalRatio);
  CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
  
  UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
  [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
