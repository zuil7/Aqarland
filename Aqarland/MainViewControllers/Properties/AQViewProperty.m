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
@property (nonatomic, strong) NSMutableArray *imagesArr;
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
//    self.items = [NSMutableArray array];
//    for (int i = 0; i < 2; i++)
//    {
//        [self.items addObject:@(i)];
//    }
    
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
    
    self.imagesArr=[[NSMutableArray alloc] initWithArray:self.propertyDetails.propertyImages];
    [self.carousel reloadData];
    [self.carousel scrollToItemAtIndex:0 duration:0.0f];
   
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
    return [self.imagesArr count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(ReflectionView *)view
{
    
     PFImageView *customImgView = [[PFImageView alloc] init];
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 195.0f, 195.0f)];
      
        customImgView.frame = view.frame;
        [customImgView setBackgroundColor:[UIColor clearColor]];
        NSDictionary *dictImg=[self.imagesArr objectAtIndex:index];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.alpha = 1.0;
        activityIndicator.center = CGPointMake(customImgView.bounds.size.width / 2.0, customImgView.bounds.size.height / 2.0);
        activityIndicator.hidesWhenStopped = NO;
        [customImgView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [view addSubview:customImgView];
        
        [customImgView setFile:dictImg[@"propertyImg"]];
        [customImgView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error)
            {
                [activityIndicator removeFromSuperview];
            }else
            {
                [activityIndicator removeFromSuperview];
                [GlobalInstance showAlert:iErrorInfo message:[error description]];
            }
        }];
        
    }
    else
    {
        
    }
    [view update];
    return view;
   
}


@end
