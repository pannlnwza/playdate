import Foundation

extension Child {
    static let mockChildren: [Child] = [
        Child(
            id: "1",
            parentId: "p1",
            name: "Emma",
            age: 4,
            bio: "Loves painting & outdoor adventures",
            hobbies: ["Art", "Outdoors", "Swimming", "Reading"],
            parentName: "Sarah M.",
            parentVerified: true,
            distanceKm: 0.8
        ),
        Child(
            id: "2",
            parentId: "p2",
            name: "Noah",
            age: 5,
            bio: "Soccer enthusiast & dinosaur expert",
            hobbies: ["Soccer", "Dinosaurs", "Lego"],
            parentName: "David R.",
            parentVerified: true,
            distanceKm: 1.2
        ),
        Child(
            id: "3",
            parentId: "p3",
            name: "Olivia",
            age: 3,
            bio: "Loves music and dancing",
            hobbies: ["Music", "Dance", "Crafts"],
            parentName: "Jessica L.",
            parentVerified: true,
            distanceKm: 1.5
        ),
        Child(
            id: "4",
            parentId: "p4",
            name: "Liam",
            age: 6,
            bio: "Future scientist & explorer",
            hobbies: ["Science", "Reading", "Outdoors"],
            parentName: "Mike T.",
            parentVerified: false,
            distanceKm: 2.1
        ),
        Child(
            id: "5",
            parentId: "p5",
            name: "Sophie",
            age: 4,
            bio: "Artistic soul with a love for storytelling",
            hobbies: ["Art", "Stories", "Music"],
            parentName: "Anna K.",
            parentVerified: true,
            distanceKm: 0.5
        )
    ]
}
