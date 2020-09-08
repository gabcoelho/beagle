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

protocol ListViewControllerDelegate: NSObjectProtocol {
    
    func listViewController(_: ListViewController, listIdentifierFor: String?) -> String?
    
    func listViewController(_: ListViewController, setContext: Context, in: UIView)
    
    func listViewController<T: Decodable>(_: ListViewController, bind: ContextExpression, view: UIView, update: @escaping (T?) -> Void)
    
    func listViewController(_: ListViewController, onInit: [RawAction], view: UIView)
}

final class ListViewController: UIViewController {
    
    weak var delegate: ListViewControllerDelegate?
    
    private(set) lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewFlowLayout
        )
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = true
        return collection
    }()
    
    private(set) lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }()
    
    let renderer: BeagleRenderer
    
    private weak var beagleController: BeagleController?
    
    init(renderer: BeagleRenderer) {
        self.renderer = renderer
        self.beagleController = renderer.controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = collectionView
    }
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
        return beagleController?.screen
    }
    
    public func setIdentifier(_ id: String?, in view: UIView) {
        let newId = delegate?.listViewController(self, listIdentifierFor: id)
        beagleController?.setIdentifier(newId, in: view)
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
        beagleController?.execute(actions: actions, origin: origin)
    }
    
    func execute(actions: [RawAction]?, with contextId: String, and contextValue: DynamicObject, origin: UIView) {
        beagleController?.execute(actions: actions, with: contextId, and: contextValue, origin: origin)
    }
    
    func setNeedsLayout(component: UIView) {
        component.yoga.markDirty()
        collectionViewFlowLayout.invalidateLayout()
    }
}
