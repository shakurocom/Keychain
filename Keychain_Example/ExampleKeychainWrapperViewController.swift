//
// Copyright (c) 2018 Shakuro (https://shakuro.com/)
// Sergey Laschuk
//

import UIKit
import Keychain_Framework
import Shakuro_CommonTypes

private struct KeychainData: Codable {
    internal let value1: String
    internal let value2: String
}

internal class ExampleKeychainWrapperViewController: UIViewController {

    private enum Constant {
        static let defaultServiceName: String = "com.shakuro.Keychain-Example"
        static let defaultItemId: String = "test_data"
    }

    @IBOutlet private var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var serviceNameLabel: UILabel!
    @IBOutlet private var itemIdLabel: UILabel!
    @IBOutlet private var value1TextField: UITextField!
    @IBOutlet private var value2TextField: UITextField!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var restoreButton: UIButton!
    @IBOutlet private var removeButton: UIButton!

    private var keyboardHandler: KeyboardHandler?

    // MARK: - Initialization

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("KeychainWrapper", comment: "")

        serviceNameLabel.text = Constant.defaultServiceName
        itemIdLabel.text = Constant.defaultItemId

        saveButton.isExclusiveTouch = true
        restoreButton.isExclusiveTouch = true
        removeButton.isExclusiveTouch = true

        keyboardHandler = KeyboardHandler(enableCurveHack: false, heightDidChange: { (change: KeyboardHandler.KeyboardChange) in
            UIView.animate(
                withDuration: change.animationDuration,
                delay: 0.0,
                animations: {
                    self.scrollViewBottomConstraint.constant = change.newHeight
                    self.view.layoutIfNeeded()
            },
                completion: nil)
        })

        restoreDataFromKeychain()
    }

    // MARK: - Events

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardHandler?.isActive = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardHandler?.isActive = false
    }

    // MARK: - Interface callbacks

    @IBAction private func saveButtonTapped() {
        saveDataToKeychain()
    }

    @IBAction private func restoreButtonTapped() {
        restoreDataFromKeychain()
    }

    @IBAction private func removeButtonTapped() {
        removeDataFromKeychain()
    }

    // MARK: - Private

    private func restoreDataFromKeychain() {
        do {
            let keychainItem: KeychainWrapper.Item<KeychainData>? = try KeychainWrapper.keychainItem(serviceName: Constant.defaultServiceName, account: Constant.defaultItemId)
            value1TextField.text = keychainItem?.secValue.value1
            value2TextField.text = keychainItem?.secValue.value2
        } catch let error {
            showErrorAlert(error: error)
        }
    }

    private func removeDataFromKeychain() {
        do {
            try KeychainWrapper.removeKeychainItem(serviceName: Constant.defaultServiceName, account: Constant.defaultItemId)
        } catch let error {
            showErrorAlert(error: error)
        }
    }

    private func saveDataToKeychain() {
        do {
            let keychainData = KeychainData(value1: value1TextField.text ?? "", value2: value2TextField.text ?? "")
            let keychainItem = KeychainWrapper.Item(serviceName: Constant.defaultServiceName, account: Constant.defaultItemId, itemName: nil, accessGroup: nil, secValue: keychainData)
            try KeychainWrapper.saveKeychainItem(keychainItem)
        } catch let error {
            showErrorAlert(error: error)
        }
    }

    private func showErrorAlert(error: Error) {
        let title: String = "Error"
        let message: String
        switch error {
        case let keychainError as KeychainWrapper.Error:
            message = "\(keychainError)"
        case let nsError as NSError:
            message = nsError.localizedDescription
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}

// MARK: - UITextFieldDelegate

extension ExampleKeychainWrapperViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}
