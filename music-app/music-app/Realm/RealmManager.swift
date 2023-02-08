//
//  RealmManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.02.23.
//

import Foundation
import RealmSwift

class RealmManager<T> where T: Object {
    private let realm = try! Realm()
    
    func write(object: T) {
        try? realm.write {
            realm.add(object)
        }
    }
    
    func read() -> [T] {
        return Array(realm.objects(T.self))
    }
    
    func update(realmBlock: @escaping (Realm) -> Void) {
        realmBlock(self.realm)
    }
    
    func delete(object: T) {
        try? realm.write {
            realm.delete(object)
        }
    }
}
