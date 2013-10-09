//
//  KBViewController.h
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBPebbleThing.h"

@interface KBViewController: UIViewController<KBPebbleThingDelegate>  {
    IBOutlet UILabel* connectedLabel;
    IBOutlet UILabel* messageLabel;
    IBOutlet UILabel* httpRequestLabel;
    IBOutlet UILabel* httpResponseLabel;
    IBOutlet UIButton* connectButton;
    IBOutlet UILabel* watchIDLabel;
    IBOutlet UILabel* logLabel;
    IBOutlet UIImageView* wifiImage;
    IBOutlet UIImageView* mobileImage;
    IBOutlet UIImageView* bluetoothImage;
    IBOutlet UIImageView* messageImage;
    IBOutlet UIImageView* httpResponseImage;
    BOOL shouldBeConnected;
    BOOL couldConnect;
    BOOL isConnected;
    BOOL continueSpinning;
    int degrees;
}

- (void)pebbleThing:(KBPebbleThing*)thing connected:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing disconnected:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing found:(PBWatch*)watch;
- (void)pebbleThing:(KBPebbleThing*)thing lost:(PBWatch *)watch;
- (void)pebbleThing:(KBPebbleThing*)thing messageReceived:(NSDictionary *)message;
- (void)pebbleThing:(KBPebbleThing*)thing messageResponse:(NSDictionary *)response;
- (void)pebbleThing:(KBPebbleThing*)thing httpRequest:(NSDictionary *)request;
- (void)pebbleThing:(KBPebbleThing*)thing httpResponse:(NSDictionary *)response;
- (void)pebbleThing:(KBPebbleThing*)thing httpResponsetoPebble:(BOOL)response;
- (void)pebbleThing:(KBPebbleThing*)thing httpErrortoPebble:(NSError *)error;
- (void)continueSpinning;

- (IBAction)toggleConnected:(id)sender;

@property (nonatomic, retain) KBPebbleThing *pebbleThing;

@end
