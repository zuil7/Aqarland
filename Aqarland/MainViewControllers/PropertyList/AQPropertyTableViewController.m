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
@property(nonatomic,strong) NSMutableArray *distinctCity;
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
    self.distinctCity=[[NSMutableArray alloc] init];
    
    self.propertyListArr=[[NSMutableArray alloc] initWithArray:[GlobalInstance loadPlistfile:@"sideMenuList" forKey:@"sideMenuList"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.distinctCity count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *CellIdentifier = @"propertyCell";
    AQPropertyListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSMutableDictionary *propertyDict=[[NSMutableDictionary alloc] init];
    NSString *strCity= [self.distinctCity objectAtIndex:indexPath.row];
    [propertyDict setObject:strCity forKey:@"city"];
    // Configure the cell...
    [cell bind:propertyDict Idx:indexPath.row :self.flagStr];

    return cell;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:pPropertyList];
   

    if ([self.flagStr isEqualToString:@"City"])
    {
        [query orderByDescending:@"createdAt"];
        //query.limit = 10;
        [query includeKey:@"propertyImgArr"];
        if ([self.objects count] == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
    }else
    {
        NSLog(@"self.StreetStr %@",self.StreetStr);
        [query whereKey:@"city" equalTo:self.StreetStr];
        [query orderByDescending:@"createdAt"];
        //query.limit = 10;
        [query includeKey:@"propertyImgArr"];
        if ([self.objects count] == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }


    }
    
    return query;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AQPropertyListCell *cell = (AQPropertyListCell *)[tableView cellForRowAtIndexPath:indexPath];
    int idx=(int)indexPath.row;
    [self.propertyDelegate didtapcell:idx :cell.placeLbl.text];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    self.distinctCity= [self.objects valueForKeyPath:@"@distinctUnionOfObjects.city"];
    NSLog(@"self.distinctCity %@",self.distinctCity);
}

@end
