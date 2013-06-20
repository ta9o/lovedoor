//
//  ViewController.m
//  LoveDoor
//
//  Created by Takuo IMBE on 6/21/13.
//  Copyright (c) 2013 Takuo IMBE. All rights reserved.
//

#import "ViewController.h"

// Import the konashi library
#import "Konashi.h"


//  --------------------------------------------------------------
//  ueno start

#define _GAMAN_TIME_SEC_    2.0

//  ueno end
//  --------------------------------------------------------------

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [Konashi initialize];
    [Konashi addObserver:self selector:@selector(setup) name:KONASHI_EVENT_READY];
    [Konashi find];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)digitalOutputControlChanged:(id)sender {
    if (self.digitalOutputControl.selectedSegmentIndex == 1) {
        [Konashi digitalWrite:LED2 value:HIGH];
    } else {
        [Konashi digitalWrite:LED2 value:LOW];
    }
}

- (void)setup
{
    // Set mode for each pin
    [Konashi pinMode:S1 mode:INPUT];
    [Konashi pinMode:LED2 mode:OUTPUT];

    // Add an observer to observe changes on PIO input pins
    [Konashi addObserver:self
                selector:@selector(pioInputUpdated)
                    name:KONASHI_EVENT_UPDATE_PIO_INPUT];
    
    
    //  --------------------------------------------------------------
    //  ueno start
    
        //  YES ｜「コンコン」の最初の「コン」が打たれた
        //  NO  ｜一旦YESになったが２秒間の間に、もう一回の「コン」入力がなかったらNOにリセット
    
    _isKnockStart = 0;
    
    //  ueno end
    //  --------------------------------------------------------------
}


#pragma mark -
#pragma mark Boy
//  --------------------------------------------------------------
//  ueno start

    //  ２秒以内に彼氏がノックを行わなかったら、このチェック関数を無効
    //  _isKnockStart = NO にリセット

//  ueno end
//  --------------------------------------------------------------
- (void)checkSecoundKnock:(NSTimer*)timer
{
    double second = [[NSDate date] timeIntervalSinceDate:_startDate];

    NSLog(@"secound = %f", second);
    if (second > _GAMAN_TIME_SEC_) {
        
        NSLog(@"timer invalidate\n");
        _isKnockStart = 0;
        [timer invalidate];
        
        if ([timer isValid]) {
            NSLog(@"timer 有効\n");
        } else {
            NSLog(@"timer 無効\n");
        }
    }
}

//  --------------------------------------------------------------
//  ueno start

    //  彼氏が２回目のノックを２秒以内に行うかを確認

//  ueno end
//  --------------------------------------------------------------
- (void)startCheckSecoundKnock
{
    NSLog(@"[startCheckSecoundKnock]\n");
    
    _startDate = [NSDate date];
    
    _sendKnockStartTimer = [NSTimer
                scheduledTimerWithTimeInterval:0.1f
                target:self
                selector:@selector(checkSecoundKnock:)
                userInfo:nil
                repeats:YES
                ];

    [_sendKnockStartTimer fire];
}


//  --------------------------------------------------------------
//  ueno start

    //  彼氏がノックした

//  ueno end
//  --------------------------------------------------------------
- (void)pioInputUpdated
{
    NSLog(@"[pioInputUpdated]\n");
    
    if (_isKnockStart < 4) {
        _isKnockStart ++;
        NSLog(@"_isKnockStart = %d", _isKnockStart);
    }
    
    //  最初のノック時
    if (_isKnockStart == 2) {

        [self startCheckSecoundKnock];
        
    } else if (_isKnockStart == 4) {
        
        [_sendKnockStartTimer invalidate];
        
        
        [self sendKnockToGirlfriend];
    }
    
}


#pragma mark -
#pragma mark GirlFriend
//  --------------------------------------------------------------
//  ueno start

    //  ソレノイドで叩くドアを表現｜代わりにLEDを2回光らせる

//  ueno end
//  --------------------------------------------------------------
- (void)fireKnock:(NSTimer*)timer
{
    
    static int count_knock = 0;
    
    NSLog(@"fireKnock, count = %d\n", count_knock);
    
    if (count_knock > 4) {
        
        NSLog(@"fireKnock invalidate\n");
        
        count_knock = 0;
        [timer invalidate];
        _isKnockStart = 0;
    }
    
    if (count_knock % 2 == 0) {
        [Konashi digitalWrite:LED2 value:LOW];
    } else {
        [Konashi digitalWrite:LED2 value:HIGH];
    }
    
    count_knock ++;
}


//  --------------------------------------------------------------
//  ueno start

    //  LEDを光らせる

//  ueno end
//  --------------------------------------------------------------
- (void)sendKnockToGirlfriend
{
    NSLog(@"[sendKnockToGirlfriend]\n");
    if ([_receiveKnockStartTimer isValid]) {
        return;
    }
    _receiveKnockStartTimer = [NSTimer
                         scheduledTimerWithTimeInterval:0.5f
                         target:self
                         selector:@selector(fireKnock:)
                         userInfo:nil
                         repeats:YES
                         ];
    
    [_receiveKnockStartTimer fire];

}

@end
