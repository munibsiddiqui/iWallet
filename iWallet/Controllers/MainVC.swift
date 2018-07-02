//
//  MainVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CVCalendar

class CoinCategory {
    var name = ""
    var amount = 0.0
    var color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    init(name: String, amount: Double, color: UIColor) {
        self.name = name
        self.amount = amount
        self.color = color
    }
}
class MainVC: UIViewController {


    @IBOutlet weak var cashTableView: UITableView!
    @IBOutlet weak var cardsTableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var costsBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var coinView: ViewWithBottomButton!
    @IBOutlet weak var parentCategoryScrollView: UIScrollView!
    @IBOutlet weak var childCategoryScrollView: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    var cards = [(name: String, id: String, costs: String, income: String)]()
    var cash = [(name: String, id: String, costs: String, income: String)]()
    var accounts = [(name: String, id: String, costs: String, income: String, rate: Double)]()
    var date = Date()
    var parentCategories = [CoinCategory]()
    var childCategories = [[CoinCategory]]()
    private var currentCalendar: Calendar?
    var selectedCardsRow: Int?
    var selectedCashRow: Int?
    let baseCategoryHeight = 125.0
    let minbaseCategoryHeight = 100.0
    let minChildCategoryHeight = 80.0
    var parentCategoryHeight = 125.0
    var childCategoryHeight = 100.0

    var parentCategoryCollectionView: UICollectionView?
    var childCategoryCollectionView: UICollectionView?
    let layoutPCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let layoutCCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var selectedParentCategory: Int?
    var currencyRates = ["USD" : 1.0]

    @IBAction func costsBtnPressed(_ sender: Any) {
        incomeBtn.isEnabled = true
        costsBtn.isEnabled = false
        incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
        costsBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        if let cardsRow = selectedCardsRow {
            fetchCategoriesCostsData(account: cards[cardsRow].id)
        }
        if let cashRow = selectedCashRow {
            fetchCategoriesCostsData(account: cash[cashRow].id)
        }
        
    }
    
    @IBAction func incomeBtnPressed(_ sender: Any) {
        incomeBtn.isEnabled = false
        costsBtn.isEnabled = true
        incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        costsBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
        if let cardsRow = selectedCardsRow {
            fetchCategoriesIncomeData(account: cards[cardsRow].id)
        }
        if let cashRow = selectedCashRow {
            fetchCategoriesIncomeData(account: cash[cashRow].id)
        }
    }
    
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "eng_ENG")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        fetchData()
    }
    
    @objc func addTransactionBtnPressed(){
        let addTransaction = AddTransactionVC()
        addTransaction.modalPresentationStyle = .custom
        addTransaction.delegate = self
        presentDetail(addTransaction)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cashTableView.delegate = self
        cashTableView.dataSource = self
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        cashTableView.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        cardsTableView.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        setCategoryHeight()
        coinView.addButton.addTarget(self, action: #selector(MainVC.addTransactionBtnPressed), for: .touchUpInside)
        layoutPCV.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutPCV.minimumInteritemSpacing = 8
        layoutPCV.minimumLineSpacing = 8
        
        layoutCCV.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutCCV.minimumInteritemSpacing = 8
        layoutCCV.minimumLineSpacing = 8
        
        parentCategoryCollectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.coinView.frame.width), height: parentCategoryHeight), collectionViewLayout: layoutPCV)
        parentCategoryCollectionView?.delegate = self
        parentCategoryCollectionView?.dataSource = self
        parentCategoryCollectionView?.register(UINib(nibName: "CoinCell", bundle: nil), forCellWithReuseIdentifier: "CoinCell")
        parentCategoryCollectionView?.showsVerticalScrollIndicator = false
        parentCategoryCollectionView?.showsHorizontalScrollIndicator = false
        parentCategoryCollectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        childCategoryCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: Double(self.coinView.frame.width), height: childCategoryHeight), collectionViewLayout: layoutCCV)
        childCategoryCollectionView?.delegate = self
        childCategoryCollectionView?.dataSource = self
        childCategoryCollectionView?.register(UINib(nibName: "CoinCell", bundle: nil), forCellWithReuseIdentifier: "CoinCell")
        childCategoryCollectionView?.showsVerticalScrollIndicator = false
        childCategoryCollectionView?.showsHorizontalScrollIndicator = false
        childCategoryCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        parentCategoryScrollView?.contentSize = CGSize(width: coinView.frame.width, height: CGFloat(parentCategoryHeight))
        parentCategoryScrollView?.showsVerticalScrollIndicator = false
        parentCategoryScrollView?.showsHorizontalScrollIndicator = false
        parentCategoryScrollView?.delegate = self
        parentCategoryScrollView?.addSubview(parentCategoryCollectionView!)
        

        childCategoryScrollView?.contentSize = CGSize(width: coinView.frame.width, height: CGFloat(childCategoryHeight))
        childCategoryScrollView?.showsVerticalScrollIndicator = false
        childCategoryScrollView?.showsHorizontalScrollIndicator = false
        childCategoryScrollView?.delegate = self
        childCategoryScrollView?.addSubview(childCategoryCollectionView!)
    
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        setMonthLabel()
        fetchData()
        setCategoryContentWidth()
        NotificationCenter.default.addObserver(self, selector: #selector(updateByNotification(notification:)), name: .update, object: nil)
    }
    
    @objc func updateByNotification(notification: NSNotification) {
        fetchData()
        setCategoryContentWidth()
    }
    func setCategoryHeight(){
        if CGFloat(parentCategoryHeight + childCategoryHeight + 8) > (self.view.frame.height - coinView.frame.origin.y) {
            parentCategoryHeight = Double((self.view.frame.height - coinView.frame.origin.y) * 0.55)
            childCategoryHeight = Double(self.view.frame.height - coinView.frame.origin.y) - parentCategoryHeight
        }
    }
    func setCategoryContentWidth(){
        var widthParent = 16.0
        var widthChild = 16.0
        var index = 0
        for _ in parentCategories {
            widthParent += getDimensionParentCategoryCell(index: index) + 8
            index += 1
        }
//        widthParent -= 8
        if let selectedParent = selectedParentCategory {
                widthChild += Double(childCategories[selectedParent].count) * (childCategoryHeight + 8)
                widthChild -= 8
        }
        parentCategoryCollectionView?.frame = CGRect(x: 0, y: 0, width: widthParent < (parentCategoryHeight + 16) ? (parentCategoryHeight + 16) : widthParent, height: parentCategoryHeight)
        childCategoryCollectionView?.frame = CGRect(x: 0, y: 0, width: widthChild < (childCategoryHeight + 16) ? (childCategoryHeight + 16) : widthChild, height: childCategoryHeight)
        parentCategoryScrollView.contentSize = CGSize(width: CGFloat(widthParent), height: CGFloat(parentCategoryHeight))
        childCategoryScrollView.contentSize = CGSize(width: CGFloat(widthChild), height: CGFloat(childCategoryHeight))
    }
    
    func fetchCategoriesCostsData(account: String){
        selectedParentCategory = nil
        parentCategories = []
        childCategories = []
        guard let currentUser = LoginHelper.instance.currentUser else {
            return
        }
        CoreDataService.instance.fetchCategoriesCosts(ByAccount: account, WithDate: date, userID: currentUser, complition: { (results) in
           
            for arrayItem in results {
                if let category = arrayItem["category.name"] as? String, let colorStr = arrayItem["category.color"] as? String, let sum = arrayItem["sum"] as? Double {
                    let color = EncodeDecodeService.instance.returnUIColor(components: colorStr)
                    if let parent = arrayItem["category.parent.name"] as? String {
                        var matchParent = false
                        for (index, item) in parentCategories.enumerated() {
                            if item.name == parent {
                                item.amount += sum
                                childCategories[index].append(CoinCategory(name: category, amount: sum, color: color))
                                matchParent = true
                            }
                        }
                        if !matchParent {
                            parentCategories.append(CoinCategory(name: parent, amount: sum, color: color))
                            childCategories.append([CoinCategory(name: category, amount: sum, color: color)])
                        }
                    } else {
                        var matchParent = false
                        for item in parentCategories {
                            if item.name == category {
                                item.amount += sum
                                matchParent = true
                            }
                        }
                        if !matchParent {
                            parentCategories.append(CoinCategory(name: category, amount: sum, color: color))
                            childCategories.append([])
                        }
                    }
                }
            }
            if parentCategories.count > 0 {
                selectedParentCategory = 0
            }
            setCategoryContentWidth()
            for (index, _) in parentCategories.enumerated() {
                for (nestedIndex, _) in parentCategories.enumerated() {
                    if parentCategories[index].amount > parentCategories[nestedIndex].amount {
                        let parentSwap = parentCategories[index]
                        parentCategories[index] = parentCategories[nestedIndex]
                        parentCategories[nestedIndex] = parentSwap
                        let childSwap = childCategories[index]
                        childCategories[index] = childCategories[nestedIndex]
                        childCategories[nestedIndex] = childSwap
                    }
                }
            }
            for (index, item) in childCategories.enumerated() {
                var childArray = item
                childArray.sort { (arg0, arg1) -> Bool in
                    return arg0.amount > arg1.amount
                }
                childCategories[index] = childArray
            }
            parentCategoryCollectionView?.reloadData()
            childCategoryCollectionView?.reloadData()
        })
    }
    
    func fetchCategoriesIncomeData(account: String){
        selectedParentCategory = nil
        parentCategories = []
        childCategories = []
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchCategoriesIncome(ByAccount: account, WithDate: date, userID: currentUser, complition: { (results) in
            for arrayItem in results {
                if let category = arrayItem["category.name"] as? String, let colorStr = arrayItem["category.color"] as? String, let sum = arrayItem["sum"] as? Double {
                    let color = EncodeDecodeService.instance.returnUIColor(components: colorStr)
                    if let parent = arrayItem["category.parent.name"] as? String {
                        var matchParent = false
                        for (index, item) in parentCategories.enumerated() {
                            if item.name == parent {
                                item.amount += sum
                                childCategories[index].append(CoinCategory(name: category, amount: sum, color: color))
                                matchParent = true
                            }
                        }
                        if !matchParent {
                            parentCategories.append(CoinCategory(name: parent, amount: sum, color: color))
                            childCategories.append([CoinCategory(name: category, amount: sum, color: color)])
                        }
                    } else {
                        var matchParent = false
                        for item in parentCategories {
                            if item.name == category {
                                item.amount += sum
                                matchParent = true
                            }
                        }
                        if !matchParent {
                            parentCategories.append(CoinCategory(name: category, amount: sum, color: color))
                            childCategories.append([])
                        }
                    }
                }
            }
            if parentCategories.count > 0 {
                selectedParentCategory = 0
            }
            setCategoryContentWidth()
            for (index, _) in parentCategories.enumerated() {
                for (nestedIndex, _) in parentCategories.enumerated() {
                    if parentCategories[index].amount > parentCategories[nestedIndex].amount {
                        let parentSwap = parentCategories[index]
                        parentCategories[index] = parentCategories[nestedIndex]
                        parentCategories[nestedIndex] = parentSwap
                        let childSwap = childCategories[index]
                        childCategories[index] = childCategories[nestedIndex]
                        childCategories[nestedIndex] = childSwap
                    }
                }
            }
            for (index, item) in childCategories.enumerated() {
                var childArray = item
                childArray.sort { (arg0, arg1) -> Bool in
                    return arg0.amount > arg1.amount
                }
                childCategories[index] = childArray
            }
            parentCategoryCollectionView?.reloadData()
            childCategoryCollectionView?.reloadData()
        })
       
    }

    func fetchCategoryData(ByAccount account: (name: String, id: String, costs: String, income: String, rate: Double)){
        let costs = Double(account.costs) ?? 0.0
        let income = Double(account.income) ?? Double(account.income[1..<account.income.count]) ?? 0.0
        if income > costs {
           fetchCategoriesIncomeData(account: account.id)
           incomeBtn.isEnabled = false
            costsBtn.isEnabled = true
            incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
            costsBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
        } else {
           fetchCategoriesCostsData(account: account.id)
            incomeBtn.isEnabled = true
            costsBtn.isEnabled = false
            incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
            costsBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        }
    }
    
    func fetchAccountsIncome(complition: @escaping (Bool)->()) {
        guard let currentUser = LoginHelper.instance.currentUser else {
            complition(false)
            return
        }
        CoreDataService.instance.fetchAccountsIncome(WithStartDate: date.startOfMonth(), WithEndDate: date.endOfMonth(), userID: currentUser){ (accountsArray) in
            if accountsArray.count == 0 {
                complition(false)
            } else {
                for (index, arrayItem) in accountsArray.enumerated() {
                    if let accountName = arrayItem["account.name"] as? String, let accountID = arrayItem["account.id"] as? String, let sum = arrayItem["sum"] as? Double, let currency = arrayItem["account.currency"] as? String {
                        if let currencyRate = self.currencyRates[currency] {
                            self.accounts.append((name: accountName, id: accountID, costs: "0.0", income: "\(sum.roundTo(places: 2))", rate: currencyRate))
                            if index == accountsArray.count - 1 {
                                complition(true)
                            }
                        } else {
                            ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: "USD", complition: { (rate) in
                                self.currencyRates[currency] = rate
                                self.accounts.append((name: accountName, id: accountID, costs: "0.0", income: "\(sum.roundTo(places: 2))", rate: rate))
                                if index == accountsArray.count - 1 {
                                    complition(true)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func fetchAccountsCosts(complition: @escaping (Bool)->()){
        guard let currentUser = LoginHelper.instance.currentUser else {
            complition(false)
            return
        }
        CoreDataService.instance.fetchAccountsCosts(WithStartDate: self.date.startOfMonth(), WithEndDate: self.date.endOfMonth(), userID: currentUser, complition: { (accountsArray) in
            if accountsArray.count == 0 {
                complition(false)
            } else {
                for (indexOfFetchedData, arrayItem) in accountsArray.enumerated() {
                    if let account = arrayItem["account.name"] as? String, let accountID = arrayItem["account.id"] as? String, let sum = arrayItem["sum"] as? Double, let currency = arrayItem["account.currency"] as? String {
                        var flagExist = false
                        for (index, item) in accounts.enumerated() {
                            if item.id == accountID {
                                accounts.remove(at: index)
                                accounts.append((name: item.name, id: item.id, costs: "\(sum.roundTo(places: 2))", income: item.income, rate: item.rate))
                                flagExist = true
                                if indexOfFetchedData == accountsArray.count - 1 {
                                    complition(true)
                                }
                            }
                        }
                        if !flagExist {
                            if let currencyRate = self.currencyRates[currency] {
                                self.accounts.append((name: account, id: accountID, costs: "\(sum.roundTo(places: 2))", income: "0.0", rate: currencyRate))
                                if indexOfFetchedData == accountsArray.count - 1 {
                                    complition(true)
                                }
                            } else {
                                ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: "USD", complition: { (rate) in
                                    self.currencyRates[currency] = rate
                                    self.accounts.append((name: account, id: accountID, costs: "\(sum.roundTo(places: 2))", income: "0.0", rate: rate))
                                    if indexOfFetchedData == accountsArray.count - 1 {
                                        complition(true)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
    }
    
    func fetchData(){
        cash = []
        cards = []
        accounts = []
        var accountIDs = [String]()
        selectedCashRow = nil
        selectedCardsRow = nil
        guard let currentUser = LoginHelper.instance.currentUser, let currentAccount = AccountHelper.instance.currentAccount else {
            titleLbl.text = "NO DATA"
            coinView.addButton.isHidden = true
            return
        }
        titleLbl.text = "BRIEF"
        coinView.addButton.isHidden = false
        self.fetchAccountsIncome { (succes) in
            self.fetchAccountsCosts(complition: { (success) in
                self.accounts.sort(by: { (arg0, arg1) -> Bool in
                        let (name0, id0, costs0, income0, rate0) = arg0
                        let (name1, id1, costs1, income1, rate1) = arg1
                        let sum0 = (Double(costs0) ?? 0.0) * rate0  + (Double(income0) ?? 0.0) * rate0
                        let sum1 = (Double(costs1) ?? 0.0 ) * rate1 + (Double(income1) ?? 0.0) * rate1

                        return sum0 > sum1
                    })
                for item in self.accounts {
                    accountIDs.append(item.id)
                }
                
                    CoreDataService.instance.fetchAccounts(ByObjectIDs: accountIDs, userID: currentUser, complition: { (fetchedAccounts) in
                            for (index, account) in self.accounts.enumerated() {
                                for fetchedAccount in fetchedAccounts {
                                    if account.id == fetchedAccount.id {
                                        guard let type = fetchedAccount.type, let currency = fetchedAccount.currency else {continue}
                                        if  type == AccountType.Cash.rawValue {
                                            if index == 0 {
                                                self.selectedCashRow = 0
                                            }
                                            self.cash.append((name: account.name, id: account.id, costs: account.costs, income:  AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency) + account.income))
                                        } else {
                                            if index == 0 {
                                                self.selectedCardsRow = 0
                                            }
                                             self.cards.append((name: account.name, id: account.id, costs: account.costs , income:  AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency) + account.income))
                                        }
                                        break
                                    }
                                }
                            }
                        })
                    if self.accounts.count > 0 {
                        self.fetchCategoryData(ByAccount: self.accounts[0])
                    } else {
                        self.parentCategories = []
                        self.childCategories = []
                        self.selectedParentCategory = nil
                        self.parentCategoryCollectionView?.reloadData()
                        self.childCategoryCollectionView?.reloadData()
                    }
            
                    self.cardsTableView.reloadData()
                    self.cashTableView.reloadData()
                })
        }
    }
    func setMonthLabel(){
        if let currentCalendar = currentCalendar {
            monthLbl.text = CVDate(date: date, calendar: currentCalendar).globalDescription
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        date = date.previousMonth()
        setMonthLabel()
        fetchData()
    }
    
    @IBAction func forwardBtnPressed(_ sender: Any) {
        date = date.nextMonth()
        setMonthLabel()
        fetchData()
    }
    
}

extension MainVC : BriefProtocol{
    func handleTransaction(date: Date) {
        fetchData()
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == parentCategoryScrollView {
            scrollView.contentSize.height = CGFloat(parentCategoryHeight)
        } else if scrollView == childCategoryScrollView{
           scrollView.contentSize.height = 1.0
        }
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == parentCategoryCollectionView{
            return parentCategories.count
        } else {
            if let selectedParent = selectedParentCategory {
                return childCategories[selectedParent].count
            } else {
                return 0
            }
        }
    }
    
    func getDimensionParentCategoryCell(index: Int) -> Double{
        var newDimension = parentCategoryHeight - Double(index * Int(0.05 * parentCategoryHeight))
        newDimension = newDimension < parentCategoryHeight * 0.8 ? parentCategoryHeight * 0.8 : newDimension
        return Double(newDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            if collectionView == parentCategoryCollectionView {
                if let cell = parentCategoryCollectionView?.dequeueReusableCell(withReuseIdentifier: "CoinCell", for: indexPath) as? CoinCell {
                    let category = parentCategories[indexPath.row]
                    cell.configureCell(name: category.name, amount: category.amount, color: category.color, currencySymbol: "$",dimensionRate: getDimensionParentCategoryCell(index: indexPath.row) / baseCategoryHeight, parent: true, selected: selectedParentCategory == indexPath.row)
                    return cell
                }
            } else {
                if let cell = childCategoryCollectionView?.dequeueReusableCell(withReuseIdentifier: "CoinCell", for: indexPath) as? CoinCell {
                    if let selectedParent = selectedParentCategory {
                        let category = childCategories[selectedParent][indexPath.row]
                        cell.configureCell(name: category.name, amount: category.amount, color: category.color, currencySymbol: "$",dimensionRate: childCategoryHeight / baseCategoryHeight, parent: false)
                        return cell
                    }
                }
            }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == parentCategoryCollectionView {
            return CGSize(width: getDimensionParentCategoryCell(index: indexPath.row), height: getDimensionParentCategoryCell(index: indexPath.row))
        } else {
            return CGSize(width: childCategoryHeight, height: childCategoryHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == parentCategoryCollectionView {
            selectedParentCategory = indexPath.row
            setCategoryContentWidth()
            parentCategoryCollectionView?.reloadData()
            childCategoryCollectionView?.reloadData()
        }
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cashTableView {
            return  cash.count
        } else {
            return cards.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if tableView == cashTableView {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell{
                    let cash = self.cash[indexPath.row]
                    cell.configureCell(name: cash.name, costs: cash.costs, income: cash.income, selected: selectedCashRow == indexPath.row, card: false, number: indexPath.row)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell{
                    let card = self.cards[indexPath.row]
                    cell.configureCell(name: card.name, costs: card.costs, income: card.income, selected: selectedCardsRow == indexPath.row, card: true, number: indexPath.row)
                    return cell
                }
            }

        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cashTableView {
            selectedCashRow = indexPath.row
            selectedCardsRow = nil
            fetchCategoryData(ByAccount: (name: cash[indexPath.row].name, id: cash[indexPath.row].id, costs: cash[indexPath.row].costs, income: cash[indexPath.row].income, rate: 1.0))
        } else {
            selectedCashRow = nil
            selectedCardsRow = indexPath.row
            fetchCategoryData(ByAccount: (name: cards[indexPath.row].name, id: cards[indexPath.row].id, costs: cards[indexPath.row].costs, income: cards[indexPath.row].income, rate: 1.0))
        }
        cashTableView.reloadData()
        cardsTableView.reloadData()
    }
    
   
}

