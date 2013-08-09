//
//  SnakeGame.m
//  SimpleSnake
//
//  Created by Sherlock on 8/9/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import "SnakeGame.h"

#define SNAKE_SIZE 6
#define SNAKE_SPEED 5
#define SNAKE_LENTH 100

#define fequal(a,b) (fabs((a) - (b)) < 0.001)
#define fdistant(a,b) fabs((a) - (b))

typedef NS_ENUM(NSInteger, MoveDirection) {
  UP,
  DOWN,
  LEFT,
  RIGHT,
};

@interface SnakeGame() {
  CGSize _size;
  CGPoint _head;
  CGPoint _tail;
  CGPoint _food;
  MoveDirection _currentDirection;
  MoveDirection _nextDirection;
  NSMutableArray *_turns;
}

@end

@implementation SnakeGame

#pragma mark - Public Methods

- (id)initWithSize:(CGSize)size
{
  self = [super init];
  if (self) {
    _size = size;
    _foodColor = [UIColor grayColor];
    _snakeColor = [UIColor blackColor];
    [self createSnake];
    [self createFood];
    [self createDirections];
  }
  return self;
}

- (void)needMoveTo:(CGPoint)point
{
  switch (_currentDirection) {
    case LEFT:
    case RIGHT:
    {
      if (!fequal(point.y, _head.y)) {
        _nextDirection = point.y > _head.y ? DOWN : UP;
      }
      break;
    }
    
    case UP:
    case DOWN:
    {
      if (!fequal(point.x, _head.x)) {
        _nextDirection = point.x > _head.x ? RIGHT : LEFT;
      }
      break;
    }
    
    default:
      break;
  }
}

- (void)update
{
  if (_currentDirection != _nextDirection) {
    [_turns addObject:[NSValue valueWithCGPoint:_head]];
    _currentDirection = _nextDirection;
  }
  [self move];
}

- (NSArray *)getGraphicLines
{
  NSMutableArray *lines = [[NSMutableArray alloc] initWithCapacity:_turns.count + 2];
  // add food
  [lines addObject:[self generateLineFrom:_food to:_food withColor:self.foodColor]];
  // add snake
  CGPoint start = _tail;
  for (NSValue *turn in _turns) {
    CGPoint turnPoint = [turn CGPointValue];
    if (![self isAcrossScreen:start with:turnPoint]) {
      [lines addObject:[self generateLineFrom:start to:turnPoint withColor:self.snakeColor]];
    }
    start = turnPoint;
  }
  [lines addObject:[self generateLineFrom:start to:_head withColor:self.snakeColor]];
  return lines;
}

#pragma mark - Setup Methods

- (void)createSnake
{
  _tail = CGPointMake((_size.width - SNAKE_LENTH) / 2 , _size.height * 3 / 4);
  _head = CGPointMake(_tail.x + SNAKE_LENTH, _tail.y);
}

- (void)createFood
{
  int xMax = (int)_size.width - 3 * SNAKE_SIZE;
  int yMax = (int)_size.height - 3 * SNAKE_SIZE;
  _food = CGPointMake(SNAKE_SIZE + rand() % xMax, SNAKE_SIZE + rand() % yMax);
}

- (void)createDirections
{
  _currentDirection = RIGHT;
  _nextDirection = RIGHT;
  _turns = [[NSMutableArray alloc] init];
}

#pragma mark - Move Methods

- (void)move
{
  [self moveHead];
  if ([self isEatenFood]) {
    [self createFood];
  } else {
    [self moveTail];
  }
}

- (void)moveHead
{
  switch (_currentDirection) {
    case UP: {
      (_head.y <= 0) ? [self moveAcrossScreen] : (_head.y -= SNAKE_SPEED);
      break;
    }
      
    case DOWN: {
      (_head.y >= _size.height) ? [self moveAcrossScreen] : (_head.y += SNAKE_SPEED);
      break;
    }
      
    case RIGHT: {
      (_head.x >= _size.width) ? [self moveAcrossScreen] : (_head.x += SNAKE_SPEED);
      break;
    }
      
    case LEFT: {
      (_head.x <= 0) ? [self moveAcrossScreen] : (_head.x -= SNAKE_SPEED);
      break;
    }
      
    default:
      break;
  }
}

- (void)moveTail
{
  if (0 < _turns.count) {
    CGPoint target = [[_turns objectAtIndex:0] CGPointValue];
    if ([self moveTailToPoint:target]) {
      [_turns removeObjectAtIndex:0];
    }
  } else {
    [self moveTailDirectly];
  }
  // fix across screen tail
  if (0 < _turns.count) {
    CGPoint lastTurn = [[_turns objectAtIndex:0] CGPointValue];
    if ([self isAcrossScreen:_tail with:lastTurn]) {
      _tail = lastTurn;
      [_turns removeObjectAtIndex:0];
    }
  }
}

- (BOOL)moveTailToPoint:(CGPoint)point
{
  BOOL reached = NO;
  if (fequal(point.x, _tail.x)) {
    reached = fdistant(point.y, _tail.y) <= SNAKE_SPEED;
    _tail.y = reached ? point.y : (point.y > _tail.y ? _tail.y + SNAKE_SPEED : _tail.y - SNAKE_SPEED);
  } else {
    reached = fdistant(point.x, _tail.x) <= SNAKE_SPEED;
    _tail.x = reached ? point.x : (point.x > _tail.x ? _tail.x + SNAKE_SPEED : _tail.x - SNAKE_SPEED);
  }
  return reached;
}

- (void)moveTailDirectly
{
  switch (_currentDirection) {
    case UP: {
      _tail.y -= SNAKE_SPEED;
      break;
    }
      
    case DOWN: {
      _tail.y += SNAKE_SPEED;
      break;
    }
      
    case RIGHT: {
      _tail.x += SNAKE_SPEED;
      break;
    }
      
    case LEFT: {
      _tail.x -= SNAKE_SPEED;
      break;
    }
      
    default:
      break;
  }
}

- (void)moveAcrossScreen
{
  switch (_currentDirection) {
    case UP: {
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(_head.x, 0)]];
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(_head.x, _size.height)]];
      _head.y = _size.height - SNAKE_SPEED;
      break;
    }
      
    case DOWN: {
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(_head.x, _size.height)]];
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(_head.x, 0)]];
      _head.y = SNAKE_SPEED;
      break;
    }
      
    case RIGHT: {
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(_size.width, _head.y)]];
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(0, _head.y)]];
      _head.x = SNAKE_SPEED;
      break;
    }
      
    case LEFT: {
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(0, _head.y)]];
      [_turns addObject:[NSValue valueWithCGPoint:CGPointMake(_size.width, _head.y)]];
      _head.x = _size.width - SNAKE_SPEED;
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - Status Checking Methods

- (BOOL)isEatenFood
{
  return fdistant(_food.x, _head.x) < SNAKE_SIZE && fdistant(_food.y, _head.y) < SNAKE_SIZE;
}

- (BOOL)isAcrossScreen:(CGPoint)point1 with:(CGPoint)point2
{
  return fdistant(point1.x, point2.x) >= _size.width || fdistant(point1.y, point2.y) >= _size.height;
}

#pragma mark - Generate Graphic Line Methods

- (GraphicLine *)generateLineFrom:(CGPoint)start to:(CGPoint)end withColor:(UIColor *)color
{
  GraphicLine *line = [[GraphicLine alloc] init];
  line.start = start;
  line.end = end;
  line.color = color;
  line.width = SNAKE_SIZE;
  return line;
}

@end


@implementation GraphicLine

@end
