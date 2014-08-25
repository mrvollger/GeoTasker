//
//  findMatches.m
//  queryMaps2
//
//  Created by Shreya Nathan on 4/6/14.
//  Copyright (c) 2014 Shreya Nathan. All rights reserved.
//

#import "findMatches.h"
#import "XYZToDoListViewController.h"
#import "XYZToDoItem.h"
#import <UIKit/UIKit.h>
#import "XYZAppDelegate.h"

XYZToDoItem *oneAlert = nil;
BOOL show;

@implementation findMatches

CLLocationManager *locationManager;

+ (int)find {
    
    [findMatches setRadius];
    
    __block dispatch_queue_t queue;
    queue = dispatch_queue_create("com.example.myQueueForMaps", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        __block int pos = 0;
        __block NSUInteger counts = [toDoItems count];
        
        for(XYZToDoItem* item in toDoItems){
            
            if (item.hasLocation==true) {
                
                
                MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
                
                if (item.itemLocation != nil){
                    request.naturalLanguageQuery = item.itemLocation;
                }
                else{
                request.naturalLanguageQuery = item.itemName;
                }
                // somehow deal with radius
                MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
                request.region = MKCoordinateRegionMake(currentLoc.coordinate, span);
                MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
                
                [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
                    
                    double minimum = INFINITY;
                    MKMapItem *closest;
                    for (MKMapItem *mapitem in response.mapItems) {
                        
                        CLLocation *loc = mapitem.placemark.location;
                        CLLocationDistance dist = [currentLoc distanceFromLocation:loc];
                        
                        if (dist < minimum) {
                            minimum = dist;
                            closest = mapitem;
                        }
                        if(dist <= item.radius){
                            [item.matches addObject:mapitem];
                        }
                    }
                    
                    if (minimum <= item.radius) {
                        item.closeMatch = closest;
                        item.match = true;
                        pos++;
                    }
                    else {
                        item.match = false;
                        NSLog(@"No item match");
                        item.closeMatch = nil;
                        pos++;
                    }
                    
                    if( counts == pos){
                        [findMatches notifyNearbyTasks];
                    }
                    
                }];
            }
            else{
                counts--;
            }
        }
    });
    
    return 1;
    
}


+ (int)findItem: (XYZToDoItem *) item {
    
    
    double speed = currentLoc.speed;
    if (speed < 1) {
        item.radius = radiusScale*500;
    }
    else {
        item.radius = radiusScale*speed*300;
    }
    
    
    __block dispatch_queue_t queue;
    queue = dispatch_queue_create("com.example.myQueueForMaps", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
                if (item.hasLocation==true) {
                MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
                
                if (item.itemLocation != nil){
                    request.naturalLanguageQuery = item.itemLocation;
                }
                else{
                    request.naturalLanguageQuery = item.itemName;
                }
                // somehow deal with radius
                MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
                request.region = MKCoordinateRegionMake(currentLoc.coordinate, span);
                
                MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
                
                [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
                    
                    double minimum = INFINITY;
                    MKMapItem *closest;
                    for (MKMapItem *mapitem in response.mapItems) {
                        
                        CLLocation *loc = mapitem.placemark.location;
                        CLLocationDistance dist = [currentLoc distanceFromLocation:loc];
                        
                        if (dist < minimum) {
                            minimum = dist;
                            closest = mapitem;
                        }
                        if(dist <= item.radius){
                            [item.matches addObject:mapitem];
                        }
                    }
                    
                    if (minimum <= item.radius) {
                        item.closeMatch = closest;
                        item.match = true;
                        [self getTravelTime:item:item.closeMatch];
                    }
                    else {
                        item.match = false;
                        NSLog(@"No item match");
                        item.closeMatch = nil;
                    }

                }];
            }
    });
    return 1;
    
}



// Gets travel time in minutes and sends notification
+ (int) getTravelTime:(XYZToDoItem*) item
                     :(MKMapItem*) destination {
    __block int time;
    
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.transportType = MKDirectionsTransportTypeWalking;
    request.source = [MKMapItem mapItemForCurrentLocation]; // start from the users current location
    request.destination = destination;
    request.departureDate = [NSDate date]; // Departing now
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        //directions.walkingTime.text = [formatter stringForTimeInterval:response.expectedTravelTime];
        time = (int) response.expectedTravelTime/60;
        NSLog(@"inside: %d", (int)time);
        [self notifyNearbyTask:item:time];
    }];
    
    //NSLog(@"getTravelTime: %d", (int)time);
    return time;
}



+ (void) notifyNearbyTasks
{
    int x = 0;
    for (XYZToDoItem *task in toDoItems) {
        if (task.match == true) {
            oneAlert = task;
            x = x+1;
        }
    }
    NSString *str = [NSString stringWithFormat: @"You have %d new tasks", x];
    NSLog(@"%@", str);
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [alert dismissWithClickedButtonIndex:0 animated:false];
    
    if(x>1){
        oneAlert = nil;
    }
    
    if (x>0) {
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && alertsOn)
        {
            if (x==1)
            {
                str = [NSString stringWithFormat: @"Do \"%@\" at %@", oneAlert.itemName, oneAlert.closeMatch.name];
            }
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localNotification.alertBody = str;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        
        UINavigationController *topController = (UINavigationController *)[XYZAppDelegate topMostController];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && alertsOn
            && ([topController.visibleViewController class] != [XYZToDoListViewController class])   )
        {
            
            if(x > 1){
                alert = [[UIAlertView alloc] initWithTitle:@"GeoTasker" message:str delegate:self
                                         cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            }
            if (x == 1){
                NSString *name = [NSString stringWithFormat: @"Do \"%@\" at %@", oneAlert.itemName, oneAlert.closeMatch.name];
                
                alert = [[UIAlertView alloc] initWithTitle:@"GeoTasker" message:name delegate:self
                                         cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                
            }
            
            [alert show];

        }
    }
}

// Single task
+ (void) notifyNearbyTask:(XYZToDoItem*) item
                         :(int) travelTime
{

    NSString *str = @"";
    NSLog(@"%@", str);
    
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [alert dismissWithClickedButtonIndex:0 animated:false];
    
    // App not open
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && alertsOn)
    {
        //str = [NSString stringWithFormat: @"Do \"%@\" at %@", item.itemName, item.closeMatch.name];
        
        str = [NSString stringWithFormat: @"\"%@\" is %d min away", item.itemName, travelTime];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = str;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
        
    //UINavigationController *topController = (UINavigationController *)[XYZAppDelegate topMostController];
    
    
    // App open
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && alertsOn)
        //&& [topController.visibleViewController class] != [XYZToDoListViewController class])
    {
        //NSString *name = [NSString stringWithFormat: @"Do \"%@\" at %@", item.itemName, item.closeMatch.name];
        NSString *name = [NSString stringWithFormat: @"\"%@\" is %d min away",
                          item.itemName, travelTime];
            
        alert = [[UIAlertView alloc] initWithTitle:@"GeoTasker" message:name delegate:self
                                 cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
            
    }
    
}

+ (void) setRadius{
    
    double speed = currentLoc.speed;
    
    for(XYZToDoItem *item in toDoItems){
        
        [item.matches removeAllObjects];
        item.closeMatch = nil;
        
        // These values are also copied in the setRadius hack for findItem
        if (speed < 1)
        {
            item.radius = radiusScale*500;
            
        }
        else
        {
            item.radius = radiusScale*speed*300;
        }
        
    }

    
}



+ (void) localDirections{
    //bring up apple maps directions
    
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking};
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    
    __block dispatch_queue_t queue;
    queue = dispatch_queue_create("com.example.localDirections", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"%@", currentLocationMapItem.description);
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, oneAlert.closeMatch] launchOptions:options];
        NSLog(@"apple maps opened");
        
    });
    
    NSLog(@"%@", currentLocationMapItem.description);
    
    
}


@end


