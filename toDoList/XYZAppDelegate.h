//
//  XYZAppDelegate.h
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define UIAppDelegate ((MyAppDelegate *)[UIApplication sharedApplication].delegate)

extern CLLocation *currentLoc;
extern BOOL alertsOn;
extern float radiusScale;


@interface XYZAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

+ (UIViewController*) topMostController;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property(nonatomic, retain) UIViewController *rootView;

@end