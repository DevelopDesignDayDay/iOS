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
    let number: Int
    let expire: String
    let message: String
}

extension AttendResponse: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> AttendResponse {
        return try AttendResponse(
            status: e <| "status",
            number: e <| "number",
            expire: e <| "expire",
            message: e <| "message"
        )
    }
}
