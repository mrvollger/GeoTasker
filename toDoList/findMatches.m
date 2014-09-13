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
            // set new location to false because we don't know if the locations are new yet
            item.newLocation = false;
            
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
                        // if it is a new location, not the one laready saved, set it as a new location
                        int distanceThreshold = 25.0;
                        if( item.closeMatch == nil || [item.closeMatch.placemark.location  distanceFromLocation:closest.placemark.location] > distanceThreshold){
                            item.newLocation = true;
                            NSLog(@"The item is new, %f", [item.closeMatch.placemark.location  distanceFromLocation:closest.placemark.location]);
                        }
                        else{
                            item.newLocation = false;
                        }
                        
                        item.closeMatch = closest;
                        item.match = true;
                        pos++;
                    }
                    else {
                        item.match = false;
                        item.closeMatch = nil;
                        [item.matches removeAllObjects];
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


+ (void) notifyNearbyTasks
{
    // notify the table it should reload
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationChanged" object:self];

    
    int x = 0;
    NSString *str = [NSString stringWithFormat: @"You have new locations where you can complete these GeoTasks: "];
    
    for (XYZToDoItem *task in toDoItems) {
        if (task.match == true && task.newLocation == true) {
            oneAlert = task;
            // change the alert message to include the item name that is newly active
            str = [str stringByAppendingString:@"\'"];
            str = [str stringByAppendingString:task.itemName];
            str = [str stringByAppendingString:@"\' "];
            
            x = x+1;
        }
    }
    NSLog(@"%@", str);
    

    
    if(x>1){
        oneAlert = nil;
    }
    
    if (x>0) {
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [alert dismissWithClickedButtonIndex:0 animated:false];
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && alertsOn)
        {
            if (x==1)
            {
                str = [NSString stringWithFormat: @"You could do your GeoTask \"%@\" at %@", oneAlert.itemName, oneAlert.closeMatch.name];
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
            // disabling alerts for now 
            //[alert show];

        }
    }
}


+ (void) setRadius{
    
    double speed = currentLoc.speed;
    
    for(XYZToDoItem *item in toDoItems){
        
        [item.matches removeAllObjects];
        //item.closeMatch = nil;
        
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


