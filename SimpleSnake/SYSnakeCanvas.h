//
//  SnakeCanvas.h
//  SimpleSnake
//
//  Created by Sherlock on 8/8/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYSnakeGame.h"

@interface SYSnakeCanvas : UIView

- (void)setGame:(SYSnakeGame *)game;
- (void)startGame;
- (void)stopGame;
- (void)restartGame;

@end
