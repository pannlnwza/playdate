import Foundation
import Observation

@Observable
final class ProfileViewModel {
    var profile: Profile

    init(profile: Profile = .mockProfile) {
        self.profile = profile
    }
}
