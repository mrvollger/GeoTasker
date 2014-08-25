//
//  XYZTableViewCell.h
//  toDoList
//
//  Created by Mitchell Vollger on 8/21/14.
//
//

#import <UIKit/UIKit.h>

@interface XYZTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *mainLabel;

-(void) status:(BOOL )match;

@end


