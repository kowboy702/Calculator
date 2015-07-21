//
//  ViewController.m
//  Calculator
//
//  Created by Mac on 4/28/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

#import "ViewController.h"
#import "CalcModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  Query the model for it's current answer state
- (void)showCurrentAnswer {
   [self.lblDisplayText setText:[CalcModel getDisplayValue]];
}

//  Push a one letter number to the calculator
- (IBAction)btnInsertNum:(UIButton *)sender {    
    [CalcModel appendCalcValue:[sender.titleLabel text]];
    [self showCurrentAnswer];
}

//  Perform one of the calculator operations
- (IBAction)btnPerformOperation:(UIButton *)sender {
    [CalcModel performOperation:(Operation)[sender tag]];
    [self showCurrentAnswer];
}

//  Clear the screen (occurs in two steps)
- (IBAction)btnClear:(id)sender {
    [CalcModel performClear];
    [self showCurrentAnswer];
}

//  Toggle the negate sign on the current item
- (IBAction)btnToggleSign:(id)sender {
    [CalcModel toggleSign];
    [self showCurrentAnswer];
}

//  Apply the current value as a percentage
- (IBAction)btnPercentage:(id)sender {
    [CalcModel assignPercentage];
    [self showCurrentAnswer];
}

//  Apply floating points to the calculator
- (IBAction)btnFloatPoint:(id)sender {
    [CalcModel waitForFloatInput];
    [self showCurrentAnswer];
}
@end
