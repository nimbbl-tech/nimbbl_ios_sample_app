/*
Created by Sandeep Y.  on 07/07/25.
Copyright (c) 2025 Bigital Technologies Pvt. Ltd. All rights reserved.
*/
import UIKit

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Scroll to the active text field with some padding
        let textFieldFrame = textField.convert(textField.bounds, to: scrollView)
        let padding: CGFloat = 20 // Add some padding above the text field
        let scrollPoint = CGPoint(x: 0, y: textFieldFrame.origin.y - padding)
        // Ensure we don't scroll beyond the content bounds
        let maxScrollY = scrollView.contentSize.height - scrollView.frame.height
        let finalScrollY = min(scrollPoint.y, maxScrollY)
        let finalScrollPoint = CGPoint(x: 0, y: max(0, finalScrollY))
        scrollView.setContentOffset(finalScrollPoint, animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
} 