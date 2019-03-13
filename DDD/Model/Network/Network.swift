//
//  Network.swift
//  DDD
//
//  Created by Gunter on 17/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import Himotoki
import SwiftyJSON

enum NetworkMethod {
    case get, post, put, delete, patch
}

enum APIResult<D> {
    case Success(D)
    case Error(Error)
}

protocol Networking {
    
    func requestNoResponse(method: NetworkMethod, url: String, parameters: [String: Any]?) -> Observable<APIResult<Any>>
    
    func request<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, type: D.Type) -> Observable<APIResult<D>>
    
    func request2<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, type: D.Type) -> Observable<D>
    
    func requestAuthLogin<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, type: D.Type) -> Observable<APIResult<D>>
    
    func requestWith<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, authToken: String, type: D.Type) -> Observable<APIResult<D>> 

}

final class Network: Networking {
    
    private let baseUrl = "base_url".localized
    
    private let queue = DispatchQueue(label: "DDD.Attendance.Network.Queue")
    
    static let shared = Network()
    
    var alamoFireManager: SessionManager?
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 100
        configuration.timeoutIntervalForResource = 100
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func request2<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, type: D.Type) -> Observable<D> {
        return request2(method: method, url: url, parameters: parameters)
            .map {
                do {
                    return try D.decodeValue($0)
                } catch {
                    debugPrint("decode fail \(error)")
                    throw NetworkError.IncorrectDataReturned
                }
        }
    }
    
    func request2(method: NetworkMethod, url: String, parameters: [String: Any]?) -> Observable<Any> {
        
        return Observable.create { observer in
            let method = method.httpMethod()
            
            var request: DataRequest
            
            //var keyStoreError: NSError?
            
            var authToken: String?
            
            //authToken = self.keychainStore.getValueForKeychain(key: "x-auth-token", errorKeychain: &keyStoreError)
            
            if let authToken = authToken {
                
                let headers: HTTPHeaders = ["x-auth-token": authToken]
                
                debugPrint(headers)
                
                if method == .get {
                    request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, headers: headers)
                } else {
                    request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                }
                
            } else {
                
                debugPrint("no token")
                
                if method == .get {
                    request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters)
                } else {
                    request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, encoding: JSONEncoding.default)
                }
                
            }
            
            request
                .debugLog()
                .validate(statusCode: 200..<201)
                .responseJSON(queue: self.queue) { response in
                    switch response.result {
                    case .success(let value):
                        //debugPrint("200 \(value)")
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        debugPrint("error")
                        debugPrint(error)
                        observer.onError(NetworkError(error: error))
                    }
            }
            return Disposables.create {
                debugPrint("😇 Disposables \(url)")
                request.cancel()
            }
        }
        
    }
    
    
    //error 핸들링을 위해
    func request<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, type: D.Type) -> Observable<APIResult<D>> {
        return Observable.create { observer in
            let method = method.httpMethod()
            
            var request: DataRequest
            
            let user = "auth_id".localized
            
            let password = "auth_pw".localized
            
            let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
            
            let base64Credentials = credentialData.base64EncodedString()
            
            let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
            
            if method == .get {
                request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, headers: headers)
            } else {
                request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            }
        
            request
                .debugLog()
                .validate()
                .responseJSON(queue: self.queue) { response in
                    switch response.result {
                    case .success(let value):
                        debugPrint("200")
                        
                        do {
                            //debugPrint(value)
                            let data = try D.decodeValue(value)
                            observer.onNext(APIResult.Success(data))
                            observer.onCompleted()
                        } catch {
                            debugPrint("decode fail \(error)")
                            let apiError: ApiError = ApiError(date: nil,
                                                              errorCode: "000",
                                                              status: nil,
                                                              message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                              path: nil)
                            observer.onError(apiError)
                        }
                        
                    case .failure(let error):
                        var apiError: ApiError
                        
                        //debugPrint("error")
                        debugPrint(error)
                        
                        if let data = response.data {
                            apiError = self.parsingErrorBody(data: data)
                            //debugPrint("api Error : \(apiError)")
                            observer.onError(apiError)
                        } else {
                            apiError = ApiError(date: nil,
                                                errorCode: "000",
                                                status: nil,
                                                message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                path: nil)
                            observer.onError(apiError)
                            
                        }
                    }
            }
            return Disposables.create {
                debugPrint("😇 Disposables \(url)")
                request.cancel()
            }
        }
    }
    
    func requestNoResponse(method: NetworkMethod, url: String, parameters: [String : Any]?) -> Observable<APIResult<Any>> {
        
        return Observable.create { [unowned self] observer in
            
            let method = method.httpMethod()
            
            var request: DataRequest
            
            let user = "auth_id".localized
            
            let password = "auth_pw".localized
                
            let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
                
            let base64Credentials = credentialData.base64EncodedString()
                
            let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
                
            debugPrint(headers)
                
            if method == .get || method == .delete {
                request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, headers: headers)
            } else {
                request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            }
            
            request.debugLog()
                .validate()
                .responseData(queue: self.queue) { response in
                    switch response.result {
                    case .success(let value):
                        debugPrint("200")
                        observer.onNext(APIResult.Success(200))
                        observer.onCompleted()
                    case .failure(let error):
                        var apiError: ApiError
                        if let data = response.data {
                            apiError = self.parsingErrorBody(data: data)
                            //debugPrint("api Error : \(apiError)")
                            observer.onError(apiError)
                        } else {
                            apiError = ApiError(date: nil,
                                                errorCode: "000",
                                                status: nil,
                                                message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                path: nil)
                            observer.onError(apiError)
                        }
                        
                    }
            }
            return Disposables.create {
                debugPrint("😇 Disposables \(url)")
                request.cancel()
            }
        }
        
    }
    
    func requestAuthLogin<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, type: D.Type) -> Observable<APIResult<D>> {
        return Observable.create { observer in
            let method = method.httpMethod()
            
            var request: DataRequest
            
            let user = "auth_id".localized
            let password = "auth_pw".localized
            
            let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
            let base64Credentials = credentialData.base64EncodedString()
            
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": "Basic \(base64Credentials)"
            ]
            
            request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, headers: headers)
            
            request
                .debugLog()
                .validate()
                .responseJSON(queue: self.queue) { response in
                    switch response.result {
                    case .success(let value):
                        debugPrint("200")
                        
                        do {
                            //debugPrint(value)
                            let data = try D.decodeValue(value)
                            observer.onNext(APIResult.Success(data))
                            observer.onCompleted()
                        } catch {
                            debugPrint("decode fail \(error)")
                            let apiError: ApiError = ApiError(date: nil,
                                                              errorCode: "000",
                                                              status: nil,
                                                              message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                              path: nil)
                            observer.onError(apiError)
                        }
                        
                    case .failure(let error):
                        var apiError: ApiError
                        
                        //debugPrint("error")
                        debugPrint("api error \(error)")
                        
                        if let data = response.data {
                            apiError = self.parsingErrorBody(data: data)
                            //debugPrint("api Error : \(apiError)")
                            observer.onError(apiError)
                        } else {
                            apiError = ApiError(date: nil,
                                                errorCode: "000",
                                                status: nil,
                                                message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                path: nil)
                            observer.onError(apiError)
                            
                        }
                    }
            }
            return Disposables.create {
                debugPrint("😇 Disposables \(url)")
                request.cancel()
            }
        }
    }
    
    func requestWith<D: Himotoki.Decodable>(method: NetworkMethod, url: String, parameters: [String: Any]?, authToken: String, type: D.Type) -> Observable<APIResult<D>> {
        return Observable.create { observer in
            let method = method.httpMethod()
            
            var request: DataRequest
            
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded",
                "Authorization": authToken
            ]
            
            debugPrint(headers)
            
            request = self.alamoFireManager!.request(self.baseUrl+url, method: method, parameters: parameters, headers: headers)
            
            request
                .debugLog()
                .validate()
                .responseJSON(queue: self.queue) { response in
                    switch response.result {
                    case .success(let value):
                        do {
                            let data = try D.decodeValue(value)
                            observer.onNext(APIResult.Success(data))
                            observer.onCompleted()
                        } catch {
                            debugPrint("decode fail \(error)")
                            let apiError: ApiError = ApiError(date: nil,
                                                              errorCode: "000",
                                                              status: nil,
                                                              message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                              path: nil)
                            observer.onError(apiError)
                        }
                        
                    case .failure(let error):
                        var apiError: ApiError

                        debugPrint(error)
                        
                        if let data = response.data {
                            apiError = self.parsingErrorBody(data: data)
                            observer.onError(apiError)
                        } else {
                            apiError = ApiError(date: nil,
                                                errorCode: "000",
                                                status: nil,
                                                message: NetworkError.IncorrectDataReturned.localizedDescription,
                                                path: nil)
                            observer.onError(apiError)
                            
                        }
                    }
            }
            return Disposables.create {
                debugPrint("😇 Disposables \(url)")
                request.cancel()
            }
        }
    }
    
    
    private func parsingErrorBody(data: Data) -> ApiError {
        
        do {
            
            let errorBody =  try JSON(data: data)
            return ApiError(date: errorBody["date"].string,
                            errorCode: errorBody["errorCode"].string,
                            status: errorBody["status"].int,
                            message: errorBody["message"].string,
                            path: errorBody["path"].string)
            
        } catch {
            
            return ApiError(date: nil,
                            errorCode: "000",
                            status: nil,
                            message: NetworkError.IncorrectDataReturned.localizedDescription,
                            path: nil)
        }
        
    }

}

fileprivate extension NetworkMethod {
    func httpMethod() -> HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        case .patch:
            return .patch
        }
    }
}

