//
//  TRTCCallingVideoViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Masonry
import MBProgressHUD

private let kSmallVideoViewWidth: CGFloat = 100.0

@objc public enum VideoCallingState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

class VideoCallingRenderView: UIView {
    
    private var isViewReady: Bool = false
    
    var userModel = CallingUserModel() {
        didSet {
            configModel(model: userModel)
        }
    }
    
    lazy var cellImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
        let user = UILabel()
        user.textColor = .white
        user.backgroundColor = UIColor.clear
        user.textAlignment = .center
        user.font = UIFont.systemFont(ofSize: 11)
        user.numberOfLines = 2
        return user
    }()
    
    let volumeProgress: UIProgressView = {
        let progress = UIProgressView.init()
        progress.backgroundColor = .clear
        return progress
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        addSubview(cellImgView)
        cellImgView.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.width.height()?.mas_equalTo()(40)
            make?.centerX.equalTo()(self)
            make?.centerY.equalTo()(self)?.setOffset(-20)
        }
        addSubview(cellUserLabel)
        cellUserLabel.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.leading.trailing()?.equalTo()(self)
            make?.height.mas_equalTo()(22)
            make?.top.equalTo()(cellImgView.mas_bottom)?.setOffset(2)
        }
        
        addSubview(volumeProgress)
        volumeProgress.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.leading.trailing()?.bottom()?.equalTo()(superview)
            make?.height.mas_equalTo()(4)
        }
    }
    
    func configModel(model: CallingUserModel) {
        backgroundColor = .darkGray
        let noModel = model.userId.count == 0
        if !noModel {
            cellUserLabel.text = model.name
            cellImgView.sd_setImage(with: URL(string: model.avatarUrl), completed: nil)
            cellImgView.isHidden = model.isVideoAvaliable
            cellUserLabel.isHidden = model.isVideoAvaliable
            volumeProgress.progress = model.volume
        }
        volumeProgress.isHidden = noModel
    }
}

@objc protocol TRTCCallingViewDelegate {

    @objc func didAcceptJoinRoom()
}


class TRTCCallingVideoViewController: UIViewController, CallingViewControllerResponder {
    lazy var userList: [CallingUserModel] = []
    
    /// 需要展示的用户列表
    var avaliableList: [CallingUserModel] {
        get {
//            return userList.filter { //如果需要屏蔽视频不可获得的用户，就可以替换成这个返回值
//                $0.isVideoAvaliable == true
//            }
            return userList.filter {
                $0.isEnter == true
            }
        }
    }
    
    @objc weak var actionDelegate: TRTCCallingViewDelegate?
    
    var dismissBlock: (()->Void)? = nil
    
    // 麦克风和听筒状态记录
    private var isMicMute = false // 默认开启麦克风
    private var isHandsFreeOn = true // 默认开启扬声器
    
    var invite = UILabel()
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
//    let disposebag = DisposeBag()
    var curSponsor: CallingUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    let localPreView = VideoCallingRenderView.init()
    static var renderViews:VideoCallingRenderView? = VideoCallingRenderView.init()
    
    @objc var deviceName: String = ""
    
    var curState: VideoCallingState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var collectionCount: Int {
        get {
            var count = ((avaliableList.count <= 4) ? avaliableList.count : 9)
            if curState == .onInvitee || curState == .dailing {
                count = 0
            }
            return count
        }
    }
    
    lazy var sponsorPanel: UIView = {
       let panel = UIView()
        panel.backgroundColor = .clear
        return panel
    }()
    
    init(sponsor: CallingUserModel? = nil) {
        curSponsor = sponsor
        if let _ = sponsor {
            curState = .onInvitee
        } else {
            curState = .dailing
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc init(ocUserID: String? = nil) {
        curSponsor = CallingUserModel(avatarUrl: "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png",
                                      name: self.deviceName,
                                      userId: ocUserID ?? "0",
                                      isEnter: false,
                                      isVideoAvaliable: false,
                                      volume: 0.0)
        
        if let _ = ocUserID {
            curState = .onInvitee
        } else {
//            curSponsor = nil
            curState = .dailing
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        curSponsor = nil
        curState = .dailing
//        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TRTCCalling.shareInstance().closeCamara()
//        TRTCCallingVideoViewController.renderViews = nil
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit \(self)")
    }
    
    lazy var userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let user = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width),
                                    collectionViewLayout: layout)
        user.register(VideoCallUserCell.classForCoder(), forCellWithReuseIdentifier: "VideoCallUserCell")
        if #available(iOS 10.0, *) {
            user.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        user.showsVerticalScrollIndicator = false
        user.showsHorizontalScrollIndicator = false
        user.contentMode = .scaleToFill
        user.backgroundColor = .appBackGround
        user.dataSource = self
        user.delegate = self
        return user
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupUI()
        
        
        let list:[CallingUserModel] = [CallingUserModel(avatarUrl: "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png",
                                                        name: "0",
                                                        userId: "0",
                                                        isEnter: false,
                                                        isVideoAvaliable: false,
                                                        volume: 0.0)];
        self.resetWithUserList(users: list, isInit: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    func getUserById(userId: String) -> CallingUserModel? {
        for user in userList {
            if user.userId == userId {
                return user
            }
        }
        return nil
    }
    
    func disMiss() {
        if self.curState != .calling {
            if !codeTimer.isCancelled {
                self.codeTimer.resume()
            }
        }
        self.codeTimer.cancel()
        dismiss(animated: false) {
            if let dis = self.dismissBlock {
                dis()
            }
            
            TRTCCalling.shareInstance().hangup()
            TRTCCalling.shareInstance().closeCamara()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    static func getRenderView(userId: String) -> VideoCallingRenderView? {
        return renderViews;
    }
    
    @objc func beHungUp () {
        invite.text = "对方已挂断..."
    }
}

extension TRTCCallingVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    
    func resetWithUserList(users: [CallingUserModel], isInit: Bool = false) {
        resetUserList()
        if !isInit {
           reloadData()
        }
    }
    
    func resetUserList() {
        if let sponsor = curSponsor {
            var sp = sponsor
            sp.isVideoAvaliable = false
            userList = [sp]
        } else {
            var curUser = CallingUserModel()
            
            userList = [curUser]
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if curState == .calling {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCallUserCell", for: indexPath) as! VideoCallUserCell
        if (indexPath.row < avaliableList.count) {
            var user = avaliableList[indexPath.row]
            if curState == .calling {
                user.isEnter = true
            }
            cell.userModel = user

//                localPreView.removeFromSuperview()
//                cell.addSubview(localPreView)
//                cell.sendSubviewToBack(localPreView)
//                localPreView.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            
        } else {
            cell.userModel = CallingUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        let collectHight = collectionView.frame.size.height
        if (collectionCount <= 4) {
            let width = collectWidth / 2
            let height = collectHight / 2
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                if indexPath.row == 0 && collectionCount == 1 {
                    return CGSize(width: width, height: width)
                } else {
                    return CGSize(width: width, height: height)
                }
            } else {
                return CGSize(width: width, height: height)
            }
        } else {
            let width = collectWidth / 3
            let height = collectHight / 3
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /// enterUser回调 每个用户进来只能调用一次
    /// - Parameter user: 用户信息
    
    @objc func OCEnterUser(userID: String) {
        let user = CallingUserModel(avatarUrl: "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png",
                                    name: "Device",
                                    userId: userID,
                                    isEnter: true,
                                    isVideoAvaliable: true,
                                    volume: 0.0)
        self.enterUser(user: user)
    }
    func enterUser(user: CallingUserModel) {

        if let renderView = TRTCCallingVideoViewController.renderViews {
            renderView.userModel = user
            TRTCCalling.shareInstance().startRemoteView(userId: user.userId, view: renderView)
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
            renderView.addGestureRecognizer(tap)
        }

        curState = .calling
        updateUser(user: user, animated: true)
    }
    
    func leaveUser(user: CallingUserModel) {
        TRTCCalling.shareInstance().stopRemoteView(userId: user.userId)
        
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            let dstUser = userList[index]
            let animate = dstUser.isVideoAvaliable
            userList.remove(at: index)
            reloadData(animate: animate)
        }
    }
    
    func updateUser(user: CallingUserModel, animated: Bool) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
            userList.insert(user, at: index)
        } else {
            userList.append(user)
        }
        reloadData(animate: animated)
    }
    
    func updateUserVolume(user: CallingUserModel) {
        if let firstRender = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
            firstRender.userModel = user
        } else {
            localPreView.userModel = user
        }
    }
    
    func reloadData(animate: Bool = false) {
        
        if curState == .calling && collectionCount > 2 {
            userCollectionView.isHidden = false
        } else {
            userCollectionView.isHidden = true
        }
        
        if collectionCount <= 2 {
            updateLayout()
            return
        }
        
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        
        if animate {
            userCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.userCollectionView.mas_updateConstraints { (make:MASConstraintMaker?) in
                    make?.leading.trailing()?.equalTo()(self.view)
                    make?.bottom.equalTo()(self.view)?.setOffset(-132)
                    make?.top.mas_equalTo()(self.collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                self.userCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation {
                userCollectionView.mas_updateConstraints { (make:MASConstraintMaker?) in
                    make?.leading.trailing()?.equalTo()(view)
                    make?.bottom.equalTo()(view)?.setInset(-132)
                    make?.top.mas_equalTo()(collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                userCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func updateLayout() {
        func setLocalViewInVCView(frame: CGRect, shouldTap: Bool = false) {
            if localPreView.frame == frame {
                return
            }
            localPreView.isUserInteractionEnabled = shouldTap
            localPreView.subviews.first?.isUserInteractionEnabled = !shouldTap
            if localPreView.superview != view {
                let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                if localPreView.superview == nil {
                    view.insertSubview(localPreView, aboveSubview: userCollectionView)
                }
                localPreView.frame = preFrame
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            }
        }
        
        if curState == .calling || curState == .dailing{
//            if localPreView.superview != view { // 从9宫格变回来
//                setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
//                                                   y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0), shouldTap: true)
//            } else { //进来了一个人
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    if self.collectionCount == 2 {
//                        if self.localPreView.bounds.size.width != kSmallVideoViewWidth {
//                            setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
//                            y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0), shouldTap: true)
//                        }
//                    }
//                }
//            }
            
            if let otherRenderView = TRTCCallingVideoViewController.renderViews {
                otherRenderView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                               y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                view.insertSubview(otherRenderView, aboveSubview: localPreView)
            }
            
            
        } else { //用户退出只剩下自己（userleave引起的）
//            if collectionCount == 1 {
                setLocalViewInVCView(frame: UIScreen.main.bounds)
//            }
        }
    }
}

extension TRTCCallingVideoViewController {
    func setupUI() {
        
        view.backgroundColor = .appBackGround
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.leading.trailing()?.equalTo()(view)
            make?.bottom.equalTo()(view)?.setOffset(-132)
            make?.top.mas_equalTo()(topPadding + 62)
        }
        view.addSubview(localPreView)
        localPreView.backgroundColor = .appBackGround
        localPreView.frame = UIScreen.main.bounds
        localPreView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
        localPreView.addGestureRecognizer(tap)

        userCollectionView.isHidden = true
        
        setupSponsorPanel(topPadding: topPadding)
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
        AppUtils.shared.alertUserTips(self)
        TRTCCalling.shareInstance().openCamera(frontCamera: true, view: localPreView)
    }
    
    func setupSponsorPanel(topPadding: CGFloat) {
        // sponsor
        if let sponsor = curSponsor {
            view.addSubview(sponsorPanel)
            sponsorPanel.mas_makeConstraints { (make:MASConstraintMaker?) in
                make?.leading.trailing()?.equalTo()(view)
                make?.top.mas_equalTo()(topPadding + 18)
                make?.height.mas_equalTo()(60)
            }
            //发起者头像
            let userImage = UIImageView()
            sponsorPanel.addSubview(userImage)
            userImage.mas_makeConstraints { (make:MASConstraintMaker?) in
                make?.trailing.equalTo()(sponsorPanel)?.setOffset(30)
                make?.top.mas_equalTo()(sponsorPanel)
                make?.width.height()?.mas_equalTo()(60)
            }
//            userImage.sd_setImage(with: URL(string: sponsor.avatarUrl), completed: nil)
            
            //发起者名字
            let userName = UILabel()
            userName.textAlignment = .right
            userName.font = UIFont.boldSystemFont(ofSize: 20)
            userName.textColor = .white
//            userName.text = self.deviceName//sponsor.name
            sponsorPanel.addSubview(userName)
            userName.mas_makeConstraints { (make:MASConstraintMaker?) in
                make?.trailing.equalTo()(userImage.mas_leading)?.setOffset(-6)
                make?.height.mas_equalTo()(32)
                make?.top.leading().equalTo()(sponsorPanel)
            }
            //提醒文字
            
            invite.textAlignment = .center
            invite.font = UIFont.systemFont(ofSize: 16)
            invite.textColor = .white
            invite.text = "视频通话邀请"
            sponsorPanel.addSubview(invite)
            invite.mas_makeConstraints { (make:MASConstraintMaker?) in
                if #available(iOS 11.0, *) {
                    make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.setOffset(70)
                }else {
                    make?.top.equalTo()(self.view.mas_top)?.setOffset(70)
                }
                make?.leading.trailing()?.equalTo()(self.view)
                
//                make?.trailing.equalTo()(userImage.mas_leading)?.setOffset(-6)
//                make?.height.mas_equalTo()(32)
//                make?.top.equalTo()(userName.mas_bottom)?.setOffset(2)
//                make?.leading.equalTo()(sponsorPanel)
            }
        }
    }
    
    @objc func remoteDismiss() {
        TRTCCalling.shareInstance().hangup()
       self.disMiss()
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setImage(UIImage(named: "ic_hangup"), for: .normal)
            view.addSubview(hangup)
            hangup.addTarget(self, action: #selector(hangupTapped), for: .touchUpInside)
        }
        
        
        if accept.superview == nil {
            accept.setImage(UIImage(named: "ic_dialing"), for: .normal)
            view.addSubview(accept)
            accept.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        }
        
        if mute.superview == nil {
            mute.setImage(UIImage(named: "ic_mute"), for: .normal)
            view.addSubview(mute)
            mute.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
            mute.isHidden = true
            mute.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(view)?.setOffset(-120)
                make?.bottom.equalTo()(view)?.setOffset(-32)
                make?.height.width()?.mas_equalTo()(60)
            }
        }
        
        if handsfree.superview == nil {
            handsfree.setImage(UIImage(named: "ic_handsfree_on"), for: .normal)
            view.addSubview(handsfree)
            handsfree.addTarget(self, action: #selector(handsfreeTapped), for: .touchUpInside)
            handsfree.isHidden = true
            handsfree.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(view)?.setOffset(120)
                make?.bottom.equalTo()(view)?.setOffset(-32)
                make?.width.height()?.mas_equalTo()(60)
            }
        }
        
        if callTimeLabel.superview == nil {
            callTimeLabel.textColor = .white
            callTimeLabel.backgroundColor = .clear
            callTimeLabel.text = "00:00"
            callTimeLabel.textAlignment = .center
            view.addSubview(callTimeLabel)
            callTimeLabel.isHidden = true
            callTimeLabel.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.leading.trailing()?.equalTo()(view)
                make?.bottom.equalTo()(hangup.mas_top)?.setOffset(-10)
                make?.height.mas_equalTo()(30)
            }
        }
    }
    
    @objc func hangupTapped () {
        TRTCCalling.shareInstance().hangup()
        self.disMiss()
    }
    
    @objc func acceptTapped() {
        var curUser = CallingUserModel()
        
        self.enterUser(user: curUser)
        self.curState = .calling
        self.accept.isHidden = true
        
        if let delegate = self.actionDelegate {
            delegate.didAcceptJoinRoom()
        }
    }
    
    @objc func muteTapped () {
        self.isMicMute = !self.isMicMute
        TRTCCalling.shareInstance().setMicMute(self.isMicMute)
        self.mute.setImage(UIImage(named: self.isMicMute ? "ic_mute_on" : "ic_mute"), for: .normal)
        let indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        indicator.mode = MBProgressHUDMode.text
        indicator.label.text = self.isMicMute ? "开启静音" : "关闭静音"
        indicator.margin = 10
        indicator.offset.y = 50
        indicator.removeFromSuperViewOnHide = true
        indicator.hide(animated: true, afterDelay: 0.5)
    }
    
    
    @objc func handsfreeTapped () {
        self.isHandsFreeOn = !self.isHandsFreeOn
        TRTCCalling.shareInstance().setHandsFree(self.isHandsFreeOn)
        self.handsfree.setImage(UIImage(named: self.isHandsFreeOn ? "ic_handsfree_on" : "ic_handsfree"), for: .normal)
        let indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        indicator.mode = MBProgressHUDMode.text
        indicator.label.text = self.isHandsFreeOn ? "开启免提" : "关闭免提"
        indicator.margin = 10
        indicator.offset.y = 50
        indicator.removeFromSuperViewOnHide = true
        indicator.hide(animated: true, afterDelay: 0.5)
    }
    
    func autoSetUIByState() {
        userCollectionView.isHidden = ((curState != .calling) || (collectionCount <= 2))
        if let _ = curSponsor {
            sponsorPanel.isHidden = curState == .calling
        }
        
        switch curState {
        case .dailing:
            hangup.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(view)
                make?.bottom.equalTo()(view)?.setOffset(-32)
                make?.width.mas_equalTo()(60)
            }
            invite.text = "视频呼叫中..."
            break
        case .onInvitee:
            hangup.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(view)?.setOffset(-80)
                make?.bottom.equalTo()(view)?.setOffset(-32)
                make?.width.height()?.mas_equalTo()(60)
            }
            accept.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(view)?.setOffset(80)
                make?.bottom.equalTo()(view)?.setOffset(-32)
                make?.width.height()?.mas_equalTo()(60)
            }
            break
        case .calling:
            hangup.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(view)
                make?.bottom.equalTo()(view)?.setOffset(-32)
                make?.width.height()?.mas_equalTo()(60)
            }
            startGCDTimer()
            break
        }
        
        if curState == .calling {
            mute.isHidden = false
            handsfree.isHidden = false
            callTimeLabel.isHidden = false
            mute.alpha = 0.0
            handsfree.alpha = 0.0
            callTimeLabel.alpha = 0.0
            
            accept.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            if self.curState == .calling {
                self.mute.alpha = 1.0
                self.handsfree.alpha = 1.0
                self.callTimeLabel.alpha = 1.0
            }
        }) { _ in
            
        }
    }
    
    // Dispatch Timer
     func startGCDTimer() {
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: { [weak self] in
            guard let self = self else {return}
            self.callingTime += 1
            // UI 更新
            DispatchQueue.main.async {
                var mins: UInt32 = 0
                var seconds: UInt32 = 0
                mins = self.callingTime / 60
                seconds = self.callingTime % 60
                self.callTimeLabel.text = String(format: "%02d:", mins) + String(format: "%02d", seconds)
            }
        })
        
        // 判断是否取消，如果已经取消了，调用resume()方法时就会崩溃！！！
        if codeTimer.isCancelled {
            return
        }
        // 启动时间源
        codeTimer.resume()
    }
    
    
    
    @objc func handleTapGesture(tap: UIPanGestureRecognizer) {
        
        if tap.view == localPreView {
            if localPreView.frame.size.width == kSmallVideoViewWidth {
                
                if let firstRender = TRTCCallingVideoViewController.renderViews {
                    UIView.animate(withDuration: 0.3, animations: { [weak firstRender, weak self] in
                        guard let `self` = self else { return }
                        self.localPreView.frame = self.view.frame
                        firstRender?.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                    y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                    }) { [weak self] (result) in
                        guard let `self` = self else { return }
                        firstRender.removeFromSuperview()
                        self.view.insertSubview(firstRender, aboveSubview: self.localPreView)
                    }
                }
            }
        } else {
            if let smallView = tap.view {
                if smallView.frame.size.width == kSmallVideoViewWidth {
                    UIView.animate(withDuration: 0.3, animations: { [weak smallView ,weak self] in
                        guard let self = self else {return}
                        smallView?.frame = self.view.frame
                        self.localPreView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                         y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                        
                    }) { [weak self] (result) in
                        guard let `self` = self else { return }
                        smallView.removeFromSuperview()
                        self.view.insertSubview(smallView, belowSubview: self.localPreView)
                    }
                }
            }
        }
    }
}
