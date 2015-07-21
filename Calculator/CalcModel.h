//
//  CalcModel.h
//  Calculator
//
//  Created by Mac on 4/28/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

//  Types of operation that can be performed on the calculator
typedef enum {
    NONE = 0,
    ADD = 1,
    SUB = 2,
    MUL = 3,
    DIV = 4,
    FINAL = 5,
    PERC = 6
} Operation;

//  The states that the calculator can be
typedef enum {
    START = 1,
    INPUT_NUM = 2,
    DISPLAY_OPERATION = 3,
    DISPLAY_FINAL = 4
} CalcState;

@interface CalcModel : NSObject

+ (NSString*)getDisplayValue;
+ (void)appendCalcValue: (NSString*)value;
+ (void)performOperation:(Operation)operation;
+ (void)performClear;
+ (void)toggleSign;
+ (void)assignPercentage;
+ (void)waitForFloatInput;

@end
