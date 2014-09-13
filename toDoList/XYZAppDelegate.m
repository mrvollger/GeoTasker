//
//  XYZAppDelegate.m
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//

#import "XYZAppDelegate.h"
#import "XYZToDoListViewController.h"
#import "XYZToDoItem.h"
#import "findMatches.h"

@implementation XYZAppDelegate

@synthesize window = _window;
@synthesize locationManager=_locationManager;

// This is a global that can be accessed in any file that imports app delegate
CLLocation *currentLoc;
BOOL alertsOn = YES;
float radiusScale = 1;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * newLocation = [locations firstObject];
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        //Location timestamp is within the last 15.0 seconds, let's use it
        if(newLocation.horizontalAccuracy < 150.0){
            //Location is accurate enough, let's use it
            
            currentLoc = newLocation;
            [findMatches find]; 
            
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if(self.locationManager==nil){
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
        
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=100; //min dist in m before update event is generated
        self.locationManager=_locationManager;
    }
    
    if([CLLocationManager locationServicesEnabled]){
        [self.locationManager startUpdatingLocation];
    }
    
    CLLocation *location = [_locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];

    currentLoc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    // local notifications permissions
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];

    
    return YES;
}


+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(NSDictionary *)userInfo {
    
    if (oneAlert != nil){
        UINavigationController *topController = (UINavigationController  *)[XYZAppDelegate topMostController];
        [topController popToRootViewControllerAnimated:NO];
        
        if([topController.visibleViewController class] == [XYZToDoListViewController class]){
            NSLog(@"%@", topController.visibleViewController.class);
            [topController.visibleViewController performSegueWithIdentifier:@"oneAlertShow" sender:topController.visibleViewController ];
        }
    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    int i = 0;
    for(XYZToDoItem * item in toDoItems){
    
        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *strFromInt = [NSString stringWithFormat:@"%d",i];
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,strFromInt,@".toDoItem"];
    
        NSLog(@"%@", filePath);
        [item save:filePath toDoItem:item];
        
        i++;
    }

}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


@end
