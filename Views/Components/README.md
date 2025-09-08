# SwiftUI Components Guide

## BottomTabView

A custom tab navigation component that matches the original design perfectly.

### Usage

```swift
BottomTabView()
    .environmentObject(appState)
```

### Features

- Three tabs: Studio, Preview, Feedback
- Active state management
- Custom icons and styling
- Seamless navigation integration

## SelectionField

Reusable form component for parameter selection.

### Usage

```swift
SelectionField(
    title: "Key",
    description: "Select a key",
    options: ["C", "D", "E", "F", "G", "A", "B", "N/A"],
    selection: $formData.key
)
```

### Features

- Bold title styling
- Descriptive text
- List of selectable options
- Active selection highlighting

## TempoSection

Specialized component for tempo selection with checkbox and number input.

### Usage

```swift
TempoSection()
    .environmentObject(midiFormData)
```

### Features

- Checkbox for N/A option
- Number input field
- BPM label
- Visual dropdown indicator

## HeaderView

Standardized header component for all main screens.

### Usage

```swift
HeaderView(title: "Generate", icon: "music.note")
```

### Features

- Consistent height (125pt)
- Icon + title layout
- Coustard font styling
- Safe area handling

## FeedbackFormField

Form field component with underline styling for feedback forms.

### Usage

```swift
FeedbackFormField(
    title: "Name",
    placeholder: "Enter your name",
    text: $feedbackData.name,
    focusedField: $focusedField,
    field: .name
)
```

### Features

- Underline text field style
- Focus state management
- Support for multiline text
- Keyboard type customization

## Color Extensions

Custom color handling for hex values.

### Usage

```swift
Color(hex: "00FF9D")  // Bright green
Color(hex: "79BEFF")  // Loading blue
Color(hex: "E6E6E6")  // Form borders
```

## Animation Patterns

### Gradient Orb Animation

```swift
.scaleEffect(animateGradient ? 1.05 : 1.0)
.animation(
    Animation.easeInOut(duration: 2.0)
        .repeatForever(autoreverses: true),
    value: animateGradient
)
```

### Progress Bar Animation

```swift
.animation(.easeOut(duration: 0.3), value: progress)
```

### Feature Reveal Animation

```swift
.opacity(isVisible ? 1.0 : 0.0)
.offset(x: isVisible ? 0 : 20)
.animation(.easeOut(duration: 0.6).delay(delay), value: isVisible)
```

## Best Practices

1. **State Management**: Use `@EnvironmentObject` for shared state
2. **Focus Management**: Implement `@FocusState` for form fields
3. **Animations**: Use consistent timing and easing
4. **Accessibility**: Add proper labels and hints
5. **Performance**: Use `LazyVStack` for long lists

## Styling Conventions

### Fonts

- **Headers**: `font(.custom("Coustard-Regular", size: 24))`
- **Body**: `font(.system(size: 16, weight: .regular))`
- **Labels**: `font(.system(size: 14, weight: .regular))`

### Colors

- **Text**: `.foregroundColor(.black)`
- **Backgrounds**: `Color.white`
- **Accents**: Custom hex colors

### Spacing

- **Sections**: 24pt vertical spacing
- **Components**: 12pt internal spacing
- **Form fields**: 8pt between label and input

## Testing Components

Test each component in isolation using SwiftUI previews:

```swift
struct ComponentName_Previews: PreviewProvider {
    static var previews: some View {
        ComponentName()
            .environmentObject(AppState())
            .environmentObject(MIDIFormData())
    }
}
```
