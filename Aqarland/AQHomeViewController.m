//
//  AQHomeViewController.m
//  Aqarland
//
//  Created by Louise on 30/7/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQHomeViewController.h"
#import "AQSearchViewController.h"
#import "AQAddPropertyViewController.h"

@interface AQHomeViewController ()<AQSearchViewControllerDelegate>
@property(nonatomic,strong) AQSearchViewController *addPropertyVC;
@property(nonatomic,strong) AQSearchViewController *searchVC;
@end

@implementation AQHomeViewController

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
    // Do any additional setup after loading the view from its nib.
     [self customizeHeaderBar];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchPropertyList];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
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
/*
-(void)tabbarCustomization
{
//    [self.listPropertyBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,RGB(34, 141, 187), NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [self.listPropertyBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} forState:UIControlStateNormal];
}*/
-(void) fetchPropertyList
{
    ParseLayerService *request=[[ParseLayerService alloc] init];
    [request fetchProperty];
    [request setCompletionBlock:^(id results)
    {
             
    }];
    [request setFailedBlock:^(NSError *error)
     {
         [GlobalInstance showAlert:iErrorInfo message:[error description]];
    }];
}
-(void) customizeHeaderBar
{
    //self.navigationItem.titleView = self.searchBar;
    //[self.navigationItem setTitle:@"Property Map"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"left", nil) style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
        UIImage *menuImage = [UIImage imageNamed:iMenuImg];
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0,0,22,32);
        [menuBtn setImage:menuImage forState:UIControlStateNormal];
        
        [menuBtn addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        [self.navigationItem setLeftBarButtonItem:barButtonItem];

    }
    
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)])
    {
        UIImage *searchImage = [UIImage imageNamed:iSearchImg];
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = CGRectMake(0,0,22,32);
        [searchBtn setImage:searchImage forState:UIControlStateNormal];
        
        [searchBtn addTarget:self action:@selector(searchBarBtn_touchedupInside:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
        [self.navigationItem setRightBarButtonItem:barButtonItem];
        
    }

}
////////////////////////////////////
#pragma mark - Action
////////////////////////////////////
-(IBAction)listProperty_touchedup_inside:(id)sender
{
   //self.searchVC = [GlobalInstance loadStoryBoardId:sSearchVC];
}
-(IBAction)addProperty_touchedup_inside:(id)sender
{
    self.addPropertyVC=[GlobalInstance loadStoryBoardId:sAddPropertyVC];
    [self.navigationController pushViewController:self.addPropertyVC animated:YES];
}
-(IBAction)myChats_touchedup_inside:(id)sender
{
    
}

-(IBAction)mapviewType:(id)sender
{
    if([sender isSelected])
    {
        self.mapView.mapType=MKMapTypeStandard;
        [sender setSelected:NO];
    }else
    {
        self.mapView.mapType=MKMapTypeHybrid;
        [sender setSelected:YES];
    }
}
////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////

-(void) searchBarBtn_touchedupInside:(id) sender
{
    [self.navigationController setNavigationBarHidden:YES];
    self.searchVC = [GlobalInstance loadStoryBoardId:sSearchVC];
    
    [self.searchVC setSearchVCDelegate:self];
    
    [self addChildViewController:self.searchVC];
    self.searchVC.view.frame = self.view.bounds;
    [self.view addSubview:self.searchVC.view];
    [self.searchVC didMoveToParentViewController:self];
   
   

}
////////////////////////////////////
#pragma mark - AQSearchViewControllerDelegate
////////////////////////////////////
- (void)showNavigationBar
{
     [self.navigationController setNavigationBarHidden:NO];
}

@end
