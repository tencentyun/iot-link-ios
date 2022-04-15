//
//  WCUserManage.m
//  TenextCloud
//
//

#import "TIoTCoreUserManage.h"
#import "NSString+Extension.h"
#import "NSObject+additions.h"

@implementation TIoTCoreUserManage
@synthesize accessToken = _accessToken;
@synthesize expireAt = _expireAt;
@synthesize userId = _userId;
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize phoneNumber = _phoneNumber;

@synthesize countryCode = _countryCode;
@synthesize email = _email;
@synthesize hasPassword = _hasPassword;
@synthesize WxOpenID = _WxOpenID;
@synthesize requestID = _requestID;
@synthesize hasBindWxOpenID = _hasBindWxOpenID;
@synthesize userRegionId = _userRegionId;
@synthesize userRegion = _userRegion;
@synthesize countryTitle = _countryTitle;
@synthesize countryTitleEN = _countryTitleEN;

@synthesize signIn_countryCode = _signIn_countryCode;
@synthesize signIn_Title = _signIn_Title;
@synthesize signIn_Phone_Numner = _signIn_Phone_Numner;
@synthesize signIn_Email_Address = _signIn_Email_Address;

@synthesize login_CountryCode = _login_CountryCode;
@synthesize login_Title = _login_Title;
@synthesize login_Code_Text = _login_Code_Text;

@synthesize FamilyType = _FamilyType;
@synthesize familyId = _familyId;
@synthesize currentRoomId = _currentRoomId;

@synthesize sys_call_status = _sys_call_status;

@synthesize isShowBirthDayView = _isShowBirthDayView;
@synthesize isShowPricyView = _isShowPricyView;
@synthesize isShowPricyWIFIView = _isShowPricyWIFIView;
@synthesize isShowPricyAudioView = _isShowPricyAudioView;
@synthesize isShowPricyWechatView = _isShowPricyWechatView;
@synthesize addDeviceNumber = _addDeviceNumber;

@synthesize searchHistoryArray = _searchHistoryArray;

@synthesize demoAccessID = _demoAccessID;
@synthesize firmwareUpdate = _firmwareUpdate;
@synthesize isRreshDeviceList = _isRreshDeviceList;
@synthesize isVersionUpdateView = _isVersionUpdateView;
@synthesize isChangeBluetoothAuth = _isChangeBluetoothAuth;
@synthesize demoAreaNetProductID = _demoAreaNetProductID;
@synthesize demoAreaNetClientToken = _demoAreaNetClientToken;

+(instancetype)shared{
    static TIoTCoreUserManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

#pragma mark - getter & setter
- (instancetype)init {
    self = [super init];
    _wifiMap = [NSMutableDictionary dictionary];
    return self;
}

- (BOOL)isValidToken
{
    if (self.accessToken && self.expireAt) {
        if (self.accessToken.length > 0 && [self.expireAt integerValue] > [[NSString getNowTimeString] integerValue]) {
            return  YES;
        }
    }
    
    return NO;
}

- (NSString *)accessToken
{
    if (!_accessToken) {
        _accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"acsToken"];
    }
    return _accessToken?:@"";
}

- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    if (accessToken == nil || [accessToken isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"acsToken"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:@"acsToken"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)expireAt
{
    if (!_expireAt) {
        _expireAt = [[NSUserDefaults standardUserDefaults] valueForKey:@"expire_At"];
    }
    return _expireAt;
}

- (void)setExpireAt:(NSString *)expireAt
{
    _expireAt = expireAt;
    [[NSUserDefaults standardUserDefaults] setValue:expireAt forKey:@"expire_At"];
}

- (NSString *)userId
{
    if (!_userId) {
        _userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"u_id"];
    }
    return _userId;
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:@"u_id"];
}

- (NSString *)avatar
{
    if (!_avatar) {
        _avatar = [[NSUserDefaults standardUserDefaults] valueForKey:@"ava_tar"];
    }
    return _avatar;
}

- (void)setAvatar:(NSString *)avatar
{
    _avatar = avatar;
    [[NSUserDefaults standardUserDefaults] setValue:avatar forKey:@"ava_tar"];
}

- (NSString *)nickName
{
    if (!_nickName) {
        _nickName = [[NSUserDefaults standardUserDefaults] valueForKey:@"nick_name"];
    }
    return _nickName;
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    [[NSUserDefaults standardUserDefaults] setValue:nickName forKey:@"nick_name"];
}

- (NSString *)phoneNumber
{
    if (!_phoneNumber) {
        _phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"phone_number"];
    }
    return _phoneNumber;
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    [[NSUserDefaults standardUserDefaults] setValue:phoneNumber forKey:@"phone_number"];
}

- (NSString *)countryCode {
    if (!_countryCode) {
        _countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"country_Code"];
    }
    return _countryCode;
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = countryCode;
    [[NSUserDefaults standardUserDefaults] setValue:countryCode forKey:@"country_Code"];
}

- (NSString *)email {
    if (!_email) {
        _email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email_"];
    }
    return _email;
}

- (void)setEmail:(NSString *)email {
    _email = email;
    [[NSUserDefaults standardUserDefaults] setValue:email forKey:@"email_"];
}

- (NSString *)WxOpenID {
    if (!_WxOpenID) {
        _WxOpenID = [[NSUserDefaults standardUserDefaults] valueForKey:@"WxOpen_ID"];
    }
    return _WxOpenID;
}

- (void)setWxOpenID:(NSString *)WxOpenID {
    _WxOpenID = WxOpenID;
    [[NSUserDefaults standardUserDefaults] setValue:WxOpenID forKey:@"WxOpen_ID"];
}

- (NSString *)hasPassword {
    if (!_hasPassword) {
        _hasPassword = [[NSUserDefaults standardUserDefaults] valueForKey:@"has_Password"];
    }
    return _hasPassword;
}

- (void)setHasPassword:(NSString *)hasPassword {
    _hasPassword = hasPassword;
    [[NSUserDefaults standardUserDefaults] setValue:hasPassword forKey:@"has_Password"];
}

- (NSString *)requestID {
    if (!_requestID) {
        _requestID = [[NSUserDefaults standardUserDefaults] valueForKey:@"request_ID"];
    }
    return _requestID;
}

- (void)setRequestID:(NSString *)requestID {
    _requestID = requestID;
    [[NSUserDefaults standardUserDefaults] setValue:requestID forKey:@"request_ID"];
}

- (NSString *)familyId {
    if (!_familyId) {
        _familyId = [[NSUserDefaults standardUserDefaults] valueForKey:@"familyId"];
    }
    return _familyId;
}

- (void)setFamilyId:(NSString *)familyId {
    _familyId = familyId;
    [[NSUserDefaults standardUserDefaults] setValue:familyId forKey:@"familyId"];
}

- (NSString *)currentRoomId {
    if (!_currentRoomId) {
        _currentRoomId = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentRoomId"];
    }
    if (_currentRoomId.length > 0) {
        return _currentRoomId;
    }
    return @"0";
}

- (void)setSys_call_status:(NSString *)sys_call_status {
    _sys_call_status = sys_call_status;
}

- (NSString *)sys_call_status {
    if ([NSString isNullOrNilWithObject:_sys_call_status]) {
        _sys_call_status = @"-1";
    }
    return _sys_call_status;
    
}

- (void)setCurrentRoomId:(NSString *)currentRoomId {
    _currentRoomId = currentRoomId;
    [[NSUserDefaults standardUserDefaults] setValue:currentRoomId forKey:@"currentRoomId"];
}

//保存accessToken
- (void)saveAccessToken:(NSString *)accessToken expireAt:(NSString *)expireAt{
    self.accessToken = [NSString stringWithFormat:@"%@",accessToken];
    self.expireAt = [NSString stringWithFormat:@"%@",expireAt];
}

-(NSString *)hasBindWxOpenID {
    if (!_hasBindWxOpenID) {
        _hasBindWxOpenID = [[NSUserDefaults standardUserDefaults] valueForKey:@"Has_WxOpenID"];
    }
    return _hasBindWxOpenID;
}

- (void)setHasWxOpenID:(NSString *)hasBindWxOpenID {
    _hasBindWxOpenID = hasBindWxOpenID;
    [[NSUserDefaults standardUserDefaults] setValue:hasBindWxOpenID forKey:@"Has_WxOpenID"];
}

//@property (nonatomic, copy, nullable) NSString *RegionId;           // 22 美东  1 国内
//@property (nonatomic, copy, nullable) NSString *region;             // 美东 na-ashburn 国内 ap-guangzhou

- (NSString *)userRegionId {
    if (!_userRegionId) {
        _userRegionId = [[NSUserDefaults standardUserDefaults] valueForKey:@"Region_Id"];
    }
    
    if ([NSString isNullOrNilWithObject:_userRegionId]) {
        _userRegionId = @"";
    }
    return _userRegionId;
}

- (void)setUserRegionId:(NSString *)userRegionId {
    _userRegionId = userRegionId;
    [[NSUserDefaults standardUserDefaults] setValue:userRegionId forKey:@"Region_Id"];
}

- (NSString *)userRegion {
    if (!_userRegion) {
        _userRegion = [[NSUserDefaults standardUserDefaults] valueForKey:@"region"];
    }
    if ([NSString isNullOrNilWithObject:_userRegion]) {
        _userRegion = @"ap-guangzhou";
    }
    return _userRegion;
}

- (void)setUserRegion:(NSString *)userRegion {
    _userRegion = userRegion;
    [[NSUserDefaults standardUserDefaults] setValue:userRegion forKey:@"region"];
}

- (NSString *)countryTitle {
    if (!_countryTitle) {
        _countryTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"country_Title"];
    }
    if ([NSString isNullOrNilWithObject:_countryTitle]) {
        _countryTitle = NSLocalizedString(@"china_main_land", @"中国大陆");
    }
    return _countryTitle;
}

- (void)setCountryTitle:(NSString *)countryTitle {
    _countryTitle = countryTitle;
    [[NSUserDefaults standardUserDefaults] setValue:countryTitle forKey:@"country_Title"];
}

- (NSString *)countryTitleEN {
    if (!_countryTitleEN) {
        _countryTitleEN = [[NSUserDefaults standardUserDefaults] valueForKey:@"country_TitleEN"];
    }
    if ([NSString isNullOrNilWithObject:_countryTitleEN]) {
        _countryTitleEN = @"Chinese Mainland";
    }
    return _countryTitleEN;
}

- (void)setCountryTitleEN:(NSString *)countryTitleEN {
    _countryTitleEN = countryTitleEN;
    [[NSUserDefaults standardUserDefaults] setValue:countryTitleEN forKey:@"country_TitleEN"];
}

#pragma mark - 固件升级
- (NSString *)firmwareUpdate
{
    if (!_firmwareUpdate) {
        _firmwareUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:@"firmware_Update"];
    }
    return _firmwareUpdate;
}

- (void)setFirmwareUpdate:(NSString *)firmwareUpdate {
    _firmwareUpdate = firmwareUpdate;
    [[NSUserDefaults standardUserDefaults] setValue:firmwareUpdate forKey:@"firmware_Update"];
}

#pragma mark - 生日日期

- (NSString *)isShowBirthDayView {
    if (!_isShowBirthDayView) {
        _isShowBirthDayView = [[NSUserDefaults standardUserDefaults] valueForKey:@"isShowBirthDayView"];
    }
    return _isShowBirthDayView;
}

- (void)setIsShowBirthDayView:(NSString *)isShowBirthDayView {
    _isShowBirthDayView = isShowBirthDayView;
    [[NSUserDefaults standardUserDefaults] setValue:isShowBirthDayView forKey:@"isShowBirthDayView"];
}

#pragma mark - 从添加设备页面返回首页后，是否刷新列表

- (NSString *)isRreshDeviceList {
    if (!_isRreshDeviceList) {
        _isRreshDeviceList = [[NSUserDefaults standardUserDefaults] valueForKey:@"isRreshDeviceList"];
    }
    return _isRreshDeviceList;
}

- (void)setIsRreshDeviceList:(NSString *)isRreshDeviceList {
    _isRreshDeviceList = isRreshDeviceList;
    [[NSUserDefaults standardUserDefaults] setValue:isRreshDeviceList forKey:@"isRreshDeviceList"];
}
#pragma mark - 注册隐私弹框

- (NSString *)isShowPricyView {
    if (!_isShowPricyView) {
        _isShowPricyView = [[NSUserDefaults standardUserDefaults] valueForKey:@"isShowPricyView"];
    }
    return _isShowPricyView;
}

- (void)setIsShowPricyView:(NSString *)isShowPricyView {
    _isShowPricyView = isShowPricyView;
    [[NSUserDefaults standardUserDefaults] setValue:isShowPricyView forKey:@"isShowPricyView"];
}

#pragma mark - 注册隐私弹框
- (NSString *)isShowPricyWIFIView {
    if (!_isShowPricyWIFIView) {
        _isShowPricyWIFIView = [[NSUserDefaults standardUserDefaults] valueForKey:@"isShowPricyWIFIView"];
    }
    return _isShowPricyWIFIView;
}

- (void)setIsShowPricyWIFIView:(NSString *)isShowPricyWIFIView {
    _isShowPricyWIFIView = isShowPricyWIFIView;
    [[NSUserDefaults standardUserDefaults] setValue:isShowPricyWIFIView forKey:@"isShowPricyWIFIView"];
}

#pragma mark - 注册隐私弹框

- (NSString *)isShowPricyAudioView {
    if (!_isShowPricyAudioView) {
        _isShowPricyAudioView = [[NSUserDefaults standardUserDefaults] valueForKey:@"isShowPricyAudioView"];
    }
    return _isShowPricyAudioView;
}

- (void)setIsShowPricyAudioView:(NSString *)isShowPricyAudioView {
    _isShowPricyAudioView = isShowPricyAudioView;
    [[NSUserDefaults standardUserDefaults] setValue:isShowPricyAudioView forKey:@"isShowPricyAudioView"];
}

#pragma mark - 注册隐私弹框

- (NSString *)isShowPricyWechatView {
    if (!_isShowPricyWechatView) {
        _isShowPricyWechatView = [[NSUserDefaults standardUserDefaults] valueForKey:@"isShowPricyWechatView"];
    }
    return _isShowPricyWechatView;
}

- (void)setIsShowPricyWechatView:(NSString *)isShowPricyWechatView {
    _isShowPricyWechatView = isShowPricyWechatView;
    [[NSUserDefaults standardUserDefaults] setValue:isShowPricyWechatView forKey:@"isShowPricyWechatView"];
}

#pragma mark - 首次进入，合规整改更新提示
- (NSString *)isVersionUpdateView {
    if (!_isVersionUpdateView) {
        _isVersionUpdateView = [[NSUserDefaults standardUserDefaults] valueForKey:@"isVersionUpdateView"];
    }
    return _isVersionUpdateView;
}

- (void)setIsVersionUpdateView:(NSString *)isVersionUpdateView {
    _isVersionUpdateView = isVersionUpdateView;
    [[NSUserDefaults standardUserDefaults] setValue:isVersionUpdateView forKey:@"isVersionUpdateView"];
}

#pragma mark - 首次进入APP 添加设备数量

- (NSString *)addDeviceNumber {
    if (!_addDeviceNumber) {
        _addDeviceNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"addDeviceNumber"];
    }
    return _addDeviceNumber;
}

- (void)setAddDeviceNumber:(NSString *)addDeviceNumber {
    _addDeviceNumber = addDeviceNumber;
    [[NSUserDefaults standardUserDefaults] setValue:addDeviceNumber forKey:@"addDeviceNumber"];
}

#pragma mark - 注册页面用户操作保存项
- (NSString *)signIn_countryCode {
    if (!_signIn_countryCode) {
        _signIn_countryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_countryCode"];
    }
    return _signIn_countryCode;
}

- (void)setsignIn_countryCode:(NSString *)signIn_countryCode {
    _signIn_countryCode = signIn_countryCode;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_countryCode forKey:@"signIn_countryCode"];
}

- (NSString *)signIn_Title {
    if (!_signIn_Title) {
        _signIn_Title = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Title"];
    }
    return _signIn_Title;
}

- (void)setsignIn_Title:(NSString *)signIn_Title {
    _signIn_Title = signIn_Title;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_Title forKey:@"signIn_Title"];
}

- (NSString *)signIn_Phone_Numner {
    if (!_signIn_Phone_Numner) {
        _signIn_Phone_Numner = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Phone_Numner"];
    }
    return _signIn_Phone_Numner;
}

- (void)setSignIn_Phone_Numner:(NSString *)signIn_Phone_Numner {
    _signIn_Phone_Numner = signIn_Phone_Numner;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_Phone_Numner forKey:@"signIn_Phone_Numner"];
}

- (NSString *)signIn_Email_Address {
    if (!_signIn_Email_Address) {
        _signIn_Email_Address = [[NSUserDefaults standardUserDefaults] valueForKey:@"signIn_Email_Address"];
    }
    return _signIn_Email_Address;
}

- (void)setSignIn_Email_Address:(NSString *)signIn_Email_Address {
    _signIn_Email_Address = signIn_Email_Address;
    [[NSUserDefaults standardUserDefaults] setValue:signIn_Email_Address forKey:@"signIn_Email_Address"];
}

#pragma mark - 是否更改过蓝牙权限

- (NSString *)isChangeBluetoothAuth {
    if (!_isChangeBluetoothAuth) {
        _isChangeBluetoothAuth = [[NSUserDefaults standardUserDefaults] valueForKey:@"is_ChangeBluetooth_Auth"];
    }
    return _isChangeBluetoothAuth;
}

- (void)setIsChangeBluetoothAuth:(NSString *)isChangeBluetoothAuth {
    _isChangeBluetoothAuth = isChangeBluetoothAuth;
    [[NSUserDefaults standardUserDefaults] setValue:isChangeBluetoothAuth forKey:@"is_ChangeBluetooth_Auth"];
}

#pragma mark - 地图搜索
- (void)setSearchHistoryArray:(NSMutableArray *)searchHistoryArray {
    _searchHistoryArray = searchHistoryArray;
    [[NSUserDefaults standardUserDefaults] setValue:searchHistoryArray forKey:@"search_historyArray"];
}

- (NSMutableArray *)searchHistoryArray {
    if (!_searchHistoryArray) {
        _searchHistoryArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"search_historyArray"];
    }
    return _searchHistoryArray;
}

#pragma mark - 登录页 用户操作保存项
- (NSString *)login_CountryCode {
    if (!_login_CountryCode) {
        _login_CountryCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_CountryCode"];
    }
    return _login_CountryCode;
}

- (void)setlogin_CountryCode:(NSString *)login_CountryCode {
    _login_CountryCode = login_CountryCode;
    [[NSUserDefaults standardUserDefaults] setValue:login_CountryCode forKey:@"login_CountryCode"];
}

- (NSString *)login_Title {
    if (!_login_Title) {
        _login_Title = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_Title"];
    }
    return _login_Title;
}

- (void)setlogin_Title:(NSString *)login_Title {
    _login_Title = login_Title;
    [[NSUserDefaults standardUserDefaults] setValue:login_Title forKey:@"login_Title"];
}

- (NSString *)login_Code_Text {
    if (!_login_Code_Text) {
        _login_Code_Text = [[NSUserDefaults standardUserDefaults] valueForKey:@"login_Code_Text"];
    }
    return _login_Code_Text;
}

- (void)setlogin_Code_Text:(NSString *)login_Code_Text {
    _login_Code_Text = login_Code_Text;
    [[NSUserDefaults standardUserDefaults] setValue:login_Code_Text forKey:@"login_Code_Text"];
}

- (NSInteger )FamilyType {
    if (!_FamilyType) {
        _FamilyType = [[[NSUserDefaults standardUserDefaults] valueForKey:@"FamilyType"] intValue];
    }
    return _FamilyType;
}

- (void)setFamilyType:(NSInteger)FamilyType {
    _FamilyType = FamilyType;
    [[NSUserDefaults standardUserDefaults] setValue:@(FamilyType) forKey:@"FamilyType"];
}

#pragma mark - SDKDemo

- (NSString *)demoAccessID {
    if (!_demoAccessID) {
        _demoAccessID = [[NSUserDefaults standardUserDefaults] valueForKey:@"demoAccessID"];
    }
    return _demoAccessID;
}

- (void)setDemoAccessID:(NSString *)demoAccessID {
    _demoAccessID = demoAccessID;
    [[NSUserDefaults standardUserDefaults] setValue:demoAccessID forKey:@"demoAccessID"];
}

- (NSString *)demoAreaNetProductID {
    if (!_demoAreaNetProductID) {
        _demoAreaNetProductID = [[NSUserDefaults standardUserDefaults] valueForKey:@"demoAreaNetProductID"];
    }
    return _demoAreaNetProductID;
}

- (void)setDemoAreaNetProductID:(NSString *)demoAreaNetProductID {
    _demoAreaNetProductID = demoAreaNetProductID;
    [[NSUserDefaults standardUserDefaults] setValue:demoAreaNetProductID forKey:@"demoAreaNetProductID"];
}

- (NSString *)demoAreaNetClientToken {
    if (!_demoAreaNetClientToken) {
        _demoAreaNetClientToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"demoAreaNetClientToken"];
    }
    return _demoAreaNetClientToken;
}

- (void)setDemoAreaNetClientToken:(NSString *)demoAreaNetClientToken {
    _demoAreaNetClientToken = demoAreaNetClientToken;
    [[NSUserDefaults standardUserDefaults] setValue:demoAreaNetClientToken forKey:@"demoAreaNetClientToken"];
}

//保存用户信息
- (void)saveUserInfo:(NSDictionary *)userInfo{
    
    if (userInfo[@"UserID"]) {
        self.userId = userInfo[@"UserID"];
    }
    if (userInfo[@"Avatar"]) {
        self.avatar = userInfo[@"Avatar"];
    }
    if (userInfo[@"NickName"]) {
        self.nickName = userInfo[@"NickName"];
    }
    if (userInfo[@"PhoneNumber"]) {
        self.phoneNumber = userInfo[@"PhoneNumber"];
    }
    if (userInfo[@"Email"]) {
        self.email = userInfo[@"Email"];
    }
    if (userInfo[@"HasPassword"]) {
        self.hasPassword = [NSString stringWithFormat:@"%@",userInfo[@"HasPassword"]];
    }
    if (userInfo[@"CountryCode"]) {
        self.countryCode = userInfo[@"CountryCode"];
    }
    if (userInfo[@"WxOpenID"]) {
        self.WxOpenID = userInfo[@"WxOpenID"];
    }
    if (userInfo[@"RequestId"]) {
        self.requestID = userInfo[@"RequestId"];
    }
    if (userInfo[@"Openid"]) {
        self.WxOpenID = userInfo[@"Openid"];
    }
    if (userInfo[@"HasWxOpenID"]) {
        self.hasWxOpenID = [NSString stringWithFormat:@"%@",userInfo[@"HasWxOpenID"]];
    }
    if (userInfo[@"RegionID"]) {
        self.userRegionId = [NSString stringWithFormat:@"%@",userInfo[@"RegionID"]];
    }
    if (userInfo[@"Region"]) {
        self.userRegion = userInfo[@"Region"];
    }
    if (userInfo[@"Title"]) {
        self.countryTitle = userInfo[@"Title"];
    }
    if (userInfo[@"TitleEN"]) {
        self.countryTitleEN = userInfo[@"TitleEN"];
    }
}

- (void)clear{
    self.accessToken = @"";
    self.userId = @"";
    self.nickName = @"";
    self.avatar = @"";
    self.phoneNumber = @"";
    self.expireAt = @"";
    self.countryCode = @"";
    self.email = @"";
    self.hasPassword = @"";
    self.WxOpenID = @"";
    self.requestID = @"";
    self.hasBindWxOpenID = @"";
    self.userRegionId = @"";
    self.userRegion = @"";
    self.countryTitle = @"";
    self.countryTitleEN = @"";
    self.FamilyType = 0;
    self.firmwareUpdate = @"";
    self.demoAreaNetProductID = @"";
    self.demoAreaNetClientToken = @"";
}

- (void)signInClear {
    self.signIn_countryCode = @"";
    self.signIn_Title = @"";
    self.signIn_Phone_Numner = @"";
    self.signIn_Email_Address = @"";
    self.demoAreaNetProductID = @"";
    self.demoAreaNetClientToken = @"";
}

@end
