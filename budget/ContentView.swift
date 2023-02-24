//
//  ContentView.swift
//  budget
//
//  Created by Lane Shukhov on 22.02.2023.
//

import SwiftUI

struct Expense: Identifiable, Codable {
    var id = UUID()
    var category: String
    var amount: Double
    var date: Date
}

struct ContentView: View {
    let viewModel = ExpensesListViewModel()
    
    var body: some View {
        ExpensesListView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

