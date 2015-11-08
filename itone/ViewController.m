//
//  ViewController.m
//  itone
//
//  Created by Jonathan S Baker on 04/11/2015.
//  Copyright © 2015 Jonathan S Baker. All rights reserved.
//

#import "ViewController.h"
#import "AudioController.h"

@interface ViewController ()

@property AudioController* audioController;

@end

@implementation ViewController
@synthesize audioController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createTonePad];
    
    audioController = [[AudioController alloc] init];
}

- (void) createTonePad
{
    int gridSize = 16;
    int buttonSize = 18;
    int x = 20;
    for (int i = 0; i < gridSize; i++)
    {
        int y = 10 + gridSize*buttonSize;
        for (int j = 0; j < gridSize; j++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(toneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(x, y, buttonSize, buttonSize);
            button.layer.borderColor = [UIColor colorWithRed:0.00 green:0.34 blue:1.00 alpha:1.0].CGColor;
            button.layer.borderWidth = 1.0f;
            button.backgroundColor = [UIColor whiteColor];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont systemFontOfSize:4.0f];
            button.adjustsImageWhenHighlighted = NO;
            button.tag = i * gridSize + j;
            [self.view addSubview:button];
            y -= (buttonSize-1);
        };
        x += (buttonSize-1);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) toneButtonClicked:(UIButton*)sender
{
    if([sender isSelected])
    {
        [sender setSelected:NO];
        sender.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        [sender setSelected:YES];
        sender.backgroundColor = [UIColor colorWithRed:0.00 green:0.34 blue:1.00 alpha:1.0];
    }
    [self.audioController toggleTone:sender.tag];
}

@end
