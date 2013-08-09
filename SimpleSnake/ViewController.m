//
//  ViewController.m
//  SimpleSnake
//
//  Created by Sherlock on 8/8/13.
//  Copyright (c) 2013 Originate. All rights reserved.
//

#import "ViewController.h"
#import "SnakeCanvas.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet  SnakeCanvas *canvas;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  SnakeGame *game = [[SnakeGame alloc] initWithSize:self.canvas.frame.size];
  [self.canvas setGame:game];
  [self.canvas startGame];
}

@end
