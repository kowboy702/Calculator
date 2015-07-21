//
//  ViewController.h
//  Calculator
//
//  Created by Mac on 4/28/15.
//  Copyright (c) 2015 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblDisplayText;
- (IBAction)btnInsertNum:(id)sender;
- (IBAction)btnPerformOperation:(UIButton *)sender;

@end

