//
//  ExpensesList.swift
//  budget
//
//  Created by Lane Shukhov on 24.02.2023.
//

import SwiftUI

class ExpensesListViewModel: ObservableObject {
        @Published var expenses = [Expense]()
    
    var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func addExpense(category: String, amount: Double, date: Date) {
        let expense = Expense(category: category, amount: amount, date: date)
        expenses.append(expense)
        self.saveExpensesToUserDefaults(expenses: expenses)
    }
    
    func updateExpense(expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpensesToUserDefaults(expenses: expenses)
        }
    }
    
    func removeExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        self.saveExpensesToUserDefaults(expenses: expenses)
    }
    
    func saveExpensesToUserDefaults(expenses: [Expense]) {
        self.removeOlderExpenses()
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
    }
    
    func loadExpensesFromUserDefaults() -> [Expense] {
        if let expensesData = UserDefaults.standard.data(forKey: "expenses") {
            let decoder = JSONDecoder()
            if let expenses = try? decoder.decode([Expense].self, from: expensesData) {
                self.removeOlderExpenses()
                return expenses
            }
        }
        return []
    }
    
    func removeOlderExpenses() {
        let currentDate = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        
        expenses = expenses.filter { $0.date >= oneMonthAgo }
    }
}

struct ExpensesListView: View {
    @ObservedObject var viewModel: ExpensesListViewModel
    
    let locale = Locale.current
    var currencySymbol: String
    
    @State private var showAbout = false
    
    init(viewModel: ExpensesListViewModel) {
        self.viewModel = viewModel
        
        _ = locale.currency?.identifier
        currencySymbol = locale.currencySymbol ?? ""
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.expenses.isEmpty {
                    GeometryReader { geo in
                        VStack {
                            VStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                Text(NSLocalizedString("noExpenses", comment: ""))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: geo.size.width, height: geo.size.height - geo.safeAreaInsets.top)
                        }
                    }
                } else {
                    List {
                        ForEach(viewModel.expenses.sorted { $0.date > $1.date }) { expense in
                            NavigationLink(destination: AddExpenseView(viewModel: viewModel, expense: expense)) {
                                VStack(alignment: .leading) {
                                    Text(expense.category)
                                        .font(.headline)
                                    Text(String(format: "%.2f " + currencySymbol, expense.amount))
                                        .foregroundColor(.red)
                                    Text("\(Text(expense.date, style: .date)) \(Text(expense.date, style: .time))")
                                    .font(.caption)
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    
                }
            }
            .navigationBarTitle(NSLocalizedString("expenses", comment: ""))
            .navigationBarItems(
                leading: Menu {
                    Label(NSLocalizedString("total", comment: "") + String(format: ": %.2f " + currencySymbol, viewModel.totalExpense), systemImage: "creditcard")
                    Button(action: {
                        showAbout.toggle()
                    }) {
                        Label("about", systemImage: "info")
                    }
                    Button(role: .destructive, action: {
                            let alert = UIAlertController(title: NSLocalizedString("sure", comment: ""), message: NSLocalizedString("cannotUndone", comment: ""), preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { _ in
                                viewModel.removeExpense(at: IndexSet(integersIn: 0..<viewModel.expenses.count))
                            }))
                            alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel))
                            
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                            rootViewController.present(alert, animated: true)
                        }
                    }) {
                        Label(NSLocalizedString("deleteAll", comment: ""), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }, trailing:
                NavigationLink(destination: AddExpenseView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            )
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear {
            viewModel.expenses = viewModel.loadExpensesFromUserDefaults()
        }
        .popover(isPresented: $showAbout) {
            AppInfoView()
        }
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.removeExpense(at: offsets)
    }
}

struct ExpensesList_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesListView(viewModel: ExpensesListViewModel())
    }
}
