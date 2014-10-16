//
//  AQSearchViewController.m
//  Aqarland
//
//  Created by Louise on 13/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQSearchViewController.h"
#import "IQKeyboardManager.h"
#import "PropertyList.h"

@interface AQSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *seachedLocations;
@property (strong, nonatomic) NSMutableArray *filteredseachedLocations;

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
    self.filteredseachedLocations = [[NSMutableArray alloc] init];
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

- (void)reloadData {
//    inSearchMode = NO;
//    self.seachedLocations = originalData;
//    [self.tableView reloadData];
}

- (void)fetchDataForSearch {
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    ParseLayerService *request = [[ParseLayerService alloc] init];
    [request fetchProperty];
    [request setCompletionBlock:^(id results) {
        properties = [[NSMutableArray alloc] initWithArray:results];
        [self.searchTbl reloadData];
        NSLog(@"properties : %@", properties);
        [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
     }];
    [request setFailedBlock:^(NSError *error) {
         [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
        [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (inSearchMode) {
        numberOfRows = self.filteredseachedLocations.count;
    } else {
        numberOfRows = properties.count;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *propertyString;
    if (inSearchMode) {
        PropertyList *propertyList = [self.filteredseachedLocations objectAtIndex:indexPath.row];
        NSMutableString *address = [[NSMutableString alloc] initWithString:[propertyList valueForKey:@"m_houseNumber"]];
        [address appendString:[propertyList valueForKey:@"m_building"]];
        [address appendString:@", "];
        [address appendString:[propertyList valueForKey:@"m_street"]];
        [address appendString:@", "];
        [address appendString:[propertyList valueForKey:@"m_city"]];
        [address appendString:@" "];
        [address appendString:[propertyList valueForKey:@"m_postCode"]];
        
        propertyString = address;
    } else {
        propertyString = @"";
    }
    cell.textLabel.text = propertyString;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 26.0f;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    BOOL isSearchTextFound;
    if ([searchText isEqual:nil] || [searchText isEqualToString:@""]) {
        inSearchMode = NO;
    } else {
        inSearchMode = YES;
        [self.filteredseachedLocations removeAllObjects];
        for (PropertyList *property in properties) {
            isSearchTextFound = NO;
            
            if ([[property valueForKey:@"m_amenities"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_building"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_city"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_description"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_houseNumber"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_numberOfBaths"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_numberOfBedrooms"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_postCode"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_price"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_propertySize"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_propertyType"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_street"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            } else if ([[property valueForKey:@"m_unit"] rangeOfString:searchText].location != NSNotFound) {
                isSearchTextFound = YES;
            }
            
            if (isSearchTextFound) {
                [self.filteredseachedLocations addObject:property];
            }
        }
    }
    [self.searchTbl reloadData];
}

@end
