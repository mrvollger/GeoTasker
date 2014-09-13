//
//  XYZToDoListViewController.m
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//

#import "XYZToDoListViewController.h"
#import "XYZToDoItem.h"
#import "XYZAddToDoItemViewController.h"
#import "XYZDetailsViewController.h"
#import "XYZAppDelegate.h"
#import "findMatches.h"

@interface XYZToDoListViewController ()

@end

NSMutableArray *toDoItems = nil;

NSMutableArray *toDoItemsNoMatch = nil;
NSMutableArray *toDoItemsMatch = nil;


// this allows for refreashing
UIRefreshControl * refreshControl = nil;
// the is the cell identifyer which can be found in main.
static NSString *CellIdentifier = @"CellIdentifier";


@implementation XYZToDoListViewController

+(void)rtnToDoItems{
    NSLog(@"%@", toDoItems.description);
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    XYZAddToDoItemViewController *source = [segue sourceViewController];
    XYZToDoItem *item = source.toDoItem;
    // Make query after item is added
    if (item != nil) {
        [toDoItems addObject:item];
        [findMatches find];
        [self.tableView reloadData];
    
    
    
    //sets a delay which allows findmatches to complete
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(item.match){
            [toDoItemsMatch addObject:item];
        }
        else{
            [toDoItemsNoMatch addObject:item];
        }
        NSLog(@"%@", toDoItemsMatch.firstObject);
        NSLog(@"%@", toDoItemsNoMatch.firstObject);
        [self.tableView reloadData];
    });

    }


}

- (void)refreshTable{
    [findMatches find];
    [self.tableView reloadData];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    [refreshControl endRefreshing];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //cancel outstanding notifications when the user sees all the to do items
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // set background image
    // UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GeoLaunch2.png"]];
    //[tempImageView setFrame:self.tableView.frame];
    //self.tableView.backgroundView = tempImageView;
    
    // set background color
    UIColor* blue = [ UIColor colorWithRed:(9/255.0) green:(6/255.0) blue:(51/255.0) alpha:1];
    [self.view setBackgroundColor:blue];
    self.tableView.opaque = NO;
    
    
    
    // Register Class for Cell Reuse Identifier
    [self.tableView registerClass:[XYZTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UIColor * green = [ UIColor colorWithRed:(0/255.0) green:(204/255.0) blue:(0/255.0) alpha:1];

    //remove seperators
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //seperator color
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];

    
    // Allow pull down to refreash
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    //set title and title color
    [self.navigationItem setTitle:@"GeoTasks"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    // set status bar colors
    [UIApplication sharedApplication].statusBarStyle = UIBarStyleDefault;
    
    // set button colors, when they are not for navigation
    self.navigationItem.rightBarButtonItem.tintColor = green;
    self.navigationItem.leftBarButtonItem.tintColor = green;
    
    //set bar color
    //UIColor * gray = [ UIColor colorWithRed:(125/255.0) green:(125/255.0) blue:(125/255.0) alpha: .1];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    //set back button color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:green, NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    //set back button arrow color
    [self.navigationController.navigationBar setTintColor:green];
    
    // extends lines in the table to edges
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
   
    // part of what allows for adjustable table cell height
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadInitialData];

}

- (void)loadInitialData {
    
    // create arrays
    toDoItems = [[NSMutableArray alloc] init];
    toDoItemsMatch = [[NSMutableArray alloc] init];
    toDoItemsNoMatch = [[NSMutableArray alloc] init];
    
    int i = 0;
    // stress test
    while(i < 0){
        XYZToDoItem *item1 = [[XYZToDoItem alloc] init];
        item1.matches = [[NSMutableArray alloc] init];
        item1.itemName = @"starbucks";
        item1.itemNotes = @"This is a preloaded item to show that it is possible";
        item1.hasLocation = true;
        [toDoItems addObject:item1];
        i++;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLocationChange:)
                                                 name:@"locationChanged"
                                               object:nil];
    
    // the following lines load saved toDoItems from the previous session
    NSString *extension = @"toDoItem";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extension]) {
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
            XYZToDoItem * x = [[XYZToDoItem alloc] init];
            x = [x load:filePath];
            [toDoItems addObject:x];
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }

    [findMatches find];
    //sets a delay which allows findmatches to complete
    int64_t delayInSeconds = 1.5 + 0.2 * [toDoItems count];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
    
    // populate the other to do lists
    XYZToDoItem * item = nil;
    for(item in toDoItems){
        if(item.match){
            [toDoItemsMatch addObject:item];
        }
        else{
            [toDoItemsNoMatch addObject:item];
        }
    }
    
    //cancel outstanding notifications when the user sees all the to do items
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)receivedLocationChange:(NSNotification*)notification
{
    // Once the images are done downloading, you just need to refresh the tableView.  It will
    // then display the newly acquired data in your table cells.
    //NSLog(@"table reloaded!");
    // populate the other to do lists
    XYZToDoItem * item = nil;
    for(item in toDoItems){
        if(item.match){
            [toDoItemsMatch addObject:item];
        }
        else{
            [toDoItemsNoMatch addObject:item];
        }
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
        return [toDoItems count];
}

- (XYZTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    XYZTableViewCell *cell = (XYZTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    XYZToDoItem *toDoItem = [toDoItems objectAtIndex:indexPath.row];
    
    NSString * str = toDoItem.itemName;
    
    if(toDoItem.match){
        str = [str stringByAppendingString:@" at \'"];
        str = [str stringByAppendingString:toDoItem.closeMatch.name];
        str = [str stringByAppendingString:@"\'"];
        str = [@"\t\t" stringByAppendingString:str];
    }
    str = [@"\t" stringByAppendingString:str];

    [cell.mainLabel setText:str];
    
    return cell;
}

-(void)viewDidAppear:(BOOL)animated{
    //NSLog(@"Is reloading the table view");
    [self.tableView reloadData];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(XYZTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];

    XYZToDoItem * current = [toDoItems objectAtIndex:indexPath.row];
    cell.layoutMargins = UIEdgeInsetsZero;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    [cell status:current.match];

}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [toDoItems removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"showDetail"] ) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        XYZDetailsViewController *destViewController = segue.destinationViewController;
        destViewController.toDoItem = [toDoItems objectAtIndex:indexPath.row];
    }
    
    if ( [segue.identifier isEqualToString:@"oneAlertShow"] ) {
        XYZDetailsViewController *destViewController = segue.destinationViewController;
        destViewController.toDoItem = oneAlert;
    }


}

+ (void) alertSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"oneAlertShow"] ) {
        XYZDetailsViewController *destViewController = segue.destinationViewController;
        destViewController.toDoItem = oneAlert;
    }

}



@end
