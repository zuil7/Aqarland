//
//  AQPropertiesViewController.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertiesViewController.h"
#import "PropertyList.h"
#import "AQViewProperty.h"

@interface AQPropertiesViewController () <UITableViewDataSource, UITableViewDelegate,AQMyPropertyDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) AQViewProperty *viewProperty;

@end

@implementation AQPropertiesViewController {
    NSMutableArray *propertyList;
    NSMutableArray *propertyListDetails;
    
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
    // Do any additional setup after loading the view.
    propertyList = [[NSMutableArray alloc] init];
    propertyListDetails = [[NSMutableArray alloc] init];
    self.viewProperty = [[AQViewProperty alloc] init];
    
    [self customizeHeaderBar];
    [self setupUserInterfaceComponents];
    [self fetchProperties];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"My Property List"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *menuImage = [UIImage imageNamed:iMenuImg];
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0,0,22,32);
        [menuBtn setImage:menuImage forState:UIControlStateNormal];
        
        [menuBtn addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
    }
   
}

- (void)setupUserInterfaceComponents {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:64.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
}

- (void)fetchProperties {
    
    [MBProgressHUD showHUDAddedTo:GlobalInstance.navController.view animated:YES];
    ParseLayerService *request = [[ParseLayerService alloc] init];
    [request fetchPropertyPerUser];
    [request setCompletionBlock:^(id results) {
        [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
        for(PropertyList *pl in results) {
            NSMutableString *address = [[NSMutableString alloc] initWithString:[pl valueForKey:@"m_houseNumber"]];
            [address appendString:[pl valueForKey:@"m_building"]];
            [address appendString:@", "];
            [address appendString:[pl valueForKey:@"m_street"]];
            [address appendString:@", "];
            [address appendString:[pl valueForKey:@"m_city"]];
            [address appendString:@" "];
            [address appendString:[pl valueForKey:@"m_postCode"]];
         
            [propertyList addObject:address];
            [propertyListDetails addObject:pl];
        }
        [self.tableView reloadData];
    }];
    [request setFailedBlock:^(NSError *error) {
        [MBProgressHUD hideHUDForView:GlobalInstance.navController.view animated:YES];
        [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return propertyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [propertyList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.viewProperty = [GlobalInstance loadStoryBoardId:sViewPropertyVC];
    self.viewProperty.propertyDetails = [propertyListDetails objectAtIndex:indexPath.row];
    self.viewProperty.isUserDetails=YES;
    self.viewProperty.nIndex=indexPath.row;
    [self.viewProperty setDelegate:self];
    [self.navigationController pushViewController:self.viewProperty animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)updateMyPropertyList:(NSInteger )nDx
{
    [propertyList removeObjectAtIndex:nDx];
    [self.tableView reloadData];
}

@end
