//
//  XYZDetailsViewController.h
//  toDoList
//
//  Created by Mitchell Vollger on 3/20/14.
//
//

#import <UIKit/UIKit.h>
#import "XYZToDoItem.h"

@interface XYZDetailsViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

{
    CGFloat animatedDistance;
    
}

@property (weak, nonatomic) IBOutlet UITextField *name1;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;

- (IBAction)switchAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *notesBox;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TextViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *closeMatchFeild;

@property (weak, nonatomic) IBOutlet UILabel *LocationField;


@property XYZToDoItem *toDoItem;





@end
