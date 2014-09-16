//
//  AQViewProperty.m
//  Aqarland
//
//  Created by Louise on 2/9/14.
//  Copyright (c) 2014 Louise. All rights reserved.
//

#import "AQViewProperty.h"
#import "ReflectionView.h"

@interface AQViewProperty ()
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation AQViewProperty

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)awakeFromNib
{
    //set up data
    //your carousel should always be driven by an array of
    //data of some kind - don't store data in your item views
    //or the recycling mechanism will destroy your data once
    //your item views move off-screen
    self.items = [NSMutableArray array];
    for (int i = 0; i < 10; i++)
    {
        [self.items addObject:@(i)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [self customizeHeaderBar];
    self.carousel.type = iCarouselTypeCoverFlow2;
    NSLog(@"self.items %@",self.items);
}
- (void)viewDidLayoutSubviews
{
    [self.propertySV setContentSize:CGSizeMake(320, 900)];
}

- (void)didReceiveMemoryWarning
{
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
    [self.navigationItem setTitle:@"Unit Number"];
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
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)])
    {
        UIImage *favoriteImage = [UIImage imageNamed:iFavoriteImg];
        UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        favoriteBtn.frame = CGRectMake(0,0,22,22);
        [favoriteBtn setImage:favoriteImage forState:UIControlStateNormal];
        
        [favoriteBtn addTarget:self action:@selector(favorites_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIImage *shareImage = [UIImage imageNamed:iShareImg];
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(0,0,22,22);
        [shareBtn setImage:shareImage forState:UIControlStateNormal];
        
        [shareBtn addTarget:self action:@selector(share_touchedup_inside:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *favoriteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:favoriteBtn];
        
        UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
        
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:favoriteButtonItem, shareButtonItem, nil];
        
        
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)favorites_touchedup_inside:(id) sender
{
    
}

-(void)share_touchedup_inside:(id) sender
{
    
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [self.items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 195.0f, 195.0f)];
        label = [[UILabel alloc] initWithFrame:view.bounds];
		label.backgroundColor = [UIColor lightGrayColor];
		label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 4.0f;
        label.layer.cornerRadius = 8.0f;
        label.textAlignment = NSTextAlignmentCenter;
		label.font = [label.font fontWithSize:50];
        label.tag = 9999;
		[view addSubview:label];
        
        //set up content
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [self.items[index] stringValue];
    
    return view;
}


@end
