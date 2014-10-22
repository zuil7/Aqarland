//
//  AQPropertyListStepTwoVC.m
//  Aqarland
//
//  Created by Louise on 16/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQPropertyListStepTwoVC.h"
#import "AQPropertyListCell.h"
#import "AQPropertyListOptionViewController.h"
#import "AQViewProperty.h"

@interface AQPropertyListStepTwoVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) AQPropertyListOptionViewController *
propertyListOptVC;
@property(nonatomic,strong) AQViewProperty *viewProperty;

@end

@implementation AQPropertyListStepTwoVC

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
    //self.propertyListArr=[NSMutableArray array];
//    self.propertyListArr=[[NSMutableArray alloc] initWithArray:[GlobalInstance loadPlistfile:@"sideMenuList" forKey:@"sideMenuList"]];
    [self customizeHeaderBar];
    NSLog(@"self.propertyListArr %@",self.propertyListArr);
    
   
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
    [self.navigationItem setTitle:@"View in List"];
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
    [self.navigationController pushViewController:self.viewProperty animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
@end
