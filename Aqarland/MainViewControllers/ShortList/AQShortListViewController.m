//
//  AQShortListViewController.m
//  Aqarland
//
//  Created by Louise on 12/8/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQShortListViewController.h"
#import "AQPropertyListCell.h"
#import "AQPropertyListOptionViewController.h"
#import "AQViewProperty.h"

@interface AQShortListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) AQPropertyListOptionViewController *
propertyListOptVC;
@property(nonatomic,strong) AQViewProperty *viewProperty;
@end

@implementation AQShortListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavorites:)
                                                 name:nsUpdateFavorites
                                               object:nil];

    
    [self customizeHeaderBar];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    ParseLayerService *request =[[ParseLayerService alloc] init];
    [request fetchUserFavorites];
    [request setCompletionBlock:^(id results)
     {
         NSLog(@"results %@",results);
         self.propertyListArr=[NSMutableArray arrayWithArray:results];
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
         [self.favoriteTbl reloadData];
     }];
    [request setFailedBlock:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
          [GlobalInstance showAlert:iErrorInfo message:[error userInfo][@"error"]];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.navigationItem setTitle:@"ShortList"];
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

-(void) updateFavorites:(NSNotification *) notify
{
    NSLog(@"notify %@",notify);
    NSDictionary *dict = [[NSDictionary alloc]initWithDictionary:[notify object]];
    NSInteger idx=[dict[@"idx"] intValue];
    
    [self.propertyListArr removeObjectAtIndex:idx];
    [self.favoriteTbl reloadData];
}


///////////////////////////////////////////////
#pragma mark - UITableViewDelegate Methods
//////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.propertyListArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"propertyCell";
    AQPropertyListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PropertyList *property= (PropertyList *)[self.propertyListArr objectAtIndex:indexPath.row];
    NSLog(@"property %@",property.m_houseNumber);
    // Configure the cell...
    NSString *address=[NSString stringWithFormat:@"%@, %@, %@",
                       property.m_street,
                       property.m_city,
                       property.m_postCode];
    [cell bindWithLocalData:address Idx:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.viewProperty=[GlobalInstance loadStoryBoardId:sViewPropertyVC];
    self.viewProperty.propertyDetails=[self.propertyListArr objectAtIndex:indexPath.row];
    self.viewProperty.nIndex=indexPath.row;
    [self.navigationController pushViewController:self.viewProperty animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
@end
