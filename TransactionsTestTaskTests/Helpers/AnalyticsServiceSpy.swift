//
//  AnalyticsServiceSpy.swift
//  TransactionsTestTaskTests
//
//  Created by Maksym Soroka on 12.03.2025.
//

import Foundation
@testable import TransactionsTestTask

final class AnalyticsServiceSpy: AnalyticsService {
    var trackedEvents: [AnalyticsEvent] = []
    private let fixedEventsDate: Date
    
    init(fixedEventsDate: Date = Date()) {
        self.fixedEventsDate = fixedEventsDate
    }
    
    func trackEvent(name: String, parameters: [String : String]) {
        let event = AnalyticsEvent(name: name, parameters: parameters, date: fixedEventsDate)
        trackedEvents.append(event)
    }
    
    func fetchEvents(using filterOptions: [AnalyticsFilterOption]) -> [AnalyticsEvent] {
        return trackedEvents.filter { $0.name == "bitcoin-rate-update" }
    }
}
