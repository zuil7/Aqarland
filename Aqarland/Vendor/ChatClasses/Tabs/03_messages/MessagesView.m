//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "MessagesView.h"
#import "MessagesCell.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessagesView()
{
	NSMutableArray *messages;
	UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *tableMessages;
@property (strong, nonatomic) IBOutlet UIView *viewEmpty;
@property (strong, nonatomic)  PFFile *lastUserAvatar;
@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) NSMutableArray *agentAvatarArr;
@property (strong, nonatomic) NSMutableArray *userAgentArr;
@property (strong, nonatomic) NSMutableArray *userAgentTempArr;
@property (strong, nonatomic) NSMutableDictionary *userInfoDict;

@property (strong, nonatomic) PFUser *agentUser;
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessagesView

@synthesize tableMessages, viewEmpty;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_messages"]];
		self.tabBarItem.title = @"Messages";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Messages";
    self.agentAvatarArr=[[NSMutableArray alloc] init];
    self.userAgentArr=[[NSMutableArray alloc] init];
    self.userAgentTempArr=[[NSMutableArray alloc] init];
    self.messageArray=[[NSMutableArray alloc] init];
    [self customizeHeaderBar];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[tableMessages registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
	tableMessages.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
	[tableMessages addSubview:refreshControl];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	messages = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEmpty.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadMessages];
	}
	else LoginUser(self);
}
////////////////////////////////////
#pragma mark - Logic
////////////////////////////////////
-(void) customizeHeaderBar
{
    [self.navigationItem setTitle:@"Messages"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBarTintColor:RGB(34, 141, 187)];
    
    if ([self.navigationItem respondsToSelector:@selector(leftBarButtonItems)])
    {
        if (self.isComingFromHome)
        {
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popViewControllerAnimated:)];
            [barButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:TitleHeaderFont size:TitleHeaderFontSize], NSFontAttributeName,RGB(255, 255, 255), NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
            [self.navigationItem setLeftBarButtonItem:barButtonItem];
//            UIImage *backImage = [UIImage imageNamed:iBackArrowImg];
//            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            backBtn.frame = CGRectMake(0,0,22,32);
//            [backBtn setImage:backImage forState:UIControlStateNormal];
//            
//            [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
//            
//            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
//            [self.navigationItem setLeftBarButtonItem:barButtonItem];
        }else
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
    
}
#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
   // __block NSMutableDictionary *dictUser=[[NSMutableDictionary alloc] init];

//    [self.agentAvatarArr removeAllObjects];
	if ([PFUser currentUser] != nil)
	{
		PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
		[query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
		[query includeKey:PF_MESSAGES_LASTUSER];
        [query includeKey:@"FromUser"];
        [query includeKey:@"ToUser"];
      //  [query includeKey:@"UserProfileArray"];
		[query orderByDescending:PF_MESSAGES_UPDATEDACTION];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
            self.messageArray=[NSMutableArray arrayWithArray:objects];
            NSLog(@"objects %@",objects);
            for (NSDictionary *dict in objects)
            {
                NSMutableDictionary *dictUser=[[NSMutableDictionary alloc] init];
                PFUser *currentUser=[PFUser currentUser];
                PFUser *tempUser;
                PFUser *agentUser=(PFUser *)dict[@"FromUser"];
                PFObject *obj;
                if ([agentUser.objectId isEqualToString:currentUser.objectId])
                {
                     obj=(PFObject*)dict[@"ToUser"];
                     tempUser=dict[@"ToUser"];
                    dictUser[@"UserInfo"]=dict[@"ToUser"];
                    dictUser[@"ImgUser"]=@"";
                    //[self.userAgentArr addObject:dictUser];
                }else
                {
                    obj=(PFObject*)dict[@"FromUser"];
                    tempUser=dict[@"FromUser"];
                    dictUser[@"UserInfo"]=dict[@"FromUser"];
                    dictUser[@"ImgUser"]=@"";

                    //[self.userAgentArr addObject:dictUser];

                }
                [self.userAgentArr addObject:dictUser];
                [self.userAgentTempArr addObject:tempUser];
//                NSLog(@"self.messageArray %@",self.messageArray);
//                NSLog(@"obj %@",obj[@"UserProfile"]);
                PFRelation *relation = obj[@"userProfile"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
                 {
//                     NSLog(@"self.userAgentArr %@",self.userAgentArr);
                     NSLog(@"results>>> %@",results);
//                     NSLog(@"self.userAgentTempArr %@",self.userAgentTempArr);

                     if([results count]!=0)
                     {
                         for (int i=0; i<[self.userAgentArr count]; i++)
                         {
                             NSDictionary *tempUser=[self.userAgentArr objectAtIndex:i];
                             PFUser *tempUser1=tempUser[@"UserInfo"];
                             NSDictionary *dict=[results objectAtIndex:0];
                             PFUser *agentUser=dict[@"user"];
//                             NSLog(@"agentUser.objectId>>> %@",agentUser.objectId);
//                             NSLog(@"tempUser>>> %@",tempUser1.objectId);

                             if ([tempUser1.objectId isEqualToString:agentUser.objectId])
                             {
                                 NSMutableDictionary *innerDict= [[NSMutableDictionary alloc] initWithDictionary:[self.userAgentArr objectAtIndex:i]];

                                 if(dict[@"userAvatar"])
                                 {
                                     [innerDict setObject:dict[@"userAvatar"] forKey:@"ImgUser"];
                                     [self.userAgentArr replaceObjectAtIndex:i withObject:innerDict];
                                     NSLog(@"self.userAgentArr %@",self.userAgentArr);
                                 }
                                 [self.agentAvatarArr addObject:innerDict[@"UserInfo"]];

                             }
                         }
                         //NSDictionary *dict=[results objectAtIndex:0];
                         //dictUser=[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", nil]
                         //[self.agentAvatarArr addObject:dict[@"userAvatar"]];
                     }
                     NSLog(@"self.agentAvatarArr %@",self.agentAvatarArr);
                     if([self.messageArray count]!=0)
                     {
                         if (error == nil)
                         {
                             if ([self.agentAvatarArr count]==[self.messageArray count])
                             {
                                 [messages removeAllObjects];
                                 [messages addObjectsFromArray:self.messageArray];
                                 //[self.agentAvatarArr reverseObjectEnumerator];
                                 //[self.userAgentArr reverseObjectEnumerator];
                                 [tableMessages reloadData];
                                 [self updateEmptyView];
                                 [self updateTabCounter];
                             }
                         }
                         else
                         {
                             [ProgressHUD showError:@"Network error."];
                         }
                         [refreshControl endRefreshing];
                         
                     }
                     else
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:iInformation
                                                                         message:@"No Messages"
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         [alert show];
                     }

                 }];
            }
 
            }];
	}
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateEmptyView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	viewEmpty.hidden = ([messages count] != 0);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int total = 0;
	for (PFObject *message in messages)
	{
		total += [message[PF_MESSAGES_COUNTER] intValue];
	}
	UITabBarItem *item = self.tabBarController.tabBar.items[2];
	item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[messages removeAllObjects];
	[tableMessages reloadData];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITabBarItem *item = self.tabBarController.tabBar.items[2];
	item.badgeValue = nil;
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell" forIndexPath:indexPath];
    if([self.userAgentArr count]!=0)
    {
        NSLog(@"self.userAgentArr %@",self.userAgentArr);
        NSDictionary *dict=[self.userAgentArr objectAtIndex:indexPath.row];
        PFFile *avatar=(PFFile *)dict[@"ImgUser"];
        NSLog(@"ImgUser %@",dict[@"ImgUser"]);
        NSLog(@"avatar %@",avatar);
        if ([avatar isKindOfClass:[PFFile class] ])
        {
            [cell bindData:messages[indexPath.row] avatar:avatar];
        }else
        {
             [cell bindData:messages[indexPath.row] avatar:nil];
        }
        
    }else
    {
        [cell bindData:messages[indexPath.row] avatar:nil];
    }
	
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	DeleteMessageItem(messages[indexPath.row]);
	[messages removeObjectAtIndex:indexPath.row];
	[tableMessages deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self updateEmptyView];
	[self updateTabCounter];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *message = messages[indexPath.row];
	ChatView *chatView = [[ChatView alloc] initWith:message[PF_MESSAGES_ROOMID]];
    NSDictionary *dict=self.userAgentArr[indexPath.row];
    PFFile *avatar=dict[@"ImgUser"];
    if ([avatar isKindOfClass:[PFFile class] ])
    {
        NSLog(@"avatar %@",avatar);
        NSData *imageData = [avatar getData];
        chatView.agentAvatar=[UIImage imageWithData:imageData];
    }else
    {
        chatView.agentAvatar=[UIImage imageNamed:@"chat_blank"];

    }
   

    chatView.userAgent=(PFUser *)[self.agentAvatarArr objectAtIndex:indexPath.row];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

@end
