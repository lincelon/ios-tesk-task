//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

/// Analytics Service is used for events logging
/// The list of reasonable events is up to you
/// It should be possible not only to track events but to get it from the service
/// The minimal needed filters are: event name and date range
/// The service should be covered by unit tests

enum AnalyticsFilterOption {
    case name(String)
    case range(ClosedRange<Date>)
}

protocol AnalyticsService: AnyObject {
    func trackEvent(name: String, parameters: [String: String])
    func fetchEvents(using filterOptions: [AnalyticsFilterOption]) -> [AnalyticsEvent] 
}

final class AnalyticsServiceImp {
    private var events: [AnalyticsEvent] = []
    
    // MARK: - Init
    init() { }
        
    func fetchEvents(using filterOptions: [AnalyticsFilterOption]) -> [AnalyticsEvent] {
        var events = events
        for option in filterOptions {
            switch option {
            case let .name(value):
                events = events.filter { $0.name == value }
            case let .range(value):
                events = events.filter { value.lowerBound < $0.date && $0.date < value.upperBound }
            }
        }
        return events
    }
}

extension AnalyticsServiceImp: AnalyticsService {
    func trackEvent(name: String, parameters: [String: String]) {
        let event = AnalyticsEvent(
            name: name,
            parameters: parameters,
            date: .now
        )
        events.append(event)
    }
}
