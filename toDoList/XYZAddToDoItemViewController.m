//
//  XYZAddToDoItemViewController.m
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.


#import "XYZAddToDoItemViewController.h"
#import "findMatches.h"
@interface XYZAddToDoItemViewController ()


@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UITextView *notesField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UISwitch *locationOn;
@property (weak, nonatomic) IBOutlet UITextField *locationField;

@property (weak, nonatomic) IBOutlet UITextView *notesBox;

@end


@implementation XYZAddToDoItemViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.doneButton) return;
    
    if (![@"" isEqualToString:[self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ]) {
        
        self.toDoItem = [[XYZToDoItem alloc] init];
        self.toDoItem.itemName = self.textField.text;
        self.toDoItem.completed = NO;
        self.toDoItem.hasLocation = self.locationOn.isOn;

        self.toDoItem.matches = [[NSMutableArray alloc] init];

        if (self.notesBox.text.length > 0) {
            self.toDoItem.itemNotes = self.notesBox.text;
        }
        else {
            self.toDoItem.itemNotes = @"";
        }
        if (self.locationField.text.length > 0){
            self.toDoItem.itemLocation = self.locationField.text;
        }
        else {
            (self.toDoItem.itemLocation = nil);
        }
        
    }
}


// the following methods are for the scroll wheel
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 6;
}

- (void)textViewDidChange:(UITextView *) textView {
    
    NSLog(@"viewDidChange");
    
    CGRect line = [self.notesBox caretRectForPosition:
                   self.notesBox.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( self.notesBox.contentOffset.y + self.notesBox.bounds.size.height
       - self.notesBox.contentInset.bottom - self.notesBox.contentInset.top );
    
    if ( overflow > 0 ) {
        NSLog(@"got to overflow");
        // Scroll caret to visible area
        CGPoint offset = self.notesBox.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [self.notesBox setContentOffset:offset];
        }];
    }
    
    [self.notesBox sizeToFit];
    
}

-(void)dismissKeyboard {
    NSLog(@"dismissKeyboard");
    [self.textField resignFirstResponder];
    [self.notesBox resignFirstResponder];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //NSLog(@"textFieldShouldBeginEditing");
    //textField.backgroundColor = [UIColor cloudsColor];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor clearColor];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //NSLog(@"textFieldDidEndEditing");
    self.toDoItem.itemNotes = self.notesBox.text;
    textView.backgroundColor = [UIColor clearColor];
}

- (BOOL)textViewDidBeginEditing:(UITextView *)textView{
    //NSLog(@"textViewDidBeginEditing");
    //textView.backgroundColor = [UIColor cloudsColor];
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add Item";
    
    UIColor * green = [ UIColor colorWithRed:(0/255.0) green:(204/255.0) blue:(0/255.0) alpha:1];
    
    //set title and title color
    [self.navigationItem setTitle:@"GeoTasks"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    // set status bar colors
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    // set button colors, when they are not for navigation
    self.navigationItem.rightBarButtonItem.tintColor = green;
    self.navigationItem.leftBarButtonItem.tintColor = green;
    
    //set bar color
    //set bar color
    UIColor * gray = [ UIColor colorWithRed:(125/255.0) green:(125/255.0) blue:(125/255.0) alpha: .1];
    [self.navigationController.navigationBar setBarTintColor:gray];
    
    //set back button color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:green, NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    //set back button arrow color
    [self.navigationController.navigationBar setTintColor:green];
    
    // set background color
    UIColor* blue = [ UIColor colorWithRed:(9/255.0) green:(6/255.0) blue:(51/255.0) alpha:1];
    [self.view setBackgroundColor:blue];
    
    self.textField.clipsToBounds = YES;
    self.textField.layer.cornerRadius = 5.0f;
    self.textField.layer.borderWidth = 0.1;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    self.notesBox.clipsToBounds = YES;
    self.notesBox.layer.cornerRadius = 5.0f;
    self.notesBox.layer.borderWidth = 0.2;
    
    self.locationOn.transform = CGAffineTransformMakeScale(0.8, 0.8);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
