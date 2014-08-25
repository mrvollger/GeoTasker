//
//  XYZMapViewController.h
//  toDoList
//
//  Created by Mitchell Vollger on 4/11/14.
//
//

#import <UIKit/UIKit.h>
#import "XYZToDoItem.h"

@interface XYZMapViewController : UIViewController <MKMapViewDelegate> {
    
    IBOutlet MKMapView *mapView;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *getDirections;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property XYZToDoItem *toDoItem;

@end
