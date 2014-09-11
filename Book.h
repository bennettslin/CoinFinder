//
//  Book.h
//  BookBracket
//
//  Created by Bennett Lin on 9/8/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Book : NSObject <NSCoding>

@property (readonly, nonatomic) NSString *id;
@property (readonly, nonatomic) NSString *author;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) UIImage *image;

@property (readonly, nonatomic) NSUInteger bracketRank;

@end
