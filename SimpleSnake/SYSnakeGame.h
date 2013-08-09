//
//  SnakeGame.h
//  SimpleSnake
//
//  Created by Sherlock on 8/9/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYSnakeGame : NSObject

@property (nonatomic, strong) UIColor *foodColor;
@property (nonatomic, strong) UIColor *snakeColor;

- (id)initWithSize:(CGSize)size;
- (void)needMoveTo:(CGPoint)point;
- (void)update;
- (void)reset;
- (NSArray *)getGraphicLines;

@end

@interface GraphicLine : NSObject

@property (nonatomic, assign) CGPoint start;
@property (nonatomic, assign) CGPoint end;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UIColor *color;

@end
