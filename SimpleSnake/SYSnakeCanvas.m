//
//  SnakeCanvas.m
//  SimpleSnake
//
//  Created by Sherlock on 8/8/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import "SYSnakeCanvas.h"

@interface SYSnakeCanvas() {
  SYSnakeGame *_game;
  NSTimer *_spinnerTimer;
}

@end

@implementation SYSnakeCanvas

#pragma mark - UIView Lifecycle

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  [self drawScene];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  [_game needMoveTo:[touch locationInView:self]];
}

#pragma mark - Public Methods

- (void)setGame:(SYSnakeGame *)game
{
  _game = game;
}

- (void)startGame
{
  if (nil == _spinnerTimer) {
    _spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:.15 target:self selector:@selector(update) userInfo:nil repeats:true];
  }
}

- (void)stopGame
{
  [_spinnerTimer invalidate];
}

- (void)restartGame
{
  [_game reset];
  [self startGame];
}

#pragma mark - Private Methods

- (void)drawScene
{
  NSArray *lines = [_game getGraphicLines];
  [self beginDrawing];
  for (GraphicLine *line in lines) {
    [self drawLine:line];
  }
  [self endDrawing];
}

- (void)beginDrawing
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGContextSetLineCap(context, kCGLineCapSquare);
}

- (void)endDrawing
{
  CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void)drawLine:(GraphicLine *)line
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, line.width);
  CGContextSetStrokeColorWithColor(context, line.color.CGColor);
  CGContextMoveToPoint(context, line.start.x, line.start.y);
  CGContextAddLineToPoint(context, line.end.x, line.end.y);
  CGContextStrokePath(context);
}

- (void)update
{
  [_game update];
  [self setNeedsDisplay];
}

@end
