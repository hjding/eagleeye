//
//  ViewController.m
//  OwnerVehiclesQuery
//
//  Created by Ding on 15-2-4.
//  Copyright (c) 2015年 hjd. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "PullRefreshTableView.h"
#import <AVOSCloud/AVOSCloud.h>
#import "Reachability.h"

#define kFontSize               14.0f
#define kCellHeight             48.0f

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,PullRefreshTableViewDelegate>
{
    PullRefreshTableView    *pullRefreshTableView;
    
    BOOL                    isOffLine;
}

//数据
@property(nonatomic,retain) UITableView     *tableView;
@property(nonatomic,retain) NSMutableArray  *tableData;

//搜索
@property(nonatomic,retain) UISearchBar     *searchBar;
@property(nonatomic,retain) NSMutableArray  *searchData;
@property(nonatomic,retain) UIView          *shadowView;
@property(nonatomic,retain) UILabel         *blankView;

@end

@implementation ViewController

#pragma mark - Init Method
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.title=@"车辆查询";
        
        self.tableData=[[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - LifeCycle Method
-(void)loadView{
//    self.view=[[UIView alloc] initWithFrame:CGRectMake(0,0,kDeviceWidth,kDeviceHeight-kTopStatusBarHeight-kNavigationBarHeight)];
    self.view=[[UIView alloc] initWithFrame:CGRectMake(0,0,kDeviceWidth,kDeviceHeight)];
    self.view.backgroundColor=kHomeBg;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self judgeNetwrok];
    
    [self initUI];
    
    if (isOffLine) {
        [Helper showHintMessage:kOffLineMode];
        [self initLocalData];
        [self.tableView reloadData];
    }
    else{
        [Helper showHintMessage:kRealTimeMode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Privite Method

-(void)judgeNetwrok{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            NSLog(@"没有网络连接");
            isOffLine=YES;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            NSLog(@"使用3G网络");
            isOffLine=NO;
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            NSLog(@"使用WiFi网络");
            isOffLine=NO;
            break;
    }
}

-(void)initUI{
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.width, self.view.height) style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    //下拉刷新
    pullRefreshTableView=[[PullRefreshTableView alloc] initWithTableView:_tableView delegate:self];
//    [pullRefreshTableView addTableHeaderView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kSearchBarHeight)];
    self.searchBar.placeholder = @"搜索(车主/车牌)";
    self.searchBar.autocapitalizationType = NO;
    self.searchBar.backgroundImage = [Helper createImageWithColor:[UIColor whiteColor] andRect:self.searchBar.frame];
    self.searchBar.delegate = self;
    self.searchBar.returnKeyType = UIReturnKeyDone;
    self.tableView.tableHeaderView=self.searchBar;
    //    [self.view addSubview:self.searchBar];
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.frame =CGRectMake(self.tableView.left,self.searchBar.height, self.tableView.width, self.tableView.height-self.searchBar.height);
    self.shadowView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    self.shadowView.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.shadowView addGestureRecognizer:tap];
    [self.view addSubview:self.shadowView];
    
    self.blankView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.width, 30)];
    self.blankView.text = @"未找到相应的车主/车牌";
    self.blankView.textColor = kWordsDetailColor;
    self.blankView.textAlignment = NSTextAlignmentCenter;
    self.blankView.font = [UIFont systemFontOfSize:kFontSize];
    self.blankView.alpha=0;
    [self.view addSubview:self.blankView];
}

-(void)initLocalData{
    self.tableData=[self queryLocalData];
}

-(void)searchWithChineseCharacter:(NSString *)searchText{
//    [self initLocalData];
    self.searchData=[[NSMutableArray alloc] init];
    //搜索
    if(searchText.length!=0){
        //遍历数组,搜索车主/车牌
        for(int i=0;i<self.tableData.count;i++){
            NSDictionary *dic_info=self.tableData[i];
            NSString *str_name=dic_info[@"name"];
            NSString *str_plateNumber=dic_info[@"plateNumber"];
            
            if([str_name rangeOfString:searchText options:NSCaseInsensitiveSearch].location!= NSNotFound||[str_plateNumber rangeOfString:searchText options:NSCaseInsensitiveSearch].location!= NSNotFound){
                [self.searchData addObject:self.tableData[i]];
            }
        }
        //搜索到结果
        if (self.searchData.count!=0){
            self.blankView.alpha=0.0f;
        }
        //未搜索到结果
        else{
            self.blankView.alpha = 1.0f;
        }
        self.tableData=self.searchData;
        [self hideShadowView];
    }
    //未输入任何字符
    else{
        
        [self showShadowView];
        self.blankView.alpha=0.0f;
    }
    [self.tableView reloadData];
}

-(void)refreshData{
    AVQuery *query=[AVQuery queryWithClassName:@"user"];
    [query setLimit:10];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSLog(@"%@",[NSString stringWithFormat:@"查询结果: \n%@", [objects description]]);
        }else{
            NSLog(@"%@",[NSString stringWithFormat:@"查询结果: \n%@", [error description]]);
        }
    }];
}

#pragma mark - FMDB
//创建表
-(void)createLocalTable{
    
    NSString *dbPath=kLocalDatabasePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:dbPath]==NO){
        //创建数据库
        FMDatabase *db=[FMDatabase databaseWithPath:dbPath];
        if ([db open]){
            //创建表
            NSString *sql=@"CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL , 'name' VARCHAR(30), 'telephone' VARCHAR(11), 'plateNumber' VARCHAR(10))";
            BOOL res=[db executeUpdate:sql];
            if(!res){
                NSLog(@"创建表失败");
            }
            else{
                NSLog(@"创建表成功");
            }
            [db close];
        }
        else{
            NSLog(@"打开数据库失败");
        }
    }
    else{
        NSLog(@"数据库已存在");
    }
    
}

//查询数据
-(NSMutableArray *)queryLocalData{
    NSString *dbPath=kLocalDatabasePath;
    NSMutableArray *muarr_data=[[NSMutableArray alloc] init];
    FMDatabase *db=[FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSString *sql=@"select * from user";
        FMResultSet *res=[db executeQuery:sql];
        while (res.next) {
            NSString *name=[res stringForColumn:@"name"];
            NSString *telephone=[res stringForColumn:@"telephone"];
            NSString *plateNumber=[res stringForColumn:@"plateNumber"];
            NSDictionary *dic_info=@{@"name":name,@"telephone":telephone,@"plateNumber":plateNumber};
            [muarr_data addObject:dic_info];
        }
        [db close];
    }
    return muarr_data;
}

//插入数据
-(void)insertLocalData{
    
    NSString *dbPath=kLocalDatabasePath;
    FMDatabase *db=[FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSString *sql=@"insert into user(name,telephone,plateNumber) values(?,?,?)";
        for (int i=0; i<10; i++) {
            NSString *name=[NSString stringWithFormat:@"黄%i",10000+i];
            NSString *telephone=[NSString stringWithFormat:@"%lld",15271840000+i];
            NSString *plateNumber=[NSString stringWithFormat:@"鄂A-%i",60000+i];
            BOOL res=[db executeUpdate:sql,name,telephone,plateNumber];
            if(!res){
                NSLog(@"插入数据失败");
            }
        }
        [db close];
    }
}

#pragma mark - Pull Down and Up Refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullRefreshTableView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshTableView scrollViewDidEndDragging];
}

-(void)beginRefresh{
    NSLog(@"正在请求数据...");
    
    [self refreshData];
    
    if (pullRefreshTableView.isRefreshing){
        //结束下拉刷新
        [pullRefreshTableView finishRefresh];
    }
}

-(void)loadMore{

}

#pragma mark - TableView Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //移去所有的子视图
    [cell.contentView removeAllSubviews];
    NSDictionary *dic_info=self.tableData[indexPath.row];
    //车主&手机
    NSString *str_name=dic_info[@"name"];
    NSString *str_telephone=dic_info[@"telephone"];
    NSString *str_plateNumber=dic_info[@"plateNumber"];
    UILabel *lb_info=[[UILabel alloc] initWithFrame:CGRectMake(5, 0,self.tableView.width-5*2, cell.contentView.height)];
    lb_info.text=[NSString stringWithFormat:@"%@(%@)            %@",str_name,str_plateNumber,str_telephone];
    lb_info.font=[UIFont systemFontOfSize:14.0f];
    [cell.contentView addSubview:lb_info];
    
    if (indexPath.row==0) {
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.width, 1)];
        line.backgroundColor=kWordsDetailColor;
        line.alpha=0.2;
        [cell.contentView addSubview:line];
    }
    
    CGFloat h=25;
    UIButton *bt_telephone=[UIButton buttonWithType:UIButtonTypeCustom];
    bt_telephone.frame=CGRectMake(cell.width-h-8, kCellHeight/2-h/2,h, h);
    UIImage *image_telephone=[UIImage imageNamed:@"ic_action_phone_start"];
    [bt_telephone setImage:image_telephone forState:UIControlStateNormal];
    [bt_telephone addTarget:self action:@selector(bt_telephonePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:bt_telephone];
    
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, kCellHeight-1, cell.width, 1)];
    line.backgroundColor=kWordsDetailColor;
    line.alpha=0.2;
    [cell.contentView addSubview:line];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Target Method
- (void)hideKeyboard
{
    if ([self.searchBar isFirstResponder])
        [self.searchBar resignFirstResponder];
    
    [self hideShadowView];
}

-(void)hideShadowView
{
    self.shadowView.alpha = 0.f;
}

-(void)showShadowView
{
    self.shadowView.alpha = 1.f;
}

-(void)bt_telephonePressed:(id)sender{
    //找到事件源
    UITableViewCell *cell=(UITableViewCell*)[[sender superview] superview];
    if (cell!=nil){
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        NSDictionary *dic_info=self.tableData[cellIndexPath.row];
        NSString *telephone=dic_info[@"telephone"];
        NSString *str_deviceName=[UIDevice currentDevice].name;
        //模拟器
        if ([str_deviceName isEqualToString:kIPhoneSimulator]) {
            [Helper showAlertViewWithTitle:@"模拟拨打电话" andMessage:telephone];
        }
        //真机
        else{
            NSString *str_url=[NSString stringWithFormat:@"tel://%@",telephone];
            NSURL *url=[NSURL URLWithString:str_url];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark - SearchBar Method
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.shadowView.alpha = 1;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    [self reviseDataWithSearchText:searchText];
    NSLog(@"%@",searchText);
    if (isOffLine) {
        [self searchWithChineseCharacter:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideKeyboard];
    if (!isOffLine) {
        NSLog(@"正在搜索数据");
        [self queryOnlineData:searchBar.text];
    }
}

#pragma mark - AVOS 
-(void)queryOnlineData:(NSString *)searchText{
    
//    select * from GameScore where name like 'dennis%'
//    select * from GameScore where name regexp 'dennis.*'
    
//    AVQuery *query=[AVQuery queryWithClassName:@"user"];
//    [query whereKey:@"name" hasPrefix:searchText];
//    [query whereKey:@"name" hasSuffix:searchText];
//    [query whereKey:@"plateNumber" hasPrefix:searchText];
//    [query whereKey:@"plateNumber" hasSuffix:searchText];
//    [query setLimit:20];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (objects) {
//            NSLog(@"%@",[NSString stringWithFormat:@"查询结果: \n%@", [objects description]]);
//        }else{
//            NSLog(@"%@",[NSString stringWithFormat:@"查询结果: \n%@", [error description]]);
//        }
//    }];
    
//    NSString *cql = [NSString stringWithFormat:@"select * from user where name like '%%%@%%'",searchText];
//    NSArray *pvalues = nil;
//    [AVQuery doCloudQueryInBackgroundWithCQL:cql pvalues:pvalues callback:^(AVCloudQueryResult *result, NSError *error) {
//        if (!error) {
//            // 操作成功
//            NSArray *arr=[result results];
//            NSLog(@"%@",[NSString stringWithFormat:@"查询结果: \n%@", [arr description]]);
//        } else {
//            NSLog(@"%@", error);
//        }
//    }];
    
    NSString *str_query=[Helper getSplitString:searchText With:@"*"];
    
    AVSearchQuery *searchQuery = [AVSearchQuery searchWithQueryString:str_query];
    searchQuery.className = @"user";
//    searchQuery.highlights = @"field1,field2";
    searchQuery.limit = 10;
    searchQuery.cachePolicy = kAVCachePolicyCacheElseNetwork;
    searchQuery.maxCacheAge = 60;
    searchQuery.fields = @[@"name", @"plateNumber",@"telephone"];
    [searchQuery findInBackground:^(NSArray *objects, NSError *error) {
        if (error==nil) {
            NSMutableArray *muarr_data=[[NSMutableArray alloc]init];
            for (AVObject *object in objects) {
                NSString *name = [object objectForKey:@"name"];
                NSString *plateNumber = [object objectForKey:@"plateNumber"];
                NSString *telephone = [object objectForKey:@"telephone"];
                NSDictionary *dic_info=@{@"name":name,@"telephone":telephone,@"plateNumber":plateNumber};
                [muarr_data addObject:dic_info];
            }
            self.tableData=muarr_data;
            [self.tableView reloadData];
//            self.searchBar.text=@"";
        }
        else{
            NSLog(@"%@",error);
        }
    }];
}

@end
