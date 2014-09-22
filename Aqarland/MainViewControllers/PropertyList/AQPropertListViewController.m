//
//  AQPropertListViewController.m
//  Aqarland
//
//  Created by Louise on 16/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertListViewController.h"
#import "AQPropertyListCell.h"
#import "AQPropertyListStepTwoVC.h"
#import "AQPropertyTableViewController.h"

@interface AQPropertListViewController ()<PropertyTableViewDelegate>
@property(nonatomic,strong) NSMutableArray *propertyListArr;
@property(nonatomic,strong) AQPropertyListStepTwoVC *propertyListTwo;
@property(nonatomic,strong) AQPropertyTableViewController *tableProperty;
@end

@implementation AQPropertListViewController

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
    [self customizeHeaderBar];
    self.propertyListArr=[[NSMutableArray alloc] initWithArray:[GlobalInstance loadPlistfile:@"sideMenuList" forKey:@"sideMenuList"]];
    self.tableProperty=[GlobalInstance loadStoryBoardId:sPropertyTableVC];
    [self.tableProperty setPropertyDelegate:self];
    [self.tableProperty.view setFrame:CGRectMake(0, 101, 320, 467)];
    [self.view addSubview:self.tableProperty.view];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Property List"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        UIImage *backImage = [UIImage imageNamed:iBackArrowImg];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0,0,22,32);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        
        [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
    }
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
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    [cell bind:self.propertyListArr Idx:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.propertyListTwo=[GlobalInstance loadStoryBoardId:sPropertyListStepTwoVC];
    [self.navigationController pushViewController:self.propertyListTwo animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
///////////////////////////////////////////
#pragma mark - PropertyTableViewDelegate
///////////////////////////////////////////
- (void)didtapcell:(int) nIdx
{
    NSLog(@"nIdx %d",nIdx);
    self.propertyListTwo=[GlobalInstance loadStoryBoardId:sPropertyListStepTwoVC];
    [self.navigationController pushViewController:self.propertyListTwo animated:YES];
    

}

@end
