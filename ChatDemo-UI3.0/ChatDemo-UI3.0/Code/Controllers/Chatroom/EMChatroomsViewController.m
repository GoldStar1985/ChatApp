/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatroomsViewController.h"
#import "EMGroupCell.h"
#import "EMGroupModel.h"
#import "EMNotificationNames.h"
#import "EMGroupInfoViewController.h"
#import "EMCreateViewController.h"
#import "EMChatViewController.h"

#import "EMChatroomCell.h"
#import "NSObject+EMAlertView.h"

@interface EMChatroomsViewController ()

@end

@implementation EMChatroomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self addNotifications];
    
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)setupNavBar {
    self.title = NSLocalizedString(@"common.chatrooms", @"Chatrooms");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
}

- (void)loadChatroomsFromServer
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChatroomList:) name:KEM_REFRESH_CHATROOMLIST_NOTIFICATION object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEM_REFRESH_CHATROOMLIST_NOTIFICATION object:nil];
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification Method

- (void)refreshChatroomList:(NSNotification *)notification
{
//    NSArray *groupList = [[EMClient sharedClient].roomManager getJoinedGroups];
//    [self.dataArray removeAllObjects];
//    for (EMGroup *group in groupList) {
//        EMGroupModel *model = [[EMGroupModel alloc] initWithObject:group];
//        if (model) {
//            [self.dataArray addObject:model];
//        }
//    }
//    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"EMChatroomCell";
    EMChatroomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMChatroomCell" owner:self options:nil] lastObject];
    }
    
    EMChatroom *chatroom = [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = chatroom.subject;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EMChatroom *chatroom = self.dataArray[indexPath.row];
    EMChatViewController *chatViewController = [[EMChatViewController alloc] initWithConversationId:chatroom.chatroomId conversationType:EMConversationTypeChatRoom];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchChatroomsWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchChatroomsWithPage:self.page isHeader:NO];
}

- (void)fetchChatroomsWithPage:(NSInteger)aPage
                      isHeader:(BOOL)aIsHeader
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EMClient sharedClient].roomManager getChatroomsFromServerWithPage:self.page pageSize:50 completion:^(EMPageResult *aResult, EMError *aError) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        
        if (aError) {
            [self showAlertWithMessage:NSLocalizedString(@"hud.fail", @"Get chatroom list failure.")];
            return ;
        }
        
        if (aIsHeader) {
            [self.dataArray removeAllObjects];
        }
        [weakSelf.dataArray addObjectsFromArray:aResult.list];
        
        if (aResult.count < 50 ) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
        
        [weakSelf.tableView reloadData];
    }];
}

@end
