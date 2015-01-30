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
@property (strong, nonatomic) NSArray *messageArray;
@property (strong, nonatomic) NSMutableArray *agentAvatarArr;
@property (strong, nonatomic) NSMutableArray *userAgentArr;
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
            UIImage *backImage = [UIImage imageNamed:iBackArrowImg];
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(0,0,22,32);
            [backBtn setImage:backImage forState:UIControlStateNormal];
            
            [backBtn addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
            [self.navigationItem setLeftBarButtonItem:barButtonItem];
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
            self.messageArray=objects;
            NSLog(@"objects %@",objects);
            for (NSDictionary *dict in objects)
            {
                PFUser *currentUser=[PFUser currentUser];
                PFUser *agentUser=(PFUser *)dict[@"FromUser"];
                PFObject *obj;
                if ([agentUser.objectId isEqualToString:currentUser.objectId])
                {
                     obj=(PFObject*)dict[@"ToUser"];
                    [self.userAgentArr addObject:dict[@"ToUser"]];
                }else
                {
                    obj=(PFObject*)dict[@"FromUser"];
                    [self.userAgentArr addObject:dict[@"FromUser"]];

                }
                
                NSLog(@"obj %@",obj[@"UserProfile"]);
                PFRelation *relation = obj[@"userProfile"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
                 {
                     NSLog(@"results %@",results);
                     if([results count]!=0)
                     {
                         NSDictionary *dict=[results objectAtIndex:0];
                         [self.agentAvatarArr addObject:dict[@"userAvatar"]];
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
                                 [self.agentAvatarArr reverseObjectEnumerator];
                                 [self.userAgentArr reverseObjectEnumerator];
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
    if([self.agentAvatarArr count]!=0)
    {
        PFFile *avatar=self.agentAvatarArr[indexPath.row];
        [cell bindData:messages[indexPath.row] avatar:avatar];
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
    PFFile *avatar=self.agentAvatarArr[indexPath.row];
    NSLog(@"avatar %@",avatar);
    NSData *imageData = [avatar getData];
    chatView.agentAvatar=[UIImage imageWithData:imageData];
    chatView.userAgent=self.userAgentArr[indexPath.row];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

@end
