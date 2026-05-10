import Foundation
import MapKit

@MainActor
@Observable
final class LocationSearchService: NSObject {
    var query: String = "" {
        didSet {
            guard query != oldValue else { return }
            completer.queryFragment = query
        }
    }

    var suggestions: [MKLocalSearchCompletion] = []

    private let completer: MKLocalSearchCompleter

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.pointOfInterest, .address]
    }

    func clear() {
        suggestions = []
        completer.queryFragment = ""
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> (CLLocationCoordinate2D, String)? {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        guard let response = try? await search.start(),
              let item = response.mapItems.first else {
            return nil
        }
        return (item.placemark.coordinate, completion.title)
    }
}

extension LocationSearchService: @preconcurrency MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        suggestions = []
    }
}
