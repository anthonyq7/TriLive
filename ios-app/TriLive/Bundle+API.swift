//
//  Bundle+API.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//
import Foundation

extension Bundle {

  var apiBaseURL: URL {
    guard
      let str = object(forInfoDictionaryKey: "API_BASE_URL") as? String,
      let url = URL(string: str)
    else {
      fatalError("You must set API_BASE_URL in Info.plist to a valid URL string")
    }
    return url
  }
}
