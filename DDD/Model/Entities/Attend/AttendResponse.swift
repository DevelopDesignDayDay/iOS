//
//  AttendResponse.swift
//  DDD
//
//  Created by ParkSungJoon on 28/02/2019.
//  Copyright © 2019 Gunter. All rights reserved.
//

import Himotoki

struct AttendResponse {
    let status: String
    let message: String?
    let number: Int?
}

extension AttendResponse: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> AttendResponse {
        return try AttendResponse(
            status: e <| "status",
            message: e <|? "message",
            number: e <|? "number"
        )
    }
}
