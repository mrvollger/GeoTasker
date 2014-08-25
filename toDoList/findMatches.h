//
//  findMatches.h
//  queryMaps2
//
//  Created by Shreya Nathan on 4/6/14.
//  Copyright (c) 2014 Shreya Nathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYZToDoItem.h"
#import "findMatches.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "XYZAppDelegate.h"


NSMutableArray *queries;

extern XYZToDoItem *oneAlert;

UIAlertView *alert;

@interface findMatches : NSObject

+ (int) find;
+ (int) findItem: (XYZToDoItem *) item;
+ (int) getTravelTime:(XYZToDoItem*) item
                     :(MKMapItem*) destination;
+ (void) notifyNearbyTasks;
+ (void) notifyNearbyTask:(XYZToDoItem*) item
                         :(int) travelTime;

+ (void) localDirections;


@end
