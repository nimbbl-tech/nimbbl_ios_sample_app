# Code Organization - NimbblCheckout

## Overview
The codebase has been reorganized into smaller, focused files to improve maintainability and readability. Each file has a specific responsibility and can be easily tested and modified.

## File Structure

### 1. **ViewController.swift** (Main Controller)
- **Responsibility**: Main view controller handling UI lifecycle and coordination
- **Size**: Reduced from 1262 lines to ~800 lines
- **Key Functions**:
  - View lifecycle management
  - UI setup coordination
  - Action handling
  - Keyboard management

### 2. **UIComponents.swift** (UI Utilities)
- **Responsibility**: UI component styling and configuration
- **Key Features**:
  - Button styling extensions
  - Text field configuration
  - Label styling
  - UI constants and colors
  - Font utilities

### 3. **PaymentManager.swift** (Payment Logic)
- **Responsibility**: Payment-related state management and business logic
- **Key Features**:
  - Payment options management
  - Currency handling
  - Order creation logic
  - Payment validation
  - Debug information

### 4. **UserDetailsManager.swift** (User Details)
- **Responsibility**: User details management and validation
- **Key Features**:
  - Text field management
  - User input validation
  - UI state management
  - Data formatting for API

### 5. **AppConstants.swift** (Constants)
- **Responsibility**: Application-wide constants and configuration
- **Key Features**:
  - API endpoints
  - Image names
  - Text constants
  - Color values
  - Validation rules

### 6. **NetworkManager.swift** (Network Layer)
- **Responsibility**: Network requests and API communication
- **Key Features**:
  - Order creation API calls
  - Environment configuration
  - Error handling
  - Response parsing

### 7. **Config.swift** (Configuration)
- **Responsibility**: App configuration and UserDefaults extensions
- **Key Features**:
  - Environment enums
  - Experience modes
  - Payment modes
  - Header options

## Benefits of New Organization

### ✅ **Maintainability**
- Each file has a single responsibility
- Easier to locate and modify specific functionality
- Reduced cognitive load when working on specific features

### ✅ **Testability**
- Business logic separated from UI
- Network layer isolated for testing
- Validation logic can be unit tested

### ✅ **Reusability**
- UI components can be reused across different screens
- Payment logic can be shared between different flows
- Constants prevent duplication

### ✅ **Readability**
- Smaller, focused files are easier to understand
- Clear separation of concerns
- Consistent naming conventions

### ✅ **Scalability**
- Easy to add new payment methods
- Simple to extend validation rules
- Modular structure supports feature additions

## Usage Examples

### Using PaymentManager
```swift
// In ViewController
let paymentManager = PaymentManager.shared
paymentManager.selectedPaymentOption = paymentOptions[0]
paymentManager.amountValue = "10.0"

// Create order request
let requestBody = paymentManager.createOrderRequest()
```

### Using UserDetailsManager
```swift
// In ViewController
let userManager = UserDetailsManager.shared
userManager.setupTextFields(name: nameTextField, number: numberTextField, email: emailTextField, stack: stackView, switchControl: userDetailsSwitch)

// Validate user details
let (isValid, errorMessage) = userManager.validateUserDetails()
```

### Using NetworkManager
```swift
// In ViewController
NetworkManager.shared.createOrder(requestBody: requestBody) { result in
    switch result {
    case .success(let orderResponse):
        // Handle success
    case .failure(let error):
        // Handle error
    }
}
```

### Using UI Components
```swift
// Configure buttons
paymentButton.configurePaymentButton()
payNowButton.configurePayNowButton()

// Configure text fields
amountTextField.configureAmountTextField()
nameTextField.configurePaymentTextField()
```

## Migration Notes

### What Changed
1. **Extracted UI styling** into `UIComponents.swift`
2. **Moved payment logic** into `PaymentManager.swift`
3. **Separated user details** into `UserDetailsManager.swift`
4. **Centralized constants** in `AppConstants.swift`
5. **Isolated network calls** in `NetworkManager.swift`

### What Remains in ViewController
- UI setup coordination
- Action handling
- View lifecycle management
- Keyboard handling
- Constraint setup

### Benefits Achieved
- **Reduced file size**: Main controller is now ~40% smaller
- **Better separation**: Each file has a clear purpose
- **Easier testing**: Business logic is isolated
- **Improved maintainability**: Changes are localized to specific files

## Future Improvements

### Potential Next Steps
1. **Create ViewModels** for MVVM architecture
2. **Add Unit Tests** for business logic
3. **Implement Dependency Injection** for better testability
4. **Add Documentation** for complex methods
5. **Create Protocols** for better abstraction

### Code Quality Improvements
- Add input validation
- Implement proper error handling
- Add loading states
- Improve accessibility
- Add analytics tracking

This organization makes the codebase more professional, maintainable, and ready for future enhancements. 