//
//  XYZSettingsViewController.m
//  toDoList
//
//  Created by Dean Makino on 5/2/14.
//
//

#import "XYZSettingsViewController.h"
#import "XYZAppDelegate.h"
#import "findMatches.h"

@interface XYZSettingsViewController ()

@end



@implementation XYZSettingsViewController

@synthesize locationSwitch; // THIS IS REALLY THE TURN OFF ALL ALERTS SWITCH
@synthesize radiusSlider;
@synthesize website;

float initialSliderValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)sliderAction:(id)sender {
    
    radiusScale = radiusSlider.value;
}

-(IBAction)switchAction:(id)sender
{
    NSLog(@"%d", alertsOn);

    if (locationSwitch.on)
    {
        alertsOn = true;
    }
    else {
        alertsOn = false;
    }
}


-(void)toWebsite
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://sites.google.com/site/geotasker333/home"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GeoLaunch2.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    [website addTarget:self action:@selector(toWebsite) forControlEvents:UIControlEventTouchUpInside];
    
    locationSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    
    [locationSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    if(alertsOn){
        [locationSwitch setOn:YES];
    }
    else{
        [locationSwitch setOn:NO];
    }
    
    [radiusSlider setValue:radiusScale];
    initialSliderValue = radiusSlider.value;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (radiusSlider.value != initialSliderValue) {
        [findMatches find];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
