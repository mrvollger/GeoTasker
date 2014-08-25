//  XYZToDoItem.h
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface XYZToDoItem : NSObject <NSCoding>{
    
    
}


- (void) save:(NSString*)path toDoItem:(XYZToDoItem*) toDoItem;

- (XYZToDoItem*) load:(NSString*)path;


@property NSString *itemName;
@property NSString *itemNotes;
@property NSString *itemLocation;

// whether or not there is a search result.
@property BOOL match;

// where item is associated with location
@property BOOL hasLocation;

// map locations
@property MKMapItem *current;
@property MKMapItem *closeMatch;

// are now needed
@property (readonly) NSDate *creationDate;
@property bool completed;

@property NSMutableArray * matches;

@property NSInteger radius;


@end
