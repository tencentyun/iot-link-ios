//
//  TRTCCallingAudioContactViewController.swift
//  TXLiteAVDemo_Enterprise
//
//  Created by abyyxwang on 2020/8/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import Masonry
import MBProgressHUD

@objc public enum AudioiCallingState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

class TRTCCallingAuidoViewController: UIViewController, CallingViewControllerResponder {
    lazy var userList: [CallingUserModel] = []
    lazy var inviteeList: [CallingUserModel] = []
    var dismissBlock: (()->Void)? = nil
    
    // 麦克风和听筒状态记录
    private var isMicMute = false // 默认开启麦克风
    private var isHandsFreeOn = true // 默认开启扬声器
    
    let controlBackView = UIView()
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
//    let disposebag = DisposeBag()
    var curSponsor: CallingUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    var avatarBigImage = UIImageView()
    var avatarMidImage = UIImageView()
    var avatarImage = UIImageView()
    
    @objc var deviceName: String = ""

    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        self.view.addSubview(label)
        label.mas_makeConstraints { (make:MASConstraintMaker?) in
            if #available(iOS 11.0, *) {
                make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.setOffset(70)
            }else {
                make?.top.equalTo()(self.view.mas_top)?.setOffset(70)
            }
            make?.leading.trailing()?.equalTo()(self.view)
        }
        
        return label
    }()
    
    @objc weak var actionDelegate: TRTCCallingViewDelegate?

    var curState: AudioiCallingState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var OnInviteePanelList: [CallingUserModel] {
        get {
            return inviteeList.filter {
                var isSponor = false
                if let sponor = curSponsor {
                    isSponor = $0.userId == sponor.userId
                }
                return !isSponor
            }
        }
    }
    
    var collectionCount: Int {
        get {
            var count = ((userList.count <= 4) ? userList.count : 9)
            if curState == .onInvitee {
                count = 1
            }
            return count
        }
    }
    
    lazy var OninviteeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()
    
    let colors = [UIColor(red: 61.0 / 255.0, green: 139.0 / 255.0,
                          blue: 255.0 / 255.0, alpha: 1).cgColor,
                  UIColor(red: 18.0 / 255.0, green: 66.0 / 255.0,
                          blue: 255.0 / 255.0, alpha: 1).cgColor]
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    lazy var OnInviteePanel: UIView = {
        let panel = UIView()
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
                                      name: "Me",
                                      userId: ocUserID ?? "0",
                                      isEnter: false,
                                      isVideoAvaliable: false,
                                      volume: 0.0)
        
        if let _ = ocUserID {
            curState = .onInvitee
        } else {
            curSponsor = nil
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
        user.register(AudioCallUserCell.classForCoder(), forCellWithReuseIdentifier: "AudioCallUserCell")
        if #available(iOS 10.0, *) {
            user.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        user.showsVerticalScrollIndicator = false
        user.showsHorizontalScrollIndicator = false
        user.contentMode = .scaleToFill
        user.backgroundColor = .clear
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
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    @objc func beHungUp() {
        tipLabel.text = "对方已挂断..."
    }
    
    @objc func hungUp() {
        tipLabel.text = "对方正忙..."
    }
    
    @objc func noAnswered() {
        tipLabel.text = "对方无人接听..."
    }
}

extension TRTCCallingAuidoViewController {
    func setupUI() {
        
        avatarBigImage.image = UIImage.init(named: "avatar_big")
        view.addSubview(avatarBigImage)
        avatarBigImage.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.top.equalTo()(tipLabel.mas_bottom)?.setOffset(45)
            make?.width.height()?.mas_equalTo()(200)
            make?.centerX.equalTo()(view)
        }
        
        avatarMidImage.image = UIImage.init(named: "avatar_mid")
        view.addSubview(avatarMidImage)
        avatarMidImage.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.centerX.centerY().equalTo()(avatarBigImage)
            make?.width.height()?.mas_equalTo()(120)
        }
        
        avatarImage.image = UIImage.init(named: "avatar")
        view.addSubview(avatarImage)
        avatarImage.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.centerX.centerY().equalTo()(avatarMidImage)
            make?.width.height()?.mas_equalTo()(87)
        }
        
        view.addSubview(OnInviteePanel)
        OnInviteePanel.addSubview(OninviteeStackView)
        OninviteeStackView.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.leading.trailing()?.bottom()?.equalTo()(OnInviteePanel)
            make?.top.equalTo()(OnInviteePanel.mas_bottom)
        }
        
        
//        ToastManager.shared.position = .bottom
        var topPadding: CGFloat = 0
        
        gradientLayer.colors = colors.compactMap{ $0 }
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.leading.trailing()?.equalTo()(view)
            make?.height.equalTo()(view.mas_width)
            make?.top.mas_equalTo()(topPadding + 62)
        }
        
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
    }
    
    @objc func remoteDismiss() {
        TRTCCalling.shareInstance().hangup()
       self.disMiss()
    }
    
    func setupControls() {
        
        if controlBackView.superview == nil {
            controlBackView.backgroundColor = UIColor(ciColor: .black).withAlphaComponent(0.1)
            controlBackView.layer.cornerRadius = 33
            view.addSubview(controlBackView)
            controlBackView.mas_makeConstraints { (make:MASConstraintMaker?) in
                make?.trailing.equalTo()(view.mas_trailing)?.setOffset(-60)
                make?.leading.equalTo()(view.mas_leading)?.setOffset(60)
                make?.height.mas_equalTo()(66)
                if #available(iOS 11.0, *) {
                    make?.bottom.equalTo()(view.mas_safeAreaLayoutGuideBottom)?.setOffset(-60)
                }else {
                    make?.bottom.equalTo()(view.mas_bottom)?.setOffset(-60)
                }
            }
        }
        
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
                make?.leading.equalTo()(controlBackView.mas_leading)?.setOffset(5)
                make?.centerY.equalTo()(controlBackView)
                make?.width.mas_equalTo()(50)
                make?.height.mas_equalTo()(50)
            }
            
        }
        
        if handsfree.superview == nil {
            handsfree.setImage(UIImage(named: "ic_handsfree_on"), for: .normal)
            view.addSubview(handsfree)
            handsfree.addTarget(self, action: #selector(handsfreeTapped), for: .touchUpInside)
            handsfree.isHidden = true
            handsfree.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.trailing.equalTo()(controlBackView.mas_trailing)?.setOffset(-5)
                make?.centerY.equalTo()(controlBackView)
                make?.width.mas_equalTo()(50)
                make?.height.mas_equalTo()(50)
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
                make?.top.equalTo()(avatarBigImage.mas_bottom)?.setOffset(20)
                make?.height.mas_equalTo()(30)
            }
        }
    }
    
    @objc func hangupTapped() {
        TRTCCalling.shareInstance()
        TRTCCalling.shareInstance().hangup()
        self.disMiss()
    }
    
    @objc func acceptTapped() {
        
        var curUser = CallingUserModel()
        curUser.isEnter = true
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
    
    @objc func handsfreeTapped() {
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
        switch curState {
        case .dailing:
            hangup.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(controlBackView)
                make?.centerY.equalTo()(controlBackView)
                make?.width.mas_equalTo()(60)
                make?.height.mas_equalTo()(60)
            }
            
            tipLabel.text = "语音呼叫中..."
            break
        case .onInvitee:
            hangup.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.leading.equalTo()(controlBackView)?.setOffset(5)
                make?.centerY.equalTo()(controlBackView)
                make?.width.mas_equalTo()(60)
                make?.height.mas_equalTo()(60)
            }
            
            accept.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.trailing.equalTo()(controlBackView)?.setOffset(-5)
                make?.centerY.equalTo()(controlBackView)
                make?.width.mas_equalTo()(60)
                make?.height.mas_equalTo()(60)
            }
            
            tipLabel.text = "语音通话邀请"
            break
        case .calling:
            hangup.mas_updateConstraints { (make:MASConstraintMaker?) in
                make?.centerX.equalTo()(controlBackView)
                make?.centerY.equalTo()(controlBackView)
                make?.width.mas_equalTo()(60)
                make?.height.mas_equalTo()(60)
            }
            startGCDTimer()
            
            tipLabel.text = "语音通话中..."
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
        
        let shouldHideOnInviteePanel = (OnInviteePanelList.count == 0 || (self.curState != .onInvitee))
        
        OnInviteePanel.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.bottom.equalTo()(self.hangup.mas_top)?.setOffset(-100)
            make?.width.mas_equalTo()(max(44, 44 * OnInviteePanelList.count + 2 * max(0, OnInviteePanelList.count - 1)))
            make?.centerX.equalTo()(view)
            make?.height.mas_equalTo()(60)
        }
        
        OninviteeStackView.safelyRemoveArrangedSubviews()
        if OnInviteePanelList.count > 0,!shouldHideOnInviteePanel {
            for user in OnInviteePanelList {
                let userAvatar = UIImageView()
                userAvatar.sd_setImage(with: URL(string: user.avatarUrl), completed: nil)
                userAvatar.widthAnchor.constraint(equalToConstant: 44).isActive = true
                OninviteeStackView.addArrangedSubview(userAvatar)
            }
        }
        
        OnInviteePanel.isHidden = shouldHideOnInviteePanel
        
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
}

extension TRTCCallingAuidoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func resetWithUserList(users: [CallingUserModel], isInit: Bool = false) {
        resetUserList()
        if isInit && curSponsor != nil {
            inviteeList.append(contentsOf: users)
        } else {
            userList.append(contentsOf: users)
        }
        
        if !isInit {
           reloadData()
        }
    }
    
    func resetUserList() {
        if let sponsor = curSponsor {
            userList = [sponsor]
        } else {
            var curUser = CallingUserModel()
            
            userList = [curUser]
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCallUserCell", for: indexPath) as! AudioCallUserCell
        if (indexPath.row < userList.count) {
            var user = userList[indexPath.row]
            if curState == .calling {
                user.isEnter = true
            }
            cell.userModel = user
        } else {
            cell.userModel = CallingUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        if (collectionCount <= 4) {
            let border = collectWidth / 2;
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                return CGSize(width:  collectWidth, height: border)
            } else {
                return CGSize(width: border, height: border)
            }
        } else {
            let border = collectWidth / 3;
            return CGSize(width: border, height: border)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc func OCEnterUser(userID: String) {
        let user = CallingUserModel(avatarUrl: "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png",
                                    name: "Device",
                                    userId: userID,
                                    isEnter: true,
                                    isVideoAvaliable: false,
                                    volume: 0.0)
        self.enterUser(user: user)
    }
    func enterUser(user: CallingUserModel) {
        curState = .calling
        updateUser(user: user, animated: true)
    }
    
    func leaveUser(user: CallingUserModel) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
        }
        reloadData(animate: true)
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
    
    func reloadData(animate: Bool = false) {
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
                    make?.bottom.equalTo()(view)?.setOffset(-132)
                    make?.top.mas_equalTo()(collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                userCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
}

