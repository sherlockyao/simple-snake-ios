//
//  SnakeCanvas.h
//  SimpleSnake
//
//  Created by Sherlock on 8/8/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakeGame.h"

@interface SnakeCanvas : UIView

- (void)setGame:(SnakeGame *)game;
- (void)startGame;

@end
