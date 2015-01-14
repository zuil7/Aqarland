//
//  AQViewPropertyImageViewer.m
//  Aqarland
//
//  Created by Louise on 14/1/15.
//  Copyright (c) 2015 Louise. All rights reserved.
//

#import "AQViewPropertyImageViewer.h"
#import "AQPhotoViewer.h"
@interface AQViewPropertyImageViewer ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation AQViewPropertyImageViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  
    NSLog(@"self.ImgArr %@",self.ImgArr);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self customizeHeaderBar];
   
    
    [self.imgCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.idx inSection:0]
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                             animated:YES];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) customizeHeaderBar
{
    
    NSString *titleStr=[NSString stringWithFormat:@"Image %d/%d",self.idx + 1,[self.ImgArr count]];

    [self.navigationItem setTitle:titleStr];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePressed:)];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/////////////////////////////////
#pragma mark - Collection Delegate
//////////////////////////////////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.ImgArr count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AQPhotoViewer *cell;
    
        cell= (AQPhotoViewer *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoViewerCell" forIndexPath:indexPath];
//        [cell.photoImg setImage:[self.imageList objectAtIndex:indexPath.row]];
//        [cell.deleteImgBtn setTag:indexPath.row];
//        [cell.deleteImgBtn addTarget:self
//                              action:@selector(deleteImg:)
//                    forControlEvents:UIControlEventTouchDown];
    [cell.imgHolder setImage:[self.ImgArr objectAtIndex:indexPath.row]];
//

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // [self.weatherCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    //    CustomCollectionCell *cell = (CustomCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    //    NSArray *views = [cell.contentView subviews];
    //    UILabel *label = [views objectAtIndex:0];
    //NSLog(@"Select %d",indexPath.row);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.imgCollection.frame.size.width;
    int idx = (self.imgCollection.contentOffset.x + pageWidth / 2) / pageWidth;

    NSString *titleStr=[NSString stringWithFormat:@"Image %d/%d",idx + 1,[self.ImgArr count]];
    [self.navigationItem setTitle:titleStr];
}
@end
