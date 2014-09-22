//
//  AQPropertyTableViewController.m
//  Aqarland
//
//  Created by Louise on 19/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertyTableViewController.h"
#import "AQPropertyListCell.h"

@interface AQPropertyTableViewController ()

@property(nonatomic,strong) NSMutableArray *propertyListArr;
@end

@implementation AQPropertyTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //self.className = @"Todo";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.propertyListArr=[[NSMutableArray alloc] initWithArray:[GlobalInstance loadPlistfile:@"sideMenuList" forKey:@"sideMenuList"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *CellIdentifier = @"propertyCell";
    AQPropertyListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSLog(@"object>>> %@",object);
    NSDictionary *propertyDict = [self.objects objectAtIndex:indexPath.row];
    // Configure the cell...
    [cell bind:propertyDict Idx:indexPath.row];

    
    return cell;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
    [query orderByDescending:@"createdAt"];
    
    
    //query.limit = 10;
    [query includeKey:@"propertyImgArr"];
    
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }    
    return query;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int idx=indexPath.row;
    [self.propertyDelegate didtapcell:idx];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
