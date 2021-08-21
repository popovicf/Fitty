//
//  PickerField.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI
import Firebase

struct PickerField: UIViewRepresentable {
    
    @Binding var selectionIndex: Int?
    private var placeholder: String
    private var data: [String]
    private let textField: PickerTextField
    
    init<S>(_ title: S, data: [String], selectionIndex: Binding<Int?>) where S: StringProtocol {
        self.placeholder = String(title)
        self.data = data
        self._selectionIndex = selectionIndex
        
        textField = PickerTextField(data: data, selectionIndex: selectionIndex)
    }
    
    func makeUIView(context: UIViewRepresentableContext<PickerField>) -> UITextField {
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .systemOrange
        textField.textAlignment = .right
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<PickerField>) {
        if let index = selectionIndex {
           uiView.text = data[index]
        } else {
            uiView.text = ""
        }
    }
    
}
