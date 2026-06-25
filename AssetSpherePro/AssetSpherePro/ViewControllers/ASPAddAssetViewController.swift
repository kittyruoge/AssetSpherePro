//
//  ASPAddAssetViewController.swift
//  AssetSpherePro
//
//  Adds a new asset using the shared form.
//

import UIKit

final class ASPAddAssetViewController: ASPAssetFormViewController {

    /// Called after a successful save.
    var onSaved: (() -> Void)?

    override func viewDidLoad() {
        // Seed a blank model before the form populates.
        workingAsset = ASPAssetModel()
        super.viewDidLoad()
        title = "New Asset"
        navigationItem.largeTitleDisplayMode = .never
    }

    override func asp_commit(_ asset: ASPAssetModel) -> Bool {
        let ok = ASPAssetManager.shared.asp_add(asset)
        if ok { onSaved?() }
        return ok
    }
}
