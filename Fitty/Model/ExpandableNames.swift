//
//  ExpandableNames.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation

struct ExpandableNames: Equatable, Hashable {
    
    var isExpanded: Bool
    var names: [[TrainingPlan]]
}

struct ExpandableNutritionPlan: Equatable, Hashable {
    
    var isExpanded: Bool
    var names: [[NutritionPlan]]
}
