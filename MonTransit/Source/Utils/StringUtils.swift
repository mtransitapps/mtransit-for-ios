//
//  StringUtils.swift
//  MonTransit
//
//  Created by Thibault on 16-01-18.
//  Copyright © 2016 Thibault. All rights reserved.
//

import Foundation

extension String {
    func trunc(length: Int, trailing: String? = ".") -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}