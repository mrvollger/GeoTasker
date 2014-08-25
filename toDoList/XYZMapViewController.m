//
//  XYZMapViewController.m
//  toDoList
//
//  Created by Mitchell Vollger on 4/11/14.
//
//

#import "XYZMapViewController.h"
#import "XYZToDoItem.h"
#import "XYZDetailsViewController.h"
#import "XYZAppDelegate.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"

@interface XYZMapViewController ()

@end

@implementation XYZMapViewController

@synthesize mapView;
@synthesize toDoItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)getDirections:(id)sender
{
    
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking};
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    
            NSLog(@"%@", currentLocationMapItem.description);
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, toDoItem.closeMatch] launchOptions:options];
        NSLog(@"apple maps opened");
    
    NSLog(@"%@", currentLocationMapItem.description);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(toDoItem.closeMatch == nil){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];

    // note make the view size dynamic
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
    CLLocationCoordinate2DMake(currentLoc.coordinate.latitude, currentLoc.coordinate.longitude), 3100, 3100);
    
    [mapView setRegion:region animated:YES];
    
    
    for(MKMapItem* mapitem in toDoItem.matches){
        CLLocationCoordinate2D close = CLLocationCoordinate2DMake(mapitem.placemark.coordinate.latitude, mapitem.placemark.coordinate.longitude);
        
        Annotation *pin = [[Annotation alloc] init];
        pin.title = mapitem.name;
        pin.subtitle = @"Press here to get directions";
        pin.coordinate = close;
        
        [mapView addAnnotation:pin];
    
    }
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView1 viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //NSLog(@"Annotation: ");
    //NSLog(@"%d", annotation.coordinate.latitude);
    //NSLog(@"%d", annotation.coordinate.longitude);
    //NSLog(@"UserLocation: ");
    //NSLog(@"%d", mapView.userLocation.coordinate.latitude);
    //NSLog(@"%d", mapView.userLocation.coordinate.longitude);
    
    //need to check how to compare these two and good to go
    if (annotation == mapView1.userLocation)
    {
        return nil;
    }
    
    else{
        
        MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
        MyPin.pinColor = MKPinAnnotationColorRed;
        
        UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        //[advertButton addTarget:self action:@selector(directionsButton:) forControlEvents:UIControlEventTouchUpInside];
        
        MyPin.rightCalloutAccessoryView = advertButton;
        MyPin.draggable = NO;
        MyPin.highlighted = YES;
        MyPin.animatesDrop=TRUE;
        MyPin.canShowCallout = YES;
        
        return MyPin;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[Annotation class]])
    {
        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        Annotation *ann = (Annotation *)view.annotation;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:ann.coordinate addressDictionary:nil];
        MKMapItem *destLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, destLocation] launchOptions:options];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
