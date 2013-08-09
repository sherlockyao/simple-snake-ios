//
//  SnakeCanvas.m
//  SimpleSnake
//
//  Created by Sherlock on 8/8/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import "SnakeCanvas.h"

#define SNAKE_SIZE 6
#define SNAKE_SPEED 5
#define fequal(a,b) (fabs((a) - (b)) < 0.001)
#define fdistant(a,b) fabs((a) - (b))

typedef NS_ENUM(NSInteger, Direction) {
  UP,
  DOWN,
  LEFT,
  RIGHT,
};

@interface SnakeCanvas() {
  CGPoint _head;
  CGPoint _tail;
  CGPoint _food;
  Direction _direction;
  Direction _turnDirection;
  NSMutableArray *_turns;
  NSTimer *_spinnerTimer;
}

@end

@implementation SnakeCanvas

#pragma mark - UIView Lifecycle

- (void)awakeFromNib
{
  [super awakeFromNib];
  _head = CGPointMake(120, 200);
  _tail = CGPointMake(20, 200);
  [self createFood];
  _direction = RIGHT;
  _turnDirection = RIGHT;
  _turns = [[NSMutableArray alloc] init];
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  [self drawScene];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint location = [touch locationInView:self];
  if (RIGHT == _direction || LEFT == _direction) {
    if (!fequal(location.y, _head.y)) {
      _turnDirection = location.y > _head.y ? DOWN : UP;
    }
  } else {
    if (!fequal(location.x, _head.x)) {
      _turnDirection = location.x > _head.x ? RIGHT : LEFT;
    }
  }
}

- (void)start
{
  if (nil == _spinnerTimer) {
    _spinnerTimer = [NSTimer scheduledTimerWithTimeInterval:.15 target:self selector:@selector(update) userInfo:nil repeats:true];
  }
}


#pragma mark - Private Methods

- (void)createFood
{
  CGSize size = self.frame.size;
  int xMax = (int)size.width - 3 * SNAKE_SIZE;
  int yMax = (int)size.height - 3 * SNAKE_SIZE;
  _food = CGPointMake(SNAKE_SIZE + rand() % xMax, SNAKE_SIZE + rand() % yMax);
}

- (void)drawScene
{
  [self beginDrawing];
  [self drawFood];
  [self drawSnake];
  [self endDrawing];
}


- (void)drawFood
{
  [self useColor:[UIColor grayColor]];
  [self drawLineFrom:_food to:_food];
}

- (void)drawSnake
{
  [self useColor:[UIColor blackColor]];
  CGPoint start = _tail;
  for (NSValue *turn in _turns) {
    CGPoint turnPoint = [turn CGPointValue];
    [self drawLineFrom:start to:turnPoint];
    start = turnPoint;
  }
  [self drawLineFrom:start to:_head];
}

- (void)beginDrawing
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGContextSetLineCap(context, kCGLineCapSquare);
  CGFloat lineWidth = SNAKE_SIZE;
  CGContextSetLineWidth(context, lineWidth);
}

- (void)endDrawing
{
  CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

- (void)useColor:(UIColor *)color
{
  CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
}

- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end
{
  if (![self isCrossScreen:start with:end]) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    CGContextStrokePath(context);
  }
}

- (void)update
{
  if (_turnDirection != _direction) {
    [_turns addObject:[NSValue valueWithCGPoint:_head]];
    _direction = _turnDirection;
  }
  [self move];
  [self setNeedsDisplay];
}

- (void)move
{
  CGPoint preHead = _head;
  [self moveHead];
  if ([self isEatenFood]) {
    [self createFood];
  } else {
    [self moveTail:preHead];
  }
  [self fixTail];
}

- (void)moveHead
{
  switch (_direction) {
    case UP: {
      if (_head.y <= 0) {
        [self crossScreen:CGPointMake(_head.x, 0) to:CGPointMake(_head.x, self.frame.size.height)];
        _head.y = self.frame.size.height - SNAKE_SPEED;
      } else {
        _head.y -= SNAKE_SPEED;
      }
      break;
    }
      
    case DOWN: {
      if (_head.y >= self.frame.size.height) {
        [self crossScreen:CGPointMake(_head.x, self.frame.size.height) to:CGPointMake(_head.x, 0)];
        _head.y = SNAKE_SPEED;
      } else {
        _head.y += SNAKE_SPEED;
      }
      break;
    }
      
    case RIGHT: {
      if (_head.x >= self.frame.size.width) {
        [self crossScreen:CGPointMake(self.frame.size.width, _head.y) to:CGPointMake(0, _head.y)];
        _head.x =SNAKE_SPEED;
      } else {
        _head.x += SNAKE_SPEED;
      }
      break;
    }
      
    case LEFT: {
      if (_head.x <= 0) {
        [self crossScreen:CGPointMake(0, _head.y) to:CGPointMake(self.frame.size.width, _head.y)];
        _head.x = self.frame.size.width - SNAKE_SPEED;
      } else {
        _head.x -= SNAKE_SPEED;
      }
      
      break;
    }
      
    default:
      break;
  }
}

- (void)moveTail:(CGPoint)head
{
  CGPoint target = 0 < _turns.count ? [[_turns objectAtIndex:0] CGPointValue] : head;
  if (fequal(target.x, _tail.x)) {
    if (fabs(target.y - _tail.y) <= SNAKE_SPEED) {
      [_turns removeObjectAtIndex:0];
      _tail.y = target.y;
    } else {
      _tail.y += target.y > _tail.y ? SNAKE_SPEED : -SNAKE_SPEED;
    }
  } else {
    if (fabs(target.x - _tail.x) <= SNAKE_SPEED) {
      [_turns removeObjectAtIndex:0];
      _tail.x = target.x;
    } else {
      _tail.x += target.x > _tail.x ? SNAKE_SPEED : -SNAKE_SPEED;
    }
  }
}

- (void)fixTail
{
  if (0 < _turns.count) {
    CGPoint lastTurn = [[_turns objectAtIndex:0] CGPointValue];
    if ([self isCrossScreen:_tail with:lastTurn]) {
      _tail = lastTurn;
      [_turns removeObjectAtIndex:0];
    }
  }  
}

- (void)crossScreen:(CGPoint)start to:(CGPoint)end
{
  [_turns addObject:[NSValue valueWithCGPoint:start]];
  [_turns addObject:[NSValue valueWithCGPoint:end]];
}

- (BOOL)isCrossScreen:(CGPoint)point1 with:(CGPoint)point2
{
  return (fabs(point1.x - point2.x) >= self.frame.size.width || fabs(point1.y - point2.y) >= self.frame.size.height);
}

- (BOOL)isEatenFood
{
  return (fabs(_food.x - _head.x) < SNAKE_SIZE && fabs(_food.y - _head.y) < SNAKE_SIZE);
}

@end
