//
//  StringExt.swift
//  GithubSearch
//
//  Created by 최형우 on 2022/01/27.
//  Copyright © 2022 baegteun. All rights reserved.
//

extension String{
    func slice(from: String, to: String) -> String? {
        (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                return String(self[substringFrom..<substringTo])
            }
        }
    }
}
