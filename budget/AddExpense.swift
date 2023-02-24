//
//  AddExpense.swift
//  budget
//
//  Created by Lane Shukhov on 24.02.2023.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ExpensesListViewModel
    
    @State private var category = ""
    @State private var amount = ""
    @State private var date = Date()
    
    var expense: Expense?
    
    enum FocusedField {
        case category, amount
    }
    @FocusState private var focusedField: FocusedField?
    
    init(viewModel: ExpensesListViewModel, expense: Expense? = nil) {
            self.viewModel = viewModel
            self.expense = expense
            
            if let expense = expense {
                _category = State(initialValue: expense.category)
                _amount = State(initialValue: String(expense.amount))
                _date = State(initialValue: expense.date)
            }
        }
    
    var body: some View {
            Form {
                Section(header: Text(NSLocalizedString("category", comment: ""))) {
                    TextField(NSLocalizedString("enterExpenseCategory", comment: ""), text: $category)
                    .focused($focusedField, equals: .category)
                    .onSubmit {
                        focusedField = .amount
                    }
                }
                
                Section(header: Text(NSLocalizedString("amount", comment: ""))) {
                    TextField(NSLocalizedString("enterExpenseAmount", comment: ""), text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                
                Section(header: Text(NSLocalizedString("date", comment: ""))) {
                    DateTimePicker(date: $date)
                }
            }
            .onAppear {
                focusedField = .category
            }
            .navigationBarTitle(NSLocalizedString("addExpenses", comment: ""))
            .navigationBarItems(trailing:
                Button(NSLocalizedString("save", comment: "")) {
                if let amount = Double(self.amount.replacingOccurrences(of: ",", with: ".")) {
                    if self.expense != nil {
                        viewModel.updateExpense(expense: Expense(id: self.expense!.id, category: self.category, amount: amount, date: self.date))
                        
                        self.presentationMode.wrappedValue.dismiss()
                        return
                    }
                    
                    self.viewModel.addExpense(category: self.category, amount: amount, date: self.date)
                    self.presentationMode.wrappedValue.dismiss()
                }
                }
            )
    }
}

struct DateTimePicker: View {
    @Binding var date: Date
    
    var body: some View {
        HStack {
            DatePicker("", selection: $date, displayedComponents: [.date])
                .labelsHidden()
            DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                .labelsHidden()
        }
    }
}

struct AddExpense_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(viewModel: ExpensesListViewModel())
    }
}
