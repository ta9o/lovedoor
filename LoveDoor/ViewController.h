//
//  ViewController.h
//  LoveDoor
//
//  Created by Takuo IMBE on 6/21/13.
//  Copyright (c) 2013 Takuo IMBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *digitalInputControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *digitalOutputControl;

@property (nonatomic, retain) NSTimer *sendKnockStartTimer;
@property (nonatomic, retain) NSTimer *receiveKnockStartTimer;

@property (nonatomic, assign) int isKnockStart;
@property (nonatomic, retain) NSDate *startDate;

- (IBAction)digitalOutputControlChanged:(id)sender;

@end
