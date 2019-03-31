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
    var refreshToken: BehaviorRelay<String> { get }
    var tapAttend: PublishSubject<Void> { get }
    var tapRefresh: PublishSubject<Void> { get }
    var attendButtonFlag: BehaviorRelay<Bool> { get }
    var accessToken: BehaviorRelay<String> { get }
    
    // MARK: - Output
    var attendResult: Observable<APIResult<AttendResponse>>! { get }
    var refreshResult: Observable<APIResult<RefreshResponse>>! { get }
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
    var refreshToken: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var tapAttend: PublishSubject<Void> = PublishSubject<Void>()
    var tapRefresh: PublishSubject<Void> = PublishSubject<Void>()
    var attendButtonFlag: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: true)
    var accessToken: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    // MARK: - Output
    var attendResult: Observable<APIResult<AttendResponse>>!
    var formValidation: Observable<String>?
    var refreshResult: Observable<APIResult<RefreshResponse>>!
    
    // MARK: - Initializer
    init(attendService: AttendServicable, refreshService: RefreshServicable) {
        refreshResult = tapRefresh.withLatestFrom(refreshToken).flatMapLatest({ (refreshToken) -> Observable<APIResult<RefreshResponse>> in
            let body = RefreshRequest(refreshToken: refreshToken)
            let param = body.dictionary
            return refreshService.reissue(param: param).catchError({ (error) -> Observable<APIResult<RefreshResponse>> in
                Observable.just(APIResult.Error(error))
            })
                .trackActivity(self.progressView)
                .observeOn(MainScheduler.instance)
        })
        switch UserType(userType: userType) {
        case .general: // General User Type
            let attendRequest = Observable.combineLatest(userId, number, accessToken)
            formValidation = number.observeOn(MainScheduler.instance)
            attendResult = tapAttend.withLatestFrom(attendRequest)
                .filter { (userId, number, accessToken) -> Bool in
                    if number.isEmpty || userId == -1 || accessToken == "" {
                        return false
                    }
                    return true
                }.flatMapLatest { (userId, number, accessToken) -> Observable<APIResult<AttendResponse>> in
                    guard let number = Int(number) else {
                      return Observable.just(
                            APIResult.Error(
                                ApiError(
                                    date: nil,
                                    errorCode: nil,
                                    status: nil,
                                    message: "invalid_attend_number".localized,
                                    path: nil
                                )
                            )
                        )
                    }
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
            let attendRequest = Observable.combineLatest(accessToken, attendButtonFlag)
            attendResult = tapAttend.withLatestFrom(attendRequest)
                .flatMapLatest { (accessToken, isSelected) -> Observable<APIResult<AttendResponse>> in
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
