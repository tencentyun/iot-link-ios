//
//  CallUserCell.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
//import SnapKit
import Masonry
import SDWebImage

class CallingSelectUserTableViewCell: UITableViewCell {
    private var isViewReady = false
    private var buttonAction: (() -> Void)?
    lazy var userImg: UIImageView = {
       let img = UIImageView()
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        return label
    }()
    
    let callButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = UIColor.appTint
        button.setTitle("呼叫", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4.0
        return button
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        contentView.addSubview(userImg)
//        userImg.snp.remakeConstraints { (make) in
//            make.leading.equalToSuperview().offset(20)
//            make.width.height.equalTo(50)
//            make.centerY.equalTo(self)
//        }
        
        
        userImg.mas_updateConstraints { (make:MASConstraintMaker?) in
//            make.leading.equalToSuperview().offset(20)
//            make.width.height.equalTo(50)
//            make.centerY.equalTo(self)
            make?.leading.equalTo()(contentView.mas_leading)?.setOffset(20)
            make?.width.mas_equalTo()(50)
            make?.height.mas_equalTo()(50)
            make?.centerY.equalTo()(self)
            
        }
        
        contentView.addSubview(nameLabel)
//        nameLabel.snp.remakeConstraints { (make) in
//            make.leading.equalTo(userImg.snp.trailing).offset(12)
//            make.trailing.top.bottom.equalTo(self)
//        }
        nameLabel.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.leading.equalTo()(userImg.mas_trailing)?.setOffset(12)
            make?.trailing.equalTo()(self)
            make?.top.equalTo()(self)
            make?.bottom.equalTo()(self)
        }
        
        contentView.addSubview(callButton)
//        callButton.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.width.equalTo(60)
//            make.height.equalTo(30)
//            make.right.equalToSuperview().offset(-20)
//        }
        callButton.mas_makeConstraints { (make:MASConstraintMaker?) in
            make?.centerY.equalTo()(contentView.mas_centerY)
            make?.width.mas_equalTo()(60)
            make?.height.mas_equalTo()(30)
            make?.right.equalTo()(contentView)?.setOffset(-20)
        }
        
        callButton.addTarget(self, action: #selector(callAction(_:)), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonAction = nil
    }
    
    func config(model: String, selected: Bool = false, action: (() -> Void)? = nil) {
        backgroundColor = .clear
//        userImg.sd_setImage(with: URL(string: model.avatar), completed: nil)
        userImg.layer.masksToBounds = true
        userImg.layer.cornerRadius = 25
//        nameLabel.text = model.name
        buttonAction = action
    }
    
    @objc
    func callAction(_ sender: UIButton) {
        if let action = self.buttonAction {
            action()
        }
    }
}

class AudioCallUserCell: UICollectionViewCell {
    
    private var isViewReady: Bool = false
    

    lazy var cellImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var cellVoiceImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.init(named: "calling_mic")
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
       let user = UILabel()
        user.textColor = .white
        user.backgroundColor = .clear
        user.textAlignment = .left
        return user
    }()
    
    lazy var dimBk: UIView = {
        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dim.isHidden = true
        return dim
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        addSubview(cellImgView)
//        cellImgView.snp.remakeConstraints { (make) in
//            make.width.height.equalTo(self.snp.height)
//            make.centerX.centerY.equalTo(self)
//        }
        cellImgView.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.width.height()?.equalTo()(self.mas_height)
            make?.centerX.centerY()?.equalTo()(self)
        }
        
        addSubview(cellUserLabel)
//        cellUserLabel.snp.remakeConstraints { (make) in
//            make.bottom.left.equalTo(cellImgView)
//            make.height.equalTo(24)
//            make.right.equalTo(cellImgView).offset(-24)
//        }
        cellUserLabel.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.bottom.left()?.equalTo()(cellImgView)
            make?.right.equalTo()(cellImgView)?.setOffset(-24)
        }
        
        addSubview(cellVoiceImageView)
//        cellVoiceImageView.snp.remakeConstraints { (make) in
//            make.bottom.right.equalTo(cellImgView)
//            make.height.width.equalTo(24)
//        }
        cellVoiceImageView.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.bottom.right()?.equalTo()(cellImgView)
            make?.height.width()?.mas_equalTo()(24)
        }
        addSubview(dimBk)
//        dimBk.snp.remakeConstraints { (make) in
//            make.edges.equalTo(cellImgView)
//        }
        cellVoiceImageView.mas_updateConstraints { (make:MASConstraintMaker?) in
            make?.edges.equalTo()(cellImgView)
        }
        
    }
    
    var userModel = CallingUserModel(){
        didSet {
            configModel(model: userModel)
        }
    }
    
    func configModel(model: CallingUserModel) {
//        cellImgView.sd_setImage(with: URL(string: model.avatarUrl), completed: nil)
//        cellUserLabel.text = userModel.name
//        let noModel = model.userId.count == 0
//        dimBk.isHidden = userModel.isEnter || noModel
//        loading.isHidden = userModel.isEnter || noModel
//        if userModel.isEnter || noModel {
//            loading.stopAnimating()
//        } else {
//            loading.startAnimating()
//        }
//        cellUserLabel.isHidden = noModel
//        cellVoiceImageView.isHidden = model.volume < 0.05
    }
}

class VideoCallUserCell: UICollectionViewCell {
   
    var userModel = CallingUserModel() {
        didSet {
            configModel(model: userModel)
        }
    }
    
    func configModel(model: CallingUserModel) {
        let noModel = model.userId.count == 0
        if !noModel {
            
            if let render = TRTCCallingVideoViewController.getRenderView(userId: userModel.userId) {
                if render.superview != self {
                    render.removeFromSuperview()
                    DispatchQueue.main.async {
                        render.frame = self.bounds
                    }
                    addSubview(render)
                    render.userModel = userModel
                }
            } else {
                print("error")
            }
            
        }
    }
}
