//
//  Constants.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation

struct Constants {
    
    struct Cell {
        static let cellIdentifier = "ReusableCell"
        static let cellNibName = "MessageCell"
        static let findTrainerCell = "FindTrainerCell"
        static let clientsCell = "ClientsCell"
        static let trainingPlanNibName = "TrainingPlanCell"
        static let trainingPlanCell = "ReusableTrainingPlanCell"
        static let trainingPlanListCell = "TrainingPlanListCell"
        static let weekCell = "WeekCell"
        static let showPlanCell = "ShowPlanCell"
        static let nutritionPlanNibName = "NutritionPlanCell"
        static let nutritionPlanCell = "ReusableNutritionPlanCell"
        static let nutritionPlanListCell = "NutritionPlanListCell"
        static let nutritionWeekCell = "NutritionWeekCell"
        static let showNutritionPlanCell = "ShowNutritionPlanCell"
        static let firstViewCell = "FirstViewCell"
        static let firstTrainerCell = "FirstTrainerCell"
        static let firstTrainingPlanCell = "FirstTrainingPlanCell"
        static let firstNutritionPlanCell = "FirstNutritionPlanCell"
        static let firstPlanCell = "FirstPlanCell"
    }
    
    struct SegueTo {
        static let loginToMain = "loginToMain"
        static let loginToBMI = "loginToBMI"
        static let BMIToBMIResults = "BMIToBMIResults"
        static let mainToBMI = "mainToBMI"
        static let BMIResultsToAdditionalInfo = "BMIResultsToAdditionalInfo"
        static let AdditionalInfoToMain = "AdditionalInfoToMain"
        static let mainToUserProfile = "mainToUserProfile"
        static let mainToNavTrainer = "mainToNavTrainer"
        static let navToTrainer = "navToTrainer"
        static let mainToChat = "mainToChat"
        static let chatToNewChat = "chatToNewChat"
        static let newChatToChat = "newChatToChat"
        static let chatToChat = "chatToChat"
        static let mainToNavClients = "mainToNavClients"
        static let navToClients = "navToClients"
        static let clientsListToClientInfo = "clientsListToClientInfo"
        static let clientsInfoToTrainingPlan = "clientsInfoToTrainingPlan"
        static let mainToTrainingPlan = "mainToTrainingPlan"
        static let navToTrainingPlan = "navToTrainingPlan"
        static let trainingPlanListToShowPlan = "trainingPlanListToShowPlan"
        static let clientsInfoToNutritionPlan = "clientsInfoToNutritionPlan"
        static let mainToNutritionPlan = "mainToNutritionPlan"
        static let nutritionPlanListToShowPlan = "nutritionPlanListToShowPlan"
        static let navToNutritionPlan = "navToNutritionPlan"
        static let mainToFirst = "mainToFirst"
        static let firstToNutritionPlan = "firstToNutritionPlan"
        static let firstToTrainingPlan = "firstToTrainingPlan"
        static let firstToTrainer = "firstToTrainer"
    }
    
    struct UserDefaults {
        static let isLoggedIn = "isLoggedIn"
        static let isLoggedInFB = "isLoggedInFB"
        static let hasAlreadyLaunched = "hasAlreadyLaunched"
    }
    
}
