import Foundation

extension Child {
    static let mockChildren: [Child] = [
        Child(
            id: "1",
            parentName: "Sarah M.",
            parentVerified: true,
            name: "Emma",
            age: 4,
            bio: "Loves painting & outdoor adventures",
            distanceKm: 0.8,
            interests: ["Art", "Outdoors", "Swimming", "Reading"]
        ),
        Child(
            id: "2",
            parentName: "David R.",
            parentVerified: true,
            name: "Noah",
            age: 5,
            bio: "Soccer enthusiast & dinosaur expert",
            distanceKm: 1.2,
            interests: ["Soccer", "Dinosaurs", "Lego"]
        ),
        Child(
            id: "3",
            parentName: "Jessica L.",
            parentVerified: true,
            name: "Olivia",
            age: 3,
            bio: "Loves music and dancing",
            distanceKm: 1.5,
            interests: ["Music", "Dance", "Crafts"]
        ),
        Child(
            id: "4",
            parentName: "Mike T.",
            parentVerified: false,
            name: "Liam",
            age: 6,
            bio: "Future scientist & explorer",
            distanceKm: 2.1,
            interests: ["Science", "Reading", "Outdoors"]
        ),
        Child(
            id: "5",
            parentName: "Anna K.",
            parentVerified: true,
            name: "Sophie",
            age: 4,
            bio: "Artistic soul with a love for storytelling",
            distanceKm: 0.5,
            interests: ["Art", "Stories", "Music"]
        )
    ]
}
