//
//  AttendViewModel.swift
//  DDD
//
//  Created by ParkSungJoon on 28/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift
import RxCocoa

protocol AttendViewModeling {
    
    // MARK: - Input
    var progressBinding: Observable<Bool> { get }
    var userId: BehaviorRelay<Int> { get }
    var number: BehaviorRelay<String> { get }
    var tapAttend: PublishSubject<Void> { get }
    var attendButtonFlag: BehaviorRelay<Bool> { get }
    
    // MARK: - Output
    var attendResult: Observable<APIResult<AttendResponse>>! { get }
}

class AttendViewModel: AttendViewModeling {

    // MARK: - Input
    var progressView: ActivityIndicator = ActivityIndicator()
    var progressBinding: Observable<Bool> {
        return progressView.asObservable()
    }
    var userId: BehaviorRelay<Int> = BehaviorRelay<Int>(value: -1)
    var userType: Int = UserDefaults.standard.integer(forKey: "userType")
    var number: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var tapAttend: PublishSubject<Void> = PublishSubject<Void>()
    var attendButtonFlag: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    
    lazy var accessToken = UserDefaults.standard.string(forKey: "accessToken")
    
    // MARK: - Output
    var attendResult: Observable<APIResult<AttendResponse>>!
    
    // MARK: - Initializer
    init(attendService: AttendServicable) {
        guard let accessToken = accessToken else { return }
        switch User(type: userType) {
        case .general:
            let attendRequest = Observable.combineLatest(userId, number)
            attendResult = tapAttend.withLatestFrom(attendRequest)
                .filter { (userId, number) -> Bool in
                    var isValidation = false
                    
                    if number.isEmpty {
                        isValidation = false
                    } else {
                        isValidation = true
                    }
                    debugPrint("isValidation \(isValidation)")
                    return isValidation
                }.flatMapLatest { (userId, number) -> Observable<APIResult<AttendResponse>> in
                    
                    let attendRequest = AttendRequest(userId: "\(userId)", number: number)
                    
                    let param = attendRequest.dictionary
                    return attendService.check(token: accessToken, param: param).catchError({ (error) -> Observable<APIResult<AttendResponse>> in
                        Observable.just(APIResult.Error(error))
                    })
                        .trackActivity(self.progressView)
                        .observeOn(MainScheduler.instance)
            }
        case .admin:
            attendResult = tapAttend.withLatestFrom(attendButtonFlag).flatMapLatest { (isSelected) -> Observable<APIResult<AttendResponse>> in
                if isSelected {
                    print("start")
                    return attendService.start(token: accessToken).catchError({ (error) -> Observable<APIResult<AttendResponse>> in
                        Observable.just(APIResult.Error(error))
                    })
                        .trackActivity(self.progressView)
                        .observeOn(MainScheduler.instance)
                }
                print("end")
                return attendService.end(token: accessToken).catchError({ (error) -> Observable<APIResult<AttendResponse>> in
                    Observable.just(APIResult.Error(error))
                })
                    .trackActivity(self.progressView)
                    .observeOn(MainScheduler.instance)
            }
        }
    }
    
    private enum User {
        case general
        case admin
        
        init(type: Int) {
            switch type {
            case 1: self = .admin
            case 2: self = .general
            default: fatalError("Invalid User Type")
            }
        }
    }
}
