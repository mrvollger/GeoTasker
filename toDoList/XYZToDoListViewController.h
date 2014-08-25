//
//  XYZToDoListViewController.h
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//
#import "XYZDetailsViewController.h"
#import <UIKit/UIKit.h>
#import "XYZTableViewCell.h"

extern NSMutableArray *toDoItems;

@interface XYZToDoListViewController : UITableViewController

+(void)rtnToDoItems;

+ (void) alertSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
