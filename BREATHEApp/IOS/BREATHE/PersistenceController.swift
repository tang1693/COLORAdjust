//
//  PersistenceController.swift
//  BREATHE
//
//  Created by Shaun Song on 2021/4/27.
//

import Foundation
import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let testdata1 = TestData(context: controller.container.viewContext)
        testdata1.id = UUID().uuidString
        testdata1.patient = "Desai, Tara"
        testdata1.room = "Living Room"
        testdata1.timestamp = Date()
        testdata1.reading_cockroach = Float.random(in: 0..<1)
        testdata1.reading_mouse = Float.random(in: 0..<1)
        testdata1.reading_dustmite1 = Float.random(in: 0..<1)
        testdata1.reading_dustmite2 = Float.random(in: 0..<1)
        testdata1.intrash = false
        
        let testdata2 = TestData(context: controller.container.viewContext)
        testdata2.id = UUID().uuidString
        testdata2.patient = "Essenhigh, Inka"
        testdata2.room = "BedRoom"
        testdata2.timestamp = Date()
        testdata2.reading_cockroach = Float.random(in: 0..<1)
        testdata2.reading_mouse = Float.random(in: 0..<1)
        testdata2.reading_dustmite1 = Float.random(in: 0..<1)
        testdata2.reading_dustmite2 = Float.random(in: 0..<1)
        testdata2.intrash = false
        
        let testdata3 = TestData(context: controller.container.viewContext)
        testdata3.id = UUID().uuidString
        testdata3.patient = "Faraday, Michael"
        testdata3.room = "Bathroom"
        testdata3.timestamp = Date()
        testdata3.reading_cockroach = Float.random(in: 0..<1)
        testdata3.reading_mouse = Float.random(in: 0..<1)
        testdata3.reading_dustmite1 = Float.random(in: 0..<1)
        testdata3.reading_dustmite2 = Float.random(in: 0..<1)
        testdata3.intrash = false
        
        let testdata4 = TestData(context: controller.container.viewContext)
        testdata4.id = UUID().uuidString
        testdata4.patient = "Paik, Nam Jun"
        testdata4.room = "Kitchen"
        testdata4.timestamp = Date()
        testdata4.reading_cockroach = Float.random(in: 0..<1)
        testdata4.reading_mouse = Float.random(in: 0..<1)
        testdata4.reading_dustmite1 = Float.random(in: 0..<1)
        testdata4.reading_dustmite2 = Float.random(in: 0..<1)
        testdata4.intrash = false

        return controller
    }()

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "Model")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
