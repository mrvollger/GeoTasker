//
//  XYZToDoItem.m
//  toDoList
//
//  Created by Mitchell Vollger on 3/19/14.
//
//

#import "XYZToDoItem.h"

@implementation XYZToDoItem 


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_itemName forKey:@"itemName"];
    [coder encodeObject:_itemNotes forKey:@"itemNotes"];
    [coder encodeObject:_itemLocation forKey:@"itemLocation"];
    [coder encodeObject:_creationDate forKey:@"creationDate"];
    [coder encodeBool:_completed forKey:@"completed"];
    [coder encodeBool:_hasLocation forKey:@"hasLocation"];
    

}

- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super init];
    if (self != NULL)
    {
        _itemName = [coder decodeObjectForKey:@"itemName"];
        _itemNotes = [coder decodeObjectForKey:@"itemNotes"];
        _itemLocation = [coder decodeObjectForKey:@"itemLocation"];
        _creationDate = [coder decodeObjectForKey:@"creationDate"];
        _completed = [coder decodeBoolForKey:@"completed"];
        _hasLocation = [coder decodeBoolForKey:@"hasLocation"];
        _match = false;
        _matches = NULL;
        _radius = 500;
        _closeMatch = NULL;
        _current = NULL;
        
    }
    
    return self;
}


- (void) save:(NSString*)path toDoItem:(XYZToDoItem*) toDoItem
{
    NSMutableData* data = [[NSMutableData alloc] init];
    if (data)
    {
        NSKeyedArchiver* archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        if (archiver)
        {
            [archiver encodeInt:1 forKey:@"Version"];
            [archiver encodeObject:toDoItem forKey:@"toDoItem"];
            [archiver finishEncoding];
            
            [data writeToFile:path atomically:YES];
            
        }
    }
}


- (XYZToDoItem*) load:(NSString*)path
{
    XYZToDoItem* ret = NULL; //[[XYZToDoItem alloc] init];
    
    NSData* data=[NSData dataWithContentsOfFile:path];
    
    if (data)
    {
        NSKeyedUnarchiver* unarchiver=[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        if (unarchiver)
        {
            int version=[unarchiver decodeIntForKey:@"Version"];
            if (version==1)
            {
                ret = (XYZToDoItem*)[unarchiver decodeObjectForKey:@"toDoItem"];
            }
            [unarchiver finishDecoding];
        }
    }
    return ret;
}



@end