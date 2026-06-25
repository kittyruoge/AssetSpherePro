//
//  ASPEditAssetViewController.swift
//  AssetSpherePro
//
//  Edits an existing asset using the shared form.
//

import UIKit

final class ASPEditAssetViewController: ASPAssetFormViewController {

    /// Called after a successful update.
    var onSaved: (() -> Void)?

    private let editingAsset: ASPAssetModel

    init(asset: ASPAssetModel) {
        self.editingAsset = asset
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        workingAsset = editingAsset
        super.viewDidLoad()
        title = "Edit Asset"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func asp_commit(_ asset: ASPAssetModel) -> Bool {
        let ok = ASPAssetManager.shared.asp_update(asset)
        if ok { onSaved?() }
        return ok
    }
}
