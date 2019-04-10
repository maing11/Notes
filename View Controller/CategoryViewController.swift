//
//  CategoryViewController.swift
//  Things+
//
//  Created by Larry Nguyen on 3/28/19.
//  Copyright © 2019 Larry. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    weak var collectionView: UICollectionView!
    
    lazy var collectionViewLayout : UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (screenWidth - 30)/2, height: (screenWidth)/2 + 10)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return layout
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var selectedCategory: Category = .Today
    
    var categories: [Category] {
        return Category.allCategories()
    }
    
    var catCount: [Category: Int] = [:]
    
    private var bottomPullView: BottomPullView!
    private var earthTipView: EarthTipDetailView!
    
    private var bottomViewToViewConstraint: NSLayoutConstraint!
    private var originalBottomTopConstant: CGFloat = 0.0
    private var upgradeCollectionHeightConstraint: NSLayoutConstraint!
    
    private var earthDetailViewHeightConstraint: NSLayoutConstraint!
    
    let realmDataPersistence: RealmDataPersistence
    
    init(realmDataPersistence: RealmDataPersistence) {
        self.realmDataPersistence = realmDataPersistence
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        setupCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
     
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Note Stack"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
      
        collectionView.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: CategoryCollectionCell.identifier)
      
        NotificationCenter.default.addObserver(self, selector: #selector(notesDidUpdate), name: .noteDataChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryCatetoryItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidLayoutSubviews()
    }
    
    fileprivate func setupCollectionView(){
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        
        self.collectionView = collectionView
    }
    
    
    @objc func didTapCompose() {
        self.navigationController?.pushViewController(NoteDetailController(realmDataPersistence: self.realmDataPersistence, category: self.selectedCategory), animated: true)
    }
    
    @objc func notesDidUpdate() {
        print ("NotesViewController: Note Data Changed")
        self.collectionView.reloadData()
    }
    
    private func queryCatetoryItems(){
        for cat in self.categories {
            let count = realmDataPersistence.notesWithFilter(category: cat, filter: "").count
            catCount[cat] = count
        }
        
    }
}

extension CategoryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategory = categories[indexPath.row]
        let noteController = NotesViewController(realmDataPersistence: self.realmDataPersistence, category: self.selectedCategory)
        self.navigationController?.pushViewController(noteController, animated: true)
    }

}


extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionCell.identifier, for: indexPath) as! CategoryCollectionCell
        cell.category = self.categories[indexPath.row]
        if let cat = cell.category, let count = catCount[cat] {
             cell.categoryView.countLabel.text = "\(count)"
        }
        cell.actionButtonClosure = { [unowned self] in
            self.selectedCategory = self.categories[indexPath.row]
            let noteController = NoteDetailController(realmDataPersistence: self.realmDataPersistence, category: self.selectedCategory)
            self.navigationController?.pushViewController(noteController, animated: true)
        }
        
        cell.layoutIfNeeded()
        return cell
    }

}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 || indexPath.row == 6 {
              return CGSize(width: collectionView.bounds.size.width - 20, height: 150)
        } else {
            return CGSize(width: (screenWidth - 30)/2, height: (screenWidth)/2 + 10)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 16)
    }

}
