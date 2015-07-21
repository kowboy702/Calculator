//
//  CalcModel.m
//  Calculator
//
//  Created by Mac on 4/28/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

#import "CalcModel.h"

@interface CalcModel ()

@end

@implementation CalcModel

static NSString *lastDisplay = @"";         //  Keeps track of the last number shown
static NSNumber *calcValue = 0;             //  Keeps track of the current calculateable value
static NSNumber *operationBuffer = 0;       //  Keeps track of the current answer
static CalcState CurrentState = START;      //  Keeps track of the calculators state
static Operation lastOperation = NONE;      //  Keeps track of the last operation the user requested
static bool usePercentage = false;          //  Flags if percentage is performed on the next operation
static bool floatWait = false;              //  Flags the state where the floating point is pressed and we are waiting on the next digits after it
static int trailingZeros = 0;               //  Keeps track of zeros following a floating point so that they can be applied and not ignored by conversion

//  Gets the calculateable number (the preview number which the user is entering with
//  floating points and trailing zeros applied to it.

+(NSString*)getCalcValue {
    NSString *currentString = @"";
    if (calcValue == nil || [calcValue floatValue] == 0)
        currentString = @"0";
    else
        currentString = [calcValue stringValue];
    
    if (floatWait || (trailingZeros && [currentString rangeOfString:@"."].location == NSNotFound))
        currentString = [NSString stringWithFormat:@"%@.", currentString];

    if (trailingZeros){
        for (int i = 0; i < trailingZeros; i++){
            currentString = [NSString stringWithFormat: @"%@0", currentString];
        }
    }
    
    return currentString;
}

//  Appends a new digit to the current calculateable value, keeping an eye on floating points and the trailing zeros

+(void)appendCalcValue:(NSString*)value{
    NSString *newCalcValue;
    
    if (CurrentState != INPUT_NUM)
        newCalcValue = @"";
    else
        newCalcValue = [calcValue stringValue];
    
    if (floatWait){
        if ([newCalcValue isEqualToString:@""])
             newCalcValue = @"0";
        
        newCalcValue = [NSString stringWithFormat:@"%@.",newCalcValue];
    }
    
    if ([value isEqualToString:@"0"] && (trailingZeros || [newCalcValue rangeOfString:@"."].location != NSNotFound))
        trailingZeros++;
    else {
        if (trailingZeros){
            if ( [newCalcValue rangeOfString:@"."].location == NSNotFound )
                newCalcValue = [NSString stringWithFormat:@"%@.",newCalcValue];

            for (int i = 0; i < trailingZeros; i++){
                newCalcValue = [NSString stringWithFormat: @"%@0", newCalcValue];
            }
        }
        
        newCalcValue = [NSString stringWithFormat:@"%@%@",newCalcValue, value];
        
        trailingZeros = 0;
    }
    
    calcValue = [NSNumber numberWithFloat: [newCalcValue floatValue]];
    
    floatWait = false;
    CurrentState = INPUT_NUM;
}

//  Returns a display value for the calculator that is highly dependent on the state of the calculator

+(NSString*)getDisplayValue {
    switch ((int)CurrentState){
        case START:
        case INPUT_NUM: lastDisplay = [self getCalcValue]; break;
        case DISPLAY_OPERATION:
        case DISPLAY_FINAL: lastDisplay = [operationBuffer stringValue];
    }
    return lastDisplay;
}

//  Perform an operation which was buffered for calculation, and prepare for the next operation

+(void)performBufferedOperation:(NSNumber*) operand{
    
    if (CurrentState != DISPLAY_FINAL && CurrentState != START){
        switch ((int)lastOperation){
            case NONE:{
                operationBuffer = calcValue;
            } break;
            case ADD: {
                operationBuffer = [NSNumber numberWithFloat:[operationBuffer floatValue] +[operand floatValue]];
            } break;
            case SUB: {
                operationBuffer = [NSNumber numberWithFloat:[operationBuffer floatValue] - [operand floatValue]];
            } break;
            case MUL:{
                operationBuffer = [NSNumber numberWithFloat:[operationBuffer floatValue] * [operand floatValue]];
            } break;
            case DIV: {
                if ([operand floatValue] != 0){ // avoid division by zero
                    operationBuffer = [NSNumber numberWithFloat:[operationBuffer floatValue] /[operand floatValue]];
                }
            } break;
        }
    }
}

//  Change the state of the calculator and prepare for next input

+(void)pushOperation:(Operation)operation{
    if (operation != FINAL && operation != PERC){
        calcValue = @0;
        lastOperation = operation;
        CurrentState = DISPLAY_OPERATION;
    }
    else {
        calcValue = @0.0;
        CurrentState = DISPLAY_FINAL;
        lastOperation = NONE;
    }
}

//  exposed function for automatically perform the calculate operation

+(void)performOperation:(Operation)operation {
    if (usePercentage) {
        switch((int)lastOperation){
            case ADD:
            case SUB:
                calcValue = @([operationBuffer floatValue] * ([calcValue floatValue] / 100));
                break;
            case MUL:
            case DIV:
                calcValue = @([calcValue floatValue] / 100);
                break;
        }
        [self performBufferedOperation:calcValue];
        [self pushOperation:operation];
        
        lastOperation = NONE;
        usePercentage = false;
    }
    else {
        [self performBufferedOperation:calcValue];
        [self pushOperation:operation];
    }
}

//  A two stage clearing function that will first clear the input value, then if required reset the calculator

+(void)performClear{
    if (CurrentState == INPUT_NUM && calcValue != 0){
        calcValue = @0;
    }
    else if (CurrentState != START){
        calcValue = @0;
        operationBuffer = @0;
        CurrentState = START;
        lastOperation = NONE;
    }
    floatWait = false;
    usePercentage = false;
    trailingZeros = 0;
}

//  Flag the sign, only after use input is entered (no -0 values)

+(void)toggleSign{
    if (CurrentState == INPUT_NUM){
        calcValue = @([calcValue floatValue] * -1);
    }
}

//  Applies or flags for use of percentages

+(void)assignPercentage{
    if (lastOperation == NONE){
        if ([operationBuffer floatValue] == 0.0)
            operationBuffer = @([calcValue floatValue] / 100.0);
        else
            operationBuffer = @([operationBuffer floatValue] / 100.0);
        usePercentage = false;
        calcValue = operationBuffer;
        CurrentState = DISPLAY_OPERATION;
    }
    else {
        usePercentage = true;
        [self performOperation:PERC];
    }
}

//  Applies and waits for floating point input
             
+(void) waitForFloatInput{
    if (CurrentState != INPUT_NUM || [lastDisplay rangeOfString:@"."].location == NSNotFound){
        CurrentState = INPUT_NUM;
        floatWait = true;
    }
}
@end
