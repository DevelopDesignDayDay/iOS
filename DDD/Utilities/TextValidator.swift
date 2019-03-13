//
//  TextValidator.swift
//  DDD
//
//  Created by Gunter on 13/03/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import RxSwift

class TextValidator {
    var input: Observable<String>
    
    init(input: Observable<String>) {
        self.input = input
    }
    
    func validate() -> Observable<Bool> {
        return input.map { text in
            if text.count <= 0 {
                return false
            } else {
                return true
            }
        }
    }
    
    func isEamilvalidate() -> Observable<Bool>  {
        return input.map { text in
            guard let regex = try? NSRegularExpression(
                    pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
                    options: [.caseInsensitive]
                )
                else {
                    assertionFailure("Regex not valid")
                    return false
            }
            
            let regexFirstMatch = regex
                .firstMatch(
                    in: text,
                    options: [],
                    range: NSRange(location: 0, length: text.count)
            )
            
            return regexFirstMatch != nil
        }
    }
    
    
}
