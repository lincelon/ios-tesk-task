//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

/// Services Assembler is used for Dependency Injection
/// There is an example of a _bad_ services relationship built on `onRateUpdate` callback
/// This kind of relationship must be refactored with a more convenient and reliable approach
enum ServicesAssembler {
    
    // MARK: - BitcoinRateService
    
    static let bitcoinRateService: PerformOnce<BitcoinRateService> = {
        lazy var analyticsService = Self.analyticsService()
        
        let service = BitcoinRateServiceImpl()
        
        service.onRateUpdate = {
            analyticsService.trackEvent(
                name: "bitcoin_rate_update",
                parameters: ["rate": String(format: "%.2f", $0)]
            )
        }
        
        return { service }
    }()
    
    // MARK: - AnalyticsService
    
    static let analyticsService: PerformOnce<AnalyticsService> = {
        let service = AnalyticsServiceImpl()
        
        return { service }
    }()
}
