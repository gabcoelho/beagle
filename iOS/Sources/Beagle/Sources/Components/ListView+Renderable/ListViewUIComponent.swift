/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import BeagleSchema

private struct CellsContextManager {
    
    private var orphanCells = [Int: ListViewCell]()
    
    private var itemContexts = [Int: [String: DynamicObject]]()
    
    mutating func track(orphanCell cell: ListViewCell) {
        if let itemHash = cell.itemHash {
            orphanCells[itemHash] = cell
        }
    }
    
    mutating func reuse(cell: ListViewCell) {
        guard let itemHash = cell.itemHash else { return }
        itemContexts[itemHash] = cell.viewContexts.reduce(into: [:]) { result, entry in
            let (view, contexts) = entry
            for context in contexts {
                let value = view.getContextValue(context.id)
                result?[context.id] = value
            }
        }
        orphanCells.removeValue(forKey: itemHash)
    }
    
    mutating func contexts(for itemHash: Int) -> [String: DynamicObject]? {
        if let orphan = orphanCells[itemHash] {
            reuse(cell: orphan)
        }
        return itemContexts[itemHash]
    }
    
}

final class ListViewUIComponent: UIView {
    
    // MARK: - Properties
    
    private var cellsContextManager = CellsContextManager()
    private var itemsSize = [Int: CGSize]()
    
    let model: Model
    
    var items: [DynamicObject]? = [] {
        didSet {
            listController.collectionView.reloadData()
            onScrollEndExecuted = false
            executeOnScrollEndIfNeededAfterLayout()
        }
    }
    
    let listController: ListViewController
    
    private(set) var onScrollEndExecuted = false
    
    lazy var renderer = BeagleRenderer(controller: listController)
    
    // MARK: - Initialization
    
    init(model: Model, renderer: BeagleRenderer) {
        self.model = model
        self.listController = ListViewController(renderer: renderer)
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let layout = listController.collectionViewFlowLayout
        layout.scrollDirection = model.direction.scrollDirection
        
        let collection = listController.collectionView
        collection.dataSource = self
        collection.delegate = self
        
        let parentController = listController.renderer.controller
        parentController.addChild(listController)
        addSubview(listController.view)
        listController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listController.view.frame = bounds
        listController.didMove(toParent: parentController)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeOnScrollEndIfNeededAfterLayout()
    }
    
    // MARK: - Cell Sizing
    
    func saveSize(_ size: CGSize, forItem itemHash: Int) {
        itemsSize[itemHash] = size
    }
    
    func invalidateSize(cell: ListViewCell) {
        if listController.collectionView.indexPath(for: cell) != nil {
            listController.collectionViewFlowLayout.invalidateLayout()
        }
    }
    
    // MARK: - Handle Scroll
    
    private func executeOnScrollEndIfNeededAfterLayout() {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(executeOnScrollEndIfNeeded(displayLink:))
        )
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc private func executeOnScrollEndIfNeeded(displayLink: CADisplayLink) {
        displayLink.invalidate()
        executeOnScrollEndIfNeeded()
    }
    
    private func executeOnScrollEndIfNeeded() {
        guard !onScrollEndExecuted else { return }
        
        let collection = listController.collectionView
        let contentSize = collection.contentSize[keyPath: model.direction.sizeKeyPath]
        let contentOffset = collection.contentOffset[keyPath: model.direction.pointKeyPath]
        let offset = contentOffset + frame.size[keyPath: model.direction.sizeKeyPath]
        
        if (contentSize > 0) && (offset / contentSize * 100 >= model.scrollThreshold) {
            onScrollEndExecuted = true
            renderer.controller.execute(actions: model.onScrollEnd, origin: self)
        }
    }
}

// MARK: - Model
extension ListViewUIComponent {
    struct Model {
        var key: Path?
        var direction: ListView.Direction
        var template: RawComponent
        var iteratorName: String
        var onScrollEnd: [RawAction]?
        var scrollThreshold: CGFloat
        var useParentScroll: Bool
    }
}

// MARK: CollectionView Data Source

extension ListViewUIComponent: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListViewCell", for: indexPath)
        if let cell = cell as? ListViewCell, let item = items?[indexPath.item] {
            cellsContextManager.reuse(cell: cell)
            listController.delegate = cell
            
            let itemKey = keyFor(item)
            let hash = hashFor(item: item, withKey: itemKey)
            let key = itemKey ?? String(indexPath.item)
            let contexts = cellsContextManager.contexts(for: hash)
            
            cell.configure(hash: hash, key: key, item: item, contexts: contexts, listView: self)
        }
        return cell
    }
    
    private func keyFor(_ item: DynamicObject) -> String? {
        if let path = model.key {
            switch item[path] {
            case .int(let value):
                return String(value)
            case .double(let value):
                return String(value)
            case .string(let value):
                return value
            case .empty, .bool, .array, .dictionary, .expression:
                break
            }
        }
        return nil
    }
    
    private func hashFor(item: DynamicObject, withKey key: String?) -> Int {
        if let key = key {
            return key.hashValue
        }
        return item.hashValue
    }
}

// MARK: CollectionView Delegate

extension ListViewUIComponent: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        guard let items = items, indexPath.item < items.count else {
            return size
        }
        
        let item = items[indexPath.item]
        let itemKey = keyFor(item)
        let itemHash = hashFor(item: item, withKey: itemKey)
        
        if let calculatedSize = itemsSize[itemHash] {
            let keyPath = model.direction.sizeKeyPath
            size[keyPath: keyPath] = calculatedSize[keyPath: keyPath]
        }
        return size
    }
        
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ListViewCell {
            cellsContextManager.track(orphanCell: cell)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        executeOnScrollEndIfNeeded()
    }
}

final class ListViewController: UIViewController {
    
    weak var delegate: ListViewControllerDelegate?
    
    fileprivate lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewFlowLayout
        )
        collection.backgroundColor = .clear
        collection.register(ListViewCell.self, forCellWithReuseIdentifier: "ListViewCell")
        collection.translatesAutoresizingMaskIntoConstraints = true
        return collection
    }()
    
    fileprivate lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    let renderer: BeagleRenderer
    
    init(renderer: BeagleRenderer) {
        self.renderer = renderer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = collectionView
    }
}

protocol ListViewControllerDelegate: NSObjectProtocol {
    
    func listViewController(_: ListViewController, listIdentifierFor: String?) -> String?
    
    func listViewController(_: ListViewController, setContext: Context, in: UIView)
    
    func listViewController<T: Decodable>(_: ListViewController, bind: ContextExpression, view: UIView, update: @escaping (T?) -> Void)
    
    func listViewController(_: ListViewController, onInit: [RawAction], view: UIView)
}

extension ListViewController: BeagleControllerProtocol {
    
    var dependencies: BeagleDependenciesProtocol {
        return renderer.controller.dependencies
    }
    
    var serverDrivenState: ServerDrivenState {
        get { return renderer.controller.serverDrivenState }
        set { renderer.controller.serverDrivenState = newValue }
    }
    
    var screenType: ScreenType {
        return renderer.controller.screenType
    }
    
    var screen: Screen? {
        return renderer.controller.screen
    }
    
    public func setIdentifier(_ id: String?, in view: UIView) {
        let newId = delegate?.listViewController(self, listIdentifierFor: id)
        renderer.controller.setIdentifier(newId, in: view)
    }
    
    func setContext(_ context: Context, in view: UIView) {
        delegate?.listViewController(self, setContext: context, in: view)
    }
    
    func addBinding<T: Decodable>(expression: ContextExpression, in view: UIView, update: @escaping (T?) -> Void) {
        delegate?.listViewController(self, bind: expression, view: view, update: update)
    }
    
    func addOnInit(_ onInit: [RawAction], in view: UIView) {
        delegate?.listViewController(self, onInit: onInit, view: view)
    }
    
    func execute(actions: [RawAction]?, origin: UIView) {
        renderer.controller.execute(actions: actions, origin: origin)
    }
    
    func execute(actions: [RawAction]?, with contextId: String, and contextValue: DynamicObject, origin: UIView) {
        renderer.controller.execute(actions: actions, with: contextId, and: contextValue, origin: origin)
    }
}
