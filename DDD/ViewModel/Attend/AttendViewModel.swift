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
    var formValidation: Observable<String>? { get }
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
    var formValidation: Observable<String>?
    
    // MARK: - Initializer
    init(attendService: AttendServicable) {
        guard let accessToken = accessToken else { return }
        switch UserType(userType: userType) {
        case .general: // General User Type
            let attendRequest = Observable.combineLatest(userId, number)
            formValidation = number.observeOn(MainScheduler.instance)
            attendResult = tapAttend.withLatestFrom(attendRequest)
                .filter { (_, number) -> Bool in
                    if number.isEmpty {
                        return false
                    }
                    return true
                }.flatMapLatest { (userId, number) -> Observable<APIResult<AttendResponse>> in
                    guard let number = Int(number) else { fatalError("Invalid Attend Number") }
                    let body = AttendRequest(userId: userId, number: number)
                    
                    let param = body.dictionary
                    return attendService.check(token: accessToken, param: param)
                        .catchError({ (error) -> Observable<APIResult<AttendResponse>> in
                            Observable.just(APIResult.Error(error))
                    })
                        .trackActivity(self.progressView)
                        .observeOn(MainScheduler.instance)
            }
        case .admin:  // Admin User Type
            attendResult = tapAttend.withLatestFrom(attendButtonFlag)
                .flatMapLatest { (isSelected) -> Observable<APIResult<AttendResponse>> in
                if isSelected {
                    return attendService.start(token: accessToken)
                        .catchError({ (error) -> Observable<APIResult<AttendResponse>> in
                            Observable.just(APIResult.Error(error))
                    })
                        .trackActivity(self.progressView)
                        .observeOn(MainScheduler.instance)
                }
                return attendService.end(token: accessToken)
                    .catchError({ (error) -> Observable<APIResult<AttendResponse>> in
                        Observable.just(APIResult.Error(error))
                })
                    .trackActivity(self.progressView)
                    .observeOn(MainScheduler.instance)
            }
        }
    }
}
