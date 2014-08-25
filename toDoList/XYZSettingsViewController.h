//
//  XYZSettingsViewController.h
//  toDoList
//
//  Created by Dean Makino on 5/2/14.
//
//

#import <UIKit/UIKit.h>

@interface XYZSettingsViewController : UIViewController{
    
}

@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;

- (IBAction)switchAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *website;

@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;

- (IBAction)sliderAction:(id)sender;

@end
