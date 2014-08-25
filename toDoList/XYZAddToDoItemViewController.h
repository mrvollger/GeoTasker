//
//  XYZAddToDoItemViewController.h
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//

#import <UIKit/UIKit.h>
#import "XYZToDoItem.h"


@interface XYZAddToDoItemViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property XYZToDoItem *toDoItem;

@end


