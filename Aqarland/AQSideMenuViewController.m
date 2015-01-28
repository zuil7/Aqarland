//
//  AQSideMenuViewController.m
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQSideMenuViewController.h"
#import "AQSideMenuCell.h"
#import "AQProfileViewController.h"
#import "MessagesView.h"

@interface AQSideMenuViewController ()

@property(nonatomic,strong) UINavigationController *nControllerView;
@property(nonatomic,strong) UIViewController *destinationController;
@property(nonatomic,strong) NSArray *sideMenuList;

@property(nonatomic,strong) AQProfileViewController *profileVC;

@end

@implementation AQSideMenuViewController

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
    [self LoadViewControllers];
    [self.testLbl setText:NSLocalizedString(@"Morning", nil)];
    self.sideMenuList=[GlobalInstance loadPlistfile:@"sideMenuList" forKey:@"sideMenuList"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///////////////////////////////////////////////
#pragma mark - Logic
///////////////////////////////////////////////
-(void) LoadViewControllers
{

}

///////////////////////////////////////////////
#pragma mark - Action
///////////////////////////////////////////////

-(IBAction)showHome_touchedup_inside:(id)sender
{
    [self.viewDeckController closeLeftView];
}

-(IBAction)logout:(id)sender
{
    [self.viewDeckController closeLeftView];
    [PFUser logOut];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    [GlobalInstance.navController popToRootViewControllerAnimated:NO];
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
    return [self.sideMenuList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sideMenuCell";
    AQSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    [cell bind:self.sideMenuList Idx:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        self.destinationController=[GlobalInstance loadStoryBoardId:sHomeVC];
    }else if(indexPath.row==1)
    {
        self.destinationController=[GlobalInstance loadStoryBoardId:sProfileVC];
    }else if(indexPath.row==2)
    {
        self.destinationController=[GlobalInstance loadStoryBoardId:sPropertiesVC];
    }else if(indexPath.row==3)
    {
        self.destinationController=[[MessagesView alloc] initWithNibName:@"MessagesView" bundle:nil];

    }else if(indexPath.row==4)
    {
        self.destinationController=[GlobalInstance loadStoryBoardId:sSupportVC];
    }else if(indexPath.row==5)
    {
         self.destinationController=[GlobalInstance loadStoryBoardId:sShortListVC];
    }else if(indexPath.row==6)
    {
         self.destinationController=[GlobalInstance loadStoryBoardId:sSettingVC];
    }
    self.nControllerView=[[UINavigationController alloc] initWithRootViewController:self.destinationController];
    self.viewDeckController.centerController = self.nControllerView;
    [self.viewDeckController closeLeftView];
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

@end
