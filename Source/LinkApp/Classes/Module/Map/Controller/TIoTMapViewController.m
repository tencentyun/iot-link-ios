//
//  TIoTMapViewController.m

#import "TIoTMapViewController.h"
#import <QMapKit/QMSSearchOption.h>
#import <QMapKit/QMSSearcher.h>
#import <QMapKit/QMSSearchServices.h>
#import "TIoTChooseLocationCell.h"

@interface TIoTMapViewController () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate, QMSSearchDelegate>
@property (nonatomic, strong) QMSSearcher *mySearcher;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation TIoTMapViewController

- (void)handleTestAction
{
//    self.mapView.mapType = self.mapView.mapType == QMapTypeStandard ? QMapTypeDark : QMapTypeStandard;
    
    QMSReverseGeoCodeSearchOption *revGeoOption = [[QMSReverseGeoCodeSearchOption alloc] init];

    [revGeoOption setLocationWithCenterCoordinate:CLLocationCoordinate2DMake(39.939791, 116.444579)];

    [revGeoOption setGet_poi:YES];

    revGeoOption.poi_options = @"radius=5000;page_size=20;page_index=1";

    [self.mySearcher searchWithReverseGeoCodeSearchOption:revGeoOption];
}

- (NSString *)testTitle
{
    return @"";
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [QMapServices sharedServices].APIKey = @"XXX";
    [[QMSSearchServices sharedServices] setApiKey:@"XXX"];
    
    self.mySearcher = [[QMSSearcher alloc] initWithDelegate:self];
    self.mapView.showsCompass = YES;
    
    [self setupView];
}

- (void)setupView {
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark -QMSSearchDelegate
- (void)searchWithReverseGeoCodeSearchOption:(QMSReverseGeoCodeSearchOption *)reverseGeoCodeSearchOption didReceiveResult:(QMSReverseGeoCodeSearchResult *)reverseGeoCodeSearchResult {
    NSLog(@"pois--->%@", reverseGeoCodeSearchResult);
}

- (void)searchWithSearchOption:(QMSSearchOption *)searchOption didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

#pragma mark - TableViewDalegate and TableViewDataSource
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TIoTChooseLocationCell *cell = [TIoTChooseLocationCell cellWithTableView:tableView];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}


#pragma mark - Lazy Loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 80;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

@end
