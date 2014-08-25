//
//  XYZTableViewCell.m
//  toDoList
//
//  Created by Mitchell Vollger on 8/21/14.
//
//

#import "XYZTableViewCell.h"

@implementation XYZTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Helpers
        CGSize size = self.contentView.frame.size;
        
        // Initialize Main Label
        self.mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        
        // Configure Main Label
        self.mainLabel.shadowColor = [UIColor blackColor];
        self.mainLabel.shadowOffset = CGSizeMake(-1.5, 1.5);
        [self.mainLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [self.mainLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mainLabel setTextColor:[UIColor darkGrayColor]];
        [self.mainLabel setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        
        // Add Main Label to Content View
        [self.contentView addSubview:self.mainLabel];
        
        //add a border
        [self.contentView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [self.contentView.layer setBorderWidth: 1.5f];
        self.contentView.layer.cornerRadius = 1;
        
    
        // iamges for pressed and unpressed cells
        self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cellback.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        self.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cellpressed.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
        
    }
    
    return self;
}


-(void) status:(BOOL)match{
    UIColor * green  = [ UIColor colorWithRed:(0/255.0) green:(204/255.0) blue:(0/255.0) alpha: .85];
    UIColor * gray = [ UIColor colorWithRed:(125/255.0) green:(125/255.0) blue:(125/255.0) alpha: .85];

    if(match) {
        //NSLog(@"Set Text Color To Green, Matches");
        self.mainLabel.textColor = green;
        self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cellback2.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
        // add route icon
        self.imageView.image = [UIImage imageNamed:@"route.png"];

        
    }
    else {
        //NSLog(@"Set Text Color To Grey, No Matches");
        self.mainLabel.textColor = gray;
        self.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"cellback.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    
        // remove toute icon
        self.imageView.image = NULL;
    }
    
}


@end
