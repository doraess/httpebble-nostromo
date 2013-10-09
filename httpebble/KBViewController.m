//
//  KBViewController.m
//  httpebble
//
//  Created by Katharine Berry on 10/05/2013.
//  Copyright (c) 2013 Katharine Berry. All rights reserved.
//

#import "KBViewController.h"
#import <PebbleKit/PebbleKit.h>
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>

#define HTTP_URL_KEY @(0xFFFF)
#define HTTP_STATUS_KEY @(0xFFFE)
#define HTTP_SUCCESS_KEY_DEPRECATED @(0xFFFD)
#define HTTP_COOKIE_KEY @(0xFFFC)
#define HTTP_CONNECT_KEY @(0xFFFB)

#define HTTP_APP_ID_KEY @(0xFFF2)
#define HTTP_COOKIE_STORE_KEY @(0xFFF0)
#define HTTP_COOKIE_LOAD_KEY @(0xFFF1)
#define HTTP_COOKIE_FSYNC_KEY @(0xFFF3)
#define HTTP_COOKIE_DELETE_KEY @(0xFFF4)

#define HTTP_TIME_KEY @(0xFFF5)
#define HTTP_UTC_OFFSET_KEY @(0xFFF6)
#define HTTP_IS_DST_KEY @(0xFFF7)
#define HTTP_TZ_NAME_KEY @(0xFFF8)

#define HTTP_LOCATION_KEY @(0xFFE0)
#define HTTP_LATITUDE_KEY @(0xFFE1)
#define HTTP_LONGITUDE_KEY @(0xFFE2)
#define HTTP_ALTITUDE_KEY @(0xFFE3)

#define HTTP_LOG_KEY @(0xFFEE)
#define HTTP_BATTERY_KEY @(0xFFED)

//@interface KBViewController ()<UIViewControllerRestoration>
@interface KBViewController ()

@end

@implementation KBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.restorationIdentifier = @"httpebble";
    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToInternet:) name:kReachabilityChangedNotification object:nil];
    
    shouldBeConnected = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldBeConnected"];
    couldConnect = NO;
    [connectButton setHidden:YES];
    [connectedLabel setText:@"Pebble no está disponible"];
    
}

- (void)pebbleThing:(KBPebbleThing *)thing found:(PBWatch *)watch {
    UIImage *linkoff = [UIImage imageNamed: @"linkoff.png"];
    [bluetoothImage setImage:linkoff];
    [connectedLabel setText:[NSString stringWithFormat:@"%@ está disponible", [watch name], nil]];
    [connectButton setTitle:@"Conectar" forState:UIControlStateNormal];
    [connectButton setHidden:NO];
    couldConnect = YES;
    [self handleConnection:thing];
    [watchIDLabel setText:[watch name]];
}

- (void)pebbleThing:(KBPebbleThing *)thing connected:(PBWatch *)watch {
    UIImage *linkon = [UIImage imageNamed: @"linkon.png"];
    [bluetoothImage setImage:linkon];
    [connectedLabel setText:[NSString stringWithFormat:@"Conectado con %@", [watch name], nil]];
    [connectButton setTitle:@"Desconectar" forState:UIControlStateNormal];
    [connectButton setHidden:NO];
    isConnected = YES;
    [watchIDLabel setText:[watch name]];
}

- (void)pebbleThing:(KBPebbleThing *)thing disconnected:(PBWatch *)watch {
    UIImage *linkoff = [UIImage imageNamed: @"linkoff.png"];
    [bluetoothImage setImage:linkoff];
    [connectedLabel setText:@"Desconectado"];
    [connectButton setTitle:@"Conectar" forState:UIControlStateNormal];
    [connectButton setHidden:NO];
    isConnected = NO;
    [watchIDLabel setText:@""];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = [NSString stringWithFormat:
                                NSLocalizedString(@"%@ se ha desconectado.", nil), [watch name]];
        localNotif.alertAction = NSLocalizedString(@"OK", nil);
        localNotif.applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

- (void)pebbleThing:(KBPebbleThing *)thing lost:(PBWatch *)watch {
    UIImage *linkoff = [UIImage imageNamed: @"linkoff.png"];
    [bluetoothImage setImage:linkoff];
    [connectButton setHidden:YES];
    [connectedLabel setText:@"Pebble no está disponible"];
    [watchIDLabel setText:@""];
    [logLabel setText:@"Pebble se ha desconectado."];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = [NSString stringWithFormat:
                                NSLocalizedString(@"%@ se ha perdido.", nil), [watch name]];
        localNotif.alertAction = NSLocalizedString(@"OK", nil);
        localNotif.applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

- (void)pebbleThing:(KBPebbleThing *)thing messageReceived:(NSDictionary *)message {
    
    [messageLabel setText:nil];
    //[httpResponseLabel setText:nil];
    //[httpRequestLabel setText:nil];
    
    UIImage *location = [UIImage imageNamed: @"compass.png"];
    UIImage *clock = [UIImage imageNamed: @"clock.png"];
    
    if([message objectForKey:HTTP_URL_KEY]) {
        [messageLabel setText:[NSString stringWithFormat:@"[%@]", [message objectForKey:HTTP_URL_KEY]]];
        [messageImage setImage:location];
    }
    if([message objectForKey:HTTP_COOKIE_LOAD_KEY]) {
        [messageLabel setText:@"Mensaje recibido"];
    }
    if([message objectForKey:HTTP_COOKIE_STORE_KEY]) {
        [messageLabel setText:@"Mensaje recibido"];
    }
    if([message objectForKey:HTTP_COOKIE_FSYNC_KEY]) {
        [messageLabel setText:@"Mensaje recibido"];
    }
    if([message objectForKey:HTTP_COOKIE_DELETE_KEY]) {
        [messageLabel setText:@"Mensaje recibido"];
    }
    if([message objectForKey:HTTP_TIME_KEY]) {
        [messageImage setImage:clock];
    }
    if([message objectForKey:HTTP_LOCATION_KEY]) {
        [messageImage setImage:location];
    }
}

- (void)pebbleThing:(KBPebbleThing *)thing messageResponse:(NSDictionary *)response {
    
    
    if([response objectForKey:HTTP_LOCATION_KEY]) {
        [messageLabel setText:[NSString stringWithFormat:@"[%@]-[%@]-[%@]", [response objectForKey:HTTP_LATITUDE_KEY], [response objectForKey:HTTP_LONGITUDE_KEY], [response objectForKey:HTTP_ALTITUDE_KEY]]];
    }
    if([response objectForKey:HTTP_LOG_KEY]) {
        [logLabel setText:[response objectForKey:HTTP_LOG_KEY]];
    }
    if([response objectForKey:HTTP_BATTERY_KEY]) {
        [messageLabel setText:[response objectForKey:HTTP_BATTERY_KEY]];
    }
    if([response objectForKey:HTTP_TIME_KEY]) {
        NSTimeInterval interval =[[response objectForKey:HTTP_TIME_KEY] doubleValue];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm - dd/MMM/yyyy"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        [messageLabel setText:[NSString stringWithFormat:@"[%@]\n[%@]", [format stringFromDate:date], [response objectForKey:HTTP_TZ_NAME_KEY]]];
    }
}

- (void)pebbleThing:(KBPebbleThing *)thing httpResponse:(NSDictionary *)response {
    
    continueSpinning = false;
    NSArray *keys = [response allKeys];
    keys = [keys sortedArrayUsingSelector: @selector (compare:)];
    NSMutableString *httpResponse = [[NSMutableString alloc] init];
    for(NSString *key in keys){
        NSString *item = [NSString stringWithFormat:@"%@", [response objectForKey:key]];
        item = [item stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        item = [item stringByReplacingOccurrencesOfString:@"  " withString:@""];
        [httpResponse appendString:[NSString stringWithFormat:@"[%@] %@\n", key, item]];
    }
    
    [httpResponseLabel setText:[NSString stringWithFormat:@"%@", httpResponse]];

    degrees = 0;
}

- (void)pebbleThing:(KBPebbleThing *)thing httpResponsetoPebble:(BOOL)response {
    
    //[httpResponseLabel setText:[NSString stringWithFormat:@"Respuesta de URL:\n[%@]", [response description]]];
    
}

- (void)pebbleThing:(KBPebbleThing *)thing httpErrortoPebble:(NSError *)error {
    
    [httpResponseLabel setText:[NSString stringWithFormat:@"Error:\n[%@]", [error localizedDescription]]];
}

- (void)pebbleThing:(KBPebbleThing *)thing httpRequest:(NSDictionary *)request {
    
    continueSpinning = false;
    NSMutableString *httpRequest = [[NSMutableString alloc] init];
    for(id key in request){
        NSString *item = [NSString stringWithFormat:@"%@", [request objectForKey:key]];
        [httpRequest appendString:[NSString stringWithFormat:@"[%@] ", item]];
    }
    
    [httpRequestLabel setText:[NSString stringWithFormat:@"%@", httpRequest]];
    degrees = 0;
    continueSpinning = true;
    [self continueSpinning];
}

- (void)toggleConnected:(id)sender {
    continueSpinning = false;
    shouldBeConnected = !shouldBeConnected;
    [[NSUserDefaults standardUserDefaults] setBool:shouldBeConnected forKey:@"ShouldBeConnected"];
    [self handleConnection:_pebbleThing];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)handleConnection:(KBPebbleThing*)thing {
    if(!isConnected) {
        if(shouldBeConnected && couldConnect) {
            [connectedLabel setText:@"Connectando…"];
            [connectButton setHidden:YES];
            [thing connect];
        }
    } else {
        if(!shouldBeConnected) {
            [connectedLabel setText:@"Desconectando…"];
            [connectButton setHidden:YES];
            [thing disconnect];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    
    // Dispose of any resources that can be recreated.
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh-mm"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    [logLabel setText:[NSString stringWithFormat:@"[%@] Memory warning", resultString]];
    
    [super didReceiveMemoryWarning];
}

- (void)connectedToInternet:(NSNotification *)notification {
    UIImage *wifion = [UIImage imageNamed: @"wifi-on.png"];
    UIImage *wifioff = [UIImage imageNamed: @"wifi-off.png"];
    UIImage *mobileon = [UIImage imageNamed: @"mobile-on.png"];
    UIImage *mobileoff = [UIImage imageNamed: @"mobile-off.png"];
    [wifiImage setImage:wifioff];
    [mobileImage setImage:mobileoff];
    Reachability *reachability = (Reachability *)[notification object];
    if ([reachability isReachableViaWiFi]) {
        [wifiImage setImage:wifion];
        //[mobileImage setImage:mobileoff];
    }
    else if ([reachability isReachableViaWWAN]) {
        //[wifiImage setImage:wifioff];
        [mobileImage setImage:mobileon];
    }
    else {
        [wifiImage setImage:wifioff];
        [mobileImage setImage:mobileoff];
    }
        
}

-(void)continueSpinning {
    degrees = (degrees + 10) % 360;
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation( degrees / 180.0 * 3.14 );
    [httpResponseImage setTransform:rotate];
    
    if(!continueSpinning && degrees == 0) return;
    else [self performSelector:@selector(continueSpinning) withObject:nil afterDelay:0.01f];
}

/*-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"Codificando datos para la restaturación...");
    [coder encodeObject:watchIDLabel.text forKey:@"Pebble"];
    [super encodeRestorableStateWithCoder:coder];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"Restaurando datos...");
    watchIDLabel.text = [coder decodeObjectForKey:@"Pebble"];
    [super decodeRestorableStateWithCoder:coder];
    
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    NSLog(@"Generando vista para la restauración...");
    KBViewController *viewController = [[self alloc] init];
    return viewController;
}*/



@end
