//
//  AQSearchViewController.m
//  Aqarland
//
//  Created by Louise on 13/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQSearchViewController.h"
#import "AQViewProperty.h"
#import "IQKeyboardManager.h"
#import "PropertyList.h"

@interface AQSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *seachedLocations;
@property (strong, nonatomic) NSMutableArray *locationAddresses;
@property (strong, nonatomic) NSMutableArray *filteredSearchedPropertyLocations;
@property (strong, nonatomic) AQViewProperty *viewProperty;

@end

@implementation AQSearchViewController {
    BOOL inSearchMode;
    NSMutableArray *properties;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [self.searchBar becomeFirstResponder];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
   // [self customizeHeaderBar];
    self.viewProperty = [[AQViewProperty alloc] init];
    self.filteredSearchedPropertyLocations = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchDataForSearch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [self.searchVCDelegate showNavigationBar];
}

#pragma mark - Private

- (void)customizeHeaderBar {
    [self.navigationItem setTitle:@"Profile"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)]) {
        UIImage *menuImage = [UIImage imageNamed:iMenuImg];
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0,0,22,32);
        [menuBtn setImage:menuImage forState:UIControlStateNormal];
        [menuBtn addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
}

- (void)fetchDataForSearch {
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    ParseLayerService *request = [[ParseLayerService alloc] init];
    [request fetchProperty];
    [request setCompletionBlock:^(id results) {
        [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
        properties = [[NSMutableArray alloc] initWithArray:results];
        [self saveLocationAddressesWithArray:properties];
        [self.searchTbl reloadData];
     }];
    [request setFailedBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
        [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
     }];
}

- (void)saveLocationAddressesWithArray:(NSArray *)locations {
    
    self.locationAddresses = [NSMutableArray arrayWithCapacity:locations.count];

    for (PropertyList *propertyList in locations) {
        NSMutableString *address = [[NSMutableString alloc] initWithString:[propertyList valueForKey:@"m_houseNumber"]];
        [address appendString:[propertyList valueForKey:@"m_building"]];
        [address appendString:@", "];
        [address appendString:[propertyList valueForKey:@"m_street"]];
        [address appendString:@", "];
        [address appendString:[propertyList valueForKey:@"m_city"]];
        [address appendString:@" "];
        [address appendString:[propertyList valueForKey:@"m_postCode"]];

        [self.locationAddresses addObject:address];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (inSearchMode) {
        numberOfRows = self.filteredSearchedPropertyLocations.count;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    PropertyList *propertyList;
    if (inSearchMode) {
        propertyList = [self.filteredSearchedPropertyLocations objectAtIndex:indexPath.row];
    }
    
    NSMutableString *address = [[NSMutableString alloc] initWithString:[propertyList valueForKey:@"m_houseNumber"]];
    [address appendString:[propertyList valueForKey:@"m_building"]];
    [address appendString:@", "];
    [address appendString:[propertyList valueForKey:@"m_street"]];
    [address appendString:@", "];
    [address appendString:[propertyList valueForKey:@"m_city"]];
    [address appendString:@" "];
    [address appendString:[propertyList valueForKey:@"m_postCode"]];
    
    cell.textLabel.text = address;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchVCDelegate showNavigationBar];
    self.viewProperty = [GlobalInstance loadStoryBoardId:sViewPropertyVC];
    
    if (inSearchMode) {
        self.viewProperty.propertyDetails = [self.filteredSearchedPropertyLocations objectAtIndex:indexPath.row];
    } else {
        self.viewProperty.propertyDetails = [properties objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:self.viewProperty animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if ([searchText isEqual:nil] || [searchText isEqualToString:@""]) {
        inSearchMode = NO;
    } else {
        inSearchMode = YES;
        [self.filteredSearchedPropertyLocations removeAllObjects];
        
        NSString *match = [NSString stringWithFormat:@"*%@*",searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@", match];
        NSArray *results = [self.locationAddresses filteredArrayUsingPredicate:predicate];
        
        
        for (NSString *matchingString in results) {
            NSInteger index = [self.locationAddresses indexOfObject:matchingString];
            [self.filteredSearchedPropertyLocations addObject:properties[index]];
        }
        
    }
    [self.searchTbl reloadData];
}

@end
