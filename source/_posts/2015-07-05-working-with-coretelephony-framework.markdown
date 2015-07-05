---
layout: post
title: "Working with Core Telephony framework"
date: 2015-07-05 15:52:09 +0200
comments: false
author: marcin
categories: 
---
Have you ever encountered a situation where you want to build some record or music app ? But you need to somehow react on a phone call which in many cases break recording or playing in more advanced app (mostly when it comes to `CoreAudio`) or switch UI in case of call? `CoreTelephony` is a great library which will help in most of the situations.  

To detect phone call on your iPhone or iPad app (this may be the case now when we use continuity) simply use this piece of code:  

```objc
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface MMCallNotificationManager()
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic) BOOL callWasStarted;
@end

@implementation MMCallNotificationManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        self.callCenter = [[CTCallCenter alloc] init];
        self.callWasStarted = NO;
        
        __weak __typeof__(self) weakSelf = self;
        
        [self.callCenter setCallEventHandler:^(CTCall *call) {
            
            if ([[call callState] isEqual:CTCallStateIncoming] ||
                [[call callState] isEqual:CTCallStateDialing]) {
                
                if (weakSelf.callWasStarted == NO) {
                    
                    weakSelf.callWasStarted = YES;
                    
                    NSLog(@"Call was started.");
                }
                
            } else if ([[call callState] isEqual:CTCallStateDisconnected]) {
                
                if (weakSelf.callWasStarted == YES)
                {
                    weakSelf.callWasStarted = NO;
                    
                    NSLog(@"Call was ended.");
                }
            }
        }];
    }
    
    return self;
}

@end

```

Another example of usage may be detecting if we have simcard installed on our device. For example our application allows user to call someone within the app, but we want to inform if the card is removed. Of course we can use some iOS urls for that, such as: `telprompt:` but they likely breaks UI e.g: in iOS8 it blinks twice which is not a nice effect...

So to detect if simcard is in place, use this code:

```objc
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

- (IBAction)handleCallButtonPress:(id)sender
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    
    NSString *code = [networkInfo.subscriberCellularProvider mobileCountryCode];

    //this is nil if you take out sim card.
    if (code == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"aler.error",nil)
                                                            message:NSLocalizedString(@"alert.message.no_sim_card",nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"alert.button_dimiss", nil)
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    //make regular phone prompt (with call confirmation)
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt://%@",phoneNumberString]];

    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

```

I hope this will help you reduce potential edge cases in your future apps.