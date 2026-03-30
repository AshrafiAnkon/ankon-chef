# Recipe Saver & Finder - Complete Feature List

## Application Overview
**App Name**: Recipe Saver & Finder  
**Platform**: Flutter (Cross-platform: iOS, Android, Web)  
**Backend**: Firebase (Authentication, Firestore Database, Cloud Storage)  
**State Management**: Riverpod (hooks_riverpod)  
**Architecture**: MVVM with Providers

---

## 🔐 AUTHENTICATION & ONBOARDING

### 1. Login Screen (`/login`)
**Status**: ✅ Implemented

#### Features:
- **Google Sign-In Integration**
  - Platform-specific implementation (Mobile, Web, Stub)
  - Automatic user profile creation on first login
  - Google account linking with app  
- **UI Elements**:
  - Gradient background (Primary to Secondary colors)
  - App logo/icon display (120x120px)
  - "Sign in with Google" button
  - Responsive layout for mobile and desktop
- **Authentication Flow**:
  - Redirects to home if already logged in
  - Stores user session in Firebase Auth
  - Creates user profile in Firestore on first login
- **Error Handling**:
  - Network error messages
  - Authentication failure notifications

#### Widgets Used:
- `Container` (Gradient background)
- `SafeArea`, `LayoutBuilder` (Responsive design)
- `ElevatedButton` (Sign-in button)
- `CircularProgressIndicator` (Loading state)

#### Related Services:
- `auth_service.dart` - Firebase Authentication
- `google_auth_interface.dart` - Platform abstraction
- `google_auth_mobile.dart`, `google_auth_web.dart` - Platform implementations

---

## 🏠 HOME SCREEN & NAVIGATION

### 2. Home Screen (`/home`)
**Status**: ✅ Implemented

#### Features:
- **Welcome Section**
  - Personalized greeting with user's display name
  - User photo display from Google account
- **Quick Navigation Cards**
  - Recipes (View all recipes)
  - Create Recipe (Add new recipe)
  - Pantry (Manage ingredients)
  - Ingredients (Browse ingredient categories)
  - Meal Plan (Plan weekly/daily meals)
  - Filter Recipes (Smart recipe search)
- **Responsive Grid Layout**
  - 1 column on mobile (<600px width)
  - 2 columns on tablet (600-900px width)
  - 3 columns on desktop (>900px width)
  - Dynamic child aspect ratios based on screen size
- **AppBar Navigation**
  - Home button (refresh)
  - Logout button
- **Drawer Navigation**
  - Side menu with all available routes
  - Quick access to all features

#### Widgets Used:
- `GridView.builder` (Responsive card grid)
- `LayoutBuilder` (Media query alternative)
- `ConstrainedBox` (Max-width constraint for large screens)
- `Card` (Navigation menu items)
- `AppBar` with actions
- `MainDrawer` custom widget

#### State Management:
- `currentUserProfileProvider` - Watches logged-in user profile
- `authServiceProvider` - Provides authentication methods

---

## 📖 RECIPE MANAGEMENT

### 3. Recipes Screen (`/recipes`)
**Status**: ✅ Implemented

#### Features:
- **Recipe List Display**
  - Shows all user-created recipes
  - Grid/List view of recipes with images
  - Cached network images for performance
  - Recipe cards display: name, image, ingredient count
- **Search Functionality**
  - Real-time recipe search by name
  - Search field with icon
  - Provider: `searchRecipesProvider(_searchQuery)`
  - Debounced search (via provider)
- **Filter by Available Ingredients**
  - Toggle button to show only recipes with available pantry ingredients
  - Dynamic filtering based on pantry contents
  - Visual indicator when filter is active
- **Navigation**
  - Click recipe to view details
  - FAB to create new recipe
- **Empty State**
  - Message when no recipes exist
  - Suggestion to create first recipe

#### Widgets Used:
- `GridView.builder` (Recipe grid)
- `TextField` (Search input)
- `IconButton` (Filter toggle)
- `FloatingActionButton` (Create recipe)
- `CachedNetworkImage` (Optimized image loading)
- `Card` (Recipe items)
- `MainDrawer` (Navigation)

#### Providers:
- `userRecipesProvider` - Fetch all user recipes
- `searchRecipesProvider` - Search filtered recipes

#### Recipe Model Properties:
```
- id: Unique identifier
- userId: Recipe owner
- name: Recipe title
- ingredientIds: List of ingredient references
- instructions: Cooking instructions
- imageUrl: Recipe image from Firebase Storage
- tags: Recipe tags/categories
- createdAt: Timestamp
- updatedAt: Timestamp
```

---

### 4. Create Recipe Screen (`/recipes/create`)
**Status**: ✅ Implemented

#### Features:
- **Recipe Input Form**
  - Recipe name (Text field, required)
  - Instructions (Multi-line text field, required)
  - Tags (Comma-separated, add tag button, can add custom tags, can select predefined tags from added in tag management screen)
  - Form validation with visual feedback
- **Ingredient Selection**
  - Multi-select ingredient picker
  - Displays all available ingredients
  - Shows ingredient categories
  - Custom widget: `IngredientMultiSelect`
  - Validation: At least one ingredient required
- **Image Upload**
  - Pick image from gallery or by url with online image finder popup
  - Image preview before saving (for online image no need to save)
  - Upload to Firebase Storage
  - Compressed image handling
  - Image picker permissions handling
- **Submission**
  - Validate form before submission
  - Show loading indicator during upload
  - 15-second timeout for upload
  - Success notification and redirect to recipes list
  - Error handling with detailed messages
  - Show error notifications with 5-second duration
- **UI/UX**
  - Scrollable form content
  - Clear error messages
  - Tag pills display with delete option
  - Image preview display
  - Category-grouped ingredient picker

#### Widgets Used:
- `Form` + `FormField` (Validation)
- `TextFormField` (Name, instructions, tags)
- `LinearProgressIndicator` (Loading state)
- `IngredientMultiSelect` (Custom ingredient selector)
- `Image.memory` (Image preview)
- `FloatingActionButton` (Save button)
- `ScaffoldMessenger` / `SnackBar` (Notifications)

#### Providers:
- `allIngredientsProvider` - Fetch ingredient list
- `currentUserProvider` - Get logged-in user
- `recipeServiceProvider` - Access recipe creation service

#### Services:
- `recipeServiceProvider.createRecipe()` - Firebase service
- `image_picker` package - Image selection

---

### 5. Recipe Detail Screen (`/recipes/:id`)
**Status**: ✅ Implemented

#### Features:
- **Recipe Header**
  - Full-height hero image display
  - Collapsible app bar with image parallax
  - Recipe name overlay on image
  - Home and Edit buttons in app bar
- **Recipe Content**
  - Ingredient list with names and amounts
  - Cooking instructions
  - Display tags (if any)
  - Creation/update timestamps
- **Image Display**
  - Optimized with CachedNetworkImage
  - Fallback icon if no image
  - Responsive image scaling
- **Editing Capability**
  - Edit button routes to update screen
  - Delete recipe option
  - Confirmation dialogs for destructive actions
- **Navigation**
  - Back navigation
  - Home button
  - Edit button

#### Widgets Used:
- `CustomScrollView` + `SliverAppBar` (Parallax effect)
- `FlexibleSpaceBar` (Flexible image header)
- `SliverList` (Scrollable content area)
- `CachedNetworkImage` (Optimized images)
- `Chip` (Tags display)
- `ExpansionTile` (Ingredient sections)

#### Providers:
- `recipeByIdProvider(id)` - Fetch specific recipe
- `allIngredientsProvider` - Resolve ingredient names

#### Data Resolution:
- Recipe ID passed as route parameter
- Resolves ingredient IDs to names and details
- Displays human-readable ingredient information

---

## 🛒 PANTRY MANAGEMENT

### 6. Pantry Screen (`/pantry`)
**Status**: ✅ Implemented

#### Features:
- **Pantry Item List**
  - Display all stored pantry items
  - Shows ingredient name, amount, unit, and dates
  - Cards display for each item
  - Empty state message with add instructions
- **Item Information**
  - Ingredient name (resolved from ingredient ID)
  - Quantity with unit (kg, g, L, pieces, etc.)
  - Added date display
  - Expiry date display (if applicable)
- **Expiry Tracking**
  - Visual indicators for expiring items
  - "Expiring Soon" badge for items within 3 days of expiry
  - "Expired" badge for past-expiry items
  - Color-coded: warning color for expiring, error color for expired
- **Item Management**
  - Delete pantry item button
  - Edit pantry item (amount/expiry update)
  - Update quantity and expiry date
  - Confirmation for deletions
- **Add Items Section**
  - `SearchableIngredientSelector` widget
  - Ingredient quantity input
  - Unit dropdown selector
  - Optional expiry date picker
  - Add to pantry button
- **UI/UX**
  - Card-based layout
  - Ingredient icons/avatars
  - Swipe-to-delete gesture support (if implemented)
  - Organized list with dates

#### Widgets Used:
- `ListView.builder` (Item list)
- `Card` (Item display)
- `PantryItemCard` (Custom item card)
- `SearchableIngredientSelector` (Custom add item widget)
- `TextField` (Quantity input)
- `DropdownButton` (Unit selector)
- `DatePicker` (Expiry date)
- `Chip` / `Badge` (Status indicators)

#### Providers:
- `pantryItemsProvider` - Fetch user's pantry items
- `allIngredientsProvider` - Resolve ingredient details
- `pantryServiceProvider` - Pantry management service

#### PantryItem Model Properties:
```
- id: Unique identifier
- userId: Owner
- ingredientId: Reference to ingredient
- amount: Quantity (double)
- unit: Measurement unit
- addedDate: When item was added
- expiryDate: Optional expiry date
- isExpiringSoon: Computed (3 days buffer)
- isExpired: Computed property
```

---

## 🥘 INGREDIENT MANAGEMENT

### 7. Ingredients Screen (`/ingredients`)
**Status**: ✅ Implemented

#### Features:
- **Ingredient Browsing**
  - View all available ingredients in the app
  - Ingredients grouped by category:
    - Vegetables
    - Proteins
    - Grains
    - Spices
    - Oils & Condiments
    - Dairy
    - Fruits
    - Baking
    - etc.
  - Category headers with collapse/expand
- **Add to Pantry Interface**
  - Each ingredient has associated fields:
    - Quantity input (text field, numeric)
    - Unit selector (kg, g, L, mL, pieces, cups, tbsp, tsp, etc.)
    - Optional expiry date picker
  - "Add to Pantry" button per ingredient
  - Single or batch add operations
- **Ingredient Information**
  - Ingredient name
  - Category display
  - Icon/avatar for ingredient
- **Form Validation**
  - Validate quantity is positive number
  - Validate unit is selected
  - Error messages for invalid input
  - Success notification after adding
- **Navigation**
  - Home button
  - Drawer access to other screens

#### Widgets Used:
- `ListView` (Scrollable ingredient list)
- `ExpansionTile` (Category sections)
- `IngredientShoppingRow` (Custom ingredient row widget)
- `TextField` (Quantity input)
- `DropdownButton` (Unit selector)
- `DatePicker` (Expiry date)
- `ElevatedButton` (Add to pantry)
- `MainDrawer` (Navigation)

#### Providers:
- `allIngredientsProvider` - Fetch all available ingredients
- `currentUserProvider` - Ensure user logged in
- `pantryServiceProvider` - Add items to pantry

#### Ingredient Model Properties:
```
- id: Unique identifier
- name: Ingredient name
- category: Category classification
```

---

## 🍽️ MEAL PLANNING

### 8. Meal Plan Screen (`/meal-plan`)
**Status**: ✅ Implemented

#### Features:
- **Date Selection**
  - Calendar picker for meal plan date
  - Shows selected date in readable format (e.g., "Monday, March 28, 2026")
  - Date range: Today to 30 days in future
  - Visual calendar widget
- **Daily Meal View**
  - Display meal plan for selected date
  - Shows all recipes planned for that day
  - Each recipe displays: name, ingredient count
  - Grouped by meal type (if planned)
- **Add Recipes to Plan**
  - Dialog to select recipes to add
  - Multi-select recipe picker
  - Shows recipe names and ingredient counts
  - Apply button to confirm selection
- **Planned Recipes Display**
  - Card-based recipe display
  - Recipe icon/image
  - Recipe name
  - Ingredient count
  - Delete recipe from plan button
- **Ingredient Summary**
  - Aggregated ingredient list for all recipes in plan
  - Ingredient count with unit
  - Helps user plan shopping/cooking
- **Empty State**
  - Message when no meal plan exists
  - Call-to-action to create meal plan
- **UI Elements**
  - Date selector card with calendar icon
  - FAB for "Plan Meal" action
  - Recipe cards layout
  - Scrollable content area

#### Widgets Used:
- `Card` (Date selector)
- `ListTile` (Date display with dropdown)
- `showDatePicker()` (Calendar widget)
- `Expanded` + `ListView` (Scrollable content)
- `FloatingActionButton.extended` (Add meal button)
- `AlertDialog` (Recipe selection)
- `MultiSelectListView` or custom multi-select

#### Providers:
- `mealPlanForDateProvider(_selectedDate)` - Get meal plan for specific date
- `userRecipesProvider` - Get available recipes for selection
- `currentIngredientIdsProvider` - User's current ingredients
- `mealPlanServiceProvider` - Meal plan operations
- `currentUserProvider` - Ensure user logged in

#### MealPlan Model Properties:
```
- id: Unique identifier
- userId: Plan owner
- planDate: Target date for meal plan
- recipeIds: List of recipe IDs in plan
- createdAt: Timestamp
```

#### Planned Features/Enhancements:
- Grocery list generation from meal plan
- Ingredient shopping checklist
- Auto-populate pantry from meal plan
- Meal substitution suggestions
- Nutritional information aggregation

---

## 🔍 RECIPE FILTERING & SEARCH

### 9. Filter Recipes Screen (`/filter-recipes`)
**Status**: ✅ Implemented

#### Features:
- **Multiple Filter Options**
  1. **Pantry-Only Filter**: Show only recipes that can be made with current pantry items
  2. **Custom Ingredient Filter**: Filter by specific selected ingredients
  3. **Match Mode Toggle**: All ingredients required vs. Any ingredient matches

- **Filter Interface**
  - Drawer-based filter controls
  - Toggle switches for filter types
  - Ingredient multi-select widget
  - Match mode radio buttons
  - Clear filters button
- **Recipe Display**
  - Filtered recipe list/grid
  - Real-time filter application
  - Update display as filters change
  - Show recipe count matching filters
- **Empty State**
  - Message when no recipes match filters
  - Suggestion to adjust filter criteria
- **UI/UX**
  - AppBar with menu toggle
  - Drawer with all filter options
  - Easy-to-use filter controls
  - Visual feedback for active filters

#### Widgets Used:
- `Scaffold` with drawer
- `Switch` (Toggle filters)
- `PantryIngredientMultiSelect` (Custom ingredient selector)
- `RadioGroup` or `RadioListTile` (Match mode)
- `ElevatedButton` (Clear filters)
- `ListView.builder` (Recipe results)
- `FilterIcon` indicator (Active filter visual)

#### Providers:
- `filteredRecipesProvider(FilterOptions)` - Apply filters
- `pantryIngredientsProvider` - Available pantry items
- `allIngredientsProvider` - All ingredients for selection
- `userRecipesProvider` - Base recipe list

#### Filter Logic:
**Pantry-Only Mode**:
- Shows recipes where ALL ingredients exist in user's pantry
- Useful for: "What can I make with what I have?"

**Custom Ingredient Filter** with Match Mode:
- **Match All Mode**: Recipes MUST contain ALL selected ingredients
  - Use case: "Find recipes with chicken AND rice"
  - Higher specificity, fewer results
- **Match Any Mode**: Recipes containing AT LEAST ONE selected ingredient
  - Use case: "Find recipes I can make with any of these items"
  - Broader results, more options

#### FilterOptions Model:
```dart
class FilterOptions {
  final bool pantryIngredientsOnly;        // Filter 1: Pantry only
  final bool filterByChoice;               // Filter 2: Custom ingredients
  final List<String> selectedIngredientIds; // Which ingredients selected
  final bool matchAll;                     // Filter logic: all vs any
}
```

#### Real-time Filtering:
- UI-level filtering in `_FilterRecipesScreenState`
- Filters applied to `userRecipesProvider` results
- Instant visual feedback as filters change
- No separate API calls for filtering

---

## 👤 USER PROFILE & SETTINGS

### Features Implemented:
- **User Profile Data**
  - Display name (from Google account)
  - Email
  - Profile photo (from Google account)
  - Account creation date
- **Profile Provider**
  - `currentUserProfileProvider` - Stream user profile updates
  - `currentUserProvider` - Firebase Auth user
- **Logout Functionality**
  - Logout button on home screen
  - Sign out from Firebase
  - Redirect to login screen

#### User Model Properties:
```
- uid: Firebase user ID
- email: User email
- displayName: Display name
- photoUrl: Profile picture URL
- createdAt: Account creation date
```

#### Planned Features:
- User settings screen
- Notification preferences
- App theme selection (light/dark/system)
- Language preferences
- Privacy settings
- Account deletion

---

## 🎨 UI/UX COMPONENTS

### Architecture & Styling:
- **Theme System** (`app_theme.dart`)
  - Light theme
  - Dark theme (structure prepared)
  - Themable colors in `AppColors`
  - Text styles in `AppTextStyles`

- **App Colors** (`app_colors.dart`)
  - Primary: Primary brand color
  - Secondary: Secondary accent
  - Accent: Additional highlights
  - Success, Error, Warning states
  - Text colors (primary, secondary, tertiary)
  - Background colors
  - Border colors

- **Text Styles** (`app_text_styles.dart`)
  - Headline styles (h1-h4)
  - Body styles (large, medium, small)
  - Caption and label styles
  - Custom text themes

### Common Widgets:
1. **MainDrawer** - Navigation drawer used on all screens
2. **IngredientMultiSelect** - Multi-select ingredient picker
3. **PantryIngredientMultiSelect** - Pantry-specific multi-select
4. **SearchableIngredientSelector** - Searchable ingredient picker
5. **IngredientShoppingRow** - Ingredient row with quantity/unit
6. **PantryItemCard** - Pantry item display card

---

## 📱 RESPONSIVE DESIGN

### Breakpoints:
- **Mobile**: < 600px width
  - Single column layouts
  - Bottom navigation/drawer
  - Full-width cards
- **Tablet**: 600px - 900px width
  - 2-column grids
  - Wider padding
  - Side drawer navigation
- **Desktop**: > 900px width
  - 3-column grids
  - Max-width containers (1000px)
  - Horizontal menus

### Implementation:
- `LayoutBuilder` for responsive logic
- `ConstrainedBox` for max-width constraints
- Dynamic `GridView` column counts
- Aspect ratio adjustments per breakpoint
- `SafeArea` for notch/systemui handling

---

## 🔐 Authentication & Authorization

### Features:
- **Google Sign-In**
  - OAuth 2.0 with Google
  - Cross-platform implementation
  - Automatic profile creation
- **Session Management**
  - Firebase Auth persistence
  - Automatic login redirect
  - Session expiry handling
- **Route Protection**
  - Redirect unauthenticated users to login
  - Redirect authenticated users away from login
  - Protected routes: /home, /recipes, /pantry, /ingredients, /meal-plan, /filter-recipes

---

## 🗄️ DATA MODELS & DATABASE

### Firestore Collections:
1. **users/** - User profiles
   - email, displayName, photoUrl, createdAt
2. **ingredients/** - Ingredient master data
   - name, category
3. **recipes/** - User recipes
   - userId, name, ingredientIds, instructions, imageUrl, tags, createdAt, updatedAt
4. **pantryItems/** - User's pantry inventory
   - userId, ingredientId, amount, unit, addedDate, expiryDate
5. **mealPlans/** - User's meal plans
   - userId, planDate, recipeIds, createdAt

### Storage:
- Firebase Storage for recipe images
- Images organized by user ID and recipe ID
- Cached with `cached_network_image` package

---

## 🔧 STATE MANAGEMENT (Riverpod)

### Key Providers:

#### Authentication:
- `authServiceProvider` - Firebase authentication service
- `currentUserProvider` - Current authenticated user
- `currentUserProfileProvider` - User profile with bio/settings
- `authStateProvider` - Stream of auth state changes

#### Recipes:
- `userRecipesProvider` - All user's recipes (cached)
- `recipeByIdProvider(id)` - Single recipe by ID
- `searchRecipesProvider(query)` - Search recipes by name
- `recipeServiceProvider` - Recipe service (CRUD)

#### Ingredients:
- `allIngredientsProvider` - All available ingredients (shared)
- `ingredientServiceProvider` - Ingredient service
- `currentIngredientIdsProvider` - User's ingredient preferences

#### Pantry:
- `pantryItemsProvider` - User's pantry items
- `pantryIngredientsProvider` - Detailed pantry with ingredient names
- `pantryServiceProvider` - Pantry service (CRUD)

#### Meal Plans:
- `mealPlanForDateProvider(date)` - Meal plan for specific date
- `mealPlanServiceProvider` - Meal plan service (CRUD)

#### Filtering:
- `filteredRecipesProvider(FilterOptions)` - Apply filters to recipes
- `FilterOptions` - Configuration for recipe filtering

---

## 🧪 TESTING

### Test Files Present:
- `create_recipe_flow_test.dart` - End-to-end recipe creation
- `filter_recipe_provider_test.dart` - Filter provider logic
- `filter_recipes_screen_test.dart` - Filter screen UI
- `ingredient_multi_select_test.dart` - Multi-select widget
- `widget_test.dart` - General widget tests
- `models/*_test.dart` - Model serialization tests

### Testing Framework:
- Flutter test framework
- Riverpod testing utilities
- Mockito for mocking dependencies
- Golden tests (if applicable)

---

## 📊 PLANNED/FUTURE FEATURES

### High Priority:
- [ ] Edit existing recipes
- [ ] Delete recipes (with confirmation)
- [ ] Advanced recipe search (by tags, cuisine, difficulty)
- [ ] Recipe ratings and reviews
- [ ] Favorite/bookmark recipes
- [ ] Share recipes with other users
- [ ] Shopping list generation from meal plan
- [ ] Export meal plans/recipes

### Medium Priority:
- [ ] User profile settings page
- [ ] Theme customization (dark mode)
- [ ] Nutritional information display
- [ ] Dietary restriction filtering (vegan, gluten-free, etc.)
- [ ] Recipe difficulty levels (easy, medium, hard)
- [ ] Prep/cook time estimates
- [ ] Serving size calculator
- [ ] Recipe scaling for ingredients

### Low Priority:
- [ ] Social features (follow other users, view their recipes)
- [ ] Community recipe sharing
- [ ] Recipe recommendations (AI)
- [ ] Integrated nutrition calculator
- [ ] Barcode scanning for pantry items
- [ ] Voice input for hands-free operation
- [ ] Offline mode with local storage sync
- [ ] Multi-language support

---

## 📦 DEPENDENCIES

### Core:
- `flutter` - UI framework
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage

### State Management:
- `flutter_riverpod` - State management
- `hooks_riverpod` - Hooks for Riverpod
- `riverpod_annotation` - Code generation

### Navigation:
- `go_router` - Flutter routing

### UI:
- `cached_network_image` - Optimized image loading
- `google_sign_in` - Google auth UI
- `image_picker` - Photo selection

### Utilities:
- `equatable` - Value equality
- `intl` - Internationalization (dates, numbers)

---

## 🏗️ PROJECT STRUCTURE

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase config
├── seed.dart                 # Demo data
│
├── models/                   # Data models
│   ├── recipe_model.dart
│   ├── ingredient_model.dart
│   ├── pantry_item_model.dart
│   ├── meal_plan_model.dart
│   └── user_model.dart
│
├── services/                 # Firebase services
│   ├── auth_service.dart
│   ├── recipe_service.dart
│   ├── ingredient_service.dart
│   ├── pantry_service.dart
│   ├── meal_plan_service.dart
│   └── google_auth_*.dart    # Platform-specific
│
├── providers/                # Riverpod providers
│   ├── auth_provider.dart
│   ├── recipe_provider.dart
│   ├── ingredient_provider.dart
│   ├── pantry_provider.dart
│   ├── meal_plan_provider.dart
│   └── filter_recipe_provider.dart
│
├── router/                   # Navigation
│   └── app_router.dart
│
└── ui/                       # User interface
    ├── screens/              # Full screens
    │   ├── login_screen.dart
    │   ├── home_screen.dart
    │   ├── recipes_screen.dart
    │   ├── create_recipe_screen.dart
    │   ├── recipe_detail_screen.dart
    │   ├── ingredients_screen.dart
    │   ├── pantry_screen.dart
    │   ├── meal_plan_screen.dart
    │   └── filter_recipes_screen.dart
    │
    ├── widgets/              # Reusable widgets
    │   ├── main_drawer.dart
    │   ├── ingredient_multi_select.dart
    │   ├── pantry_ingredient_multi_select.dart
    │   ├── searchable_ingredient_selector.dart
    │   ├── ingredient_shopping_row.dart
    │   └── pantry_item_card.dart
    │
    └── theme/                # Styling
        ├── app_theme.dart
        ├── app_colors.dart
        └── app_text_styles.dart
```

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Screens** | 9 |
| **Models** | 5 |
| **Services** | 5 |
| **Providers** | 10+ |
| **Custom Widgets** | 6+ |
| **Routes** | 9 |
| **Features** | 25+ |
| **Test Files** | 8+ |

---

## Implementation Status Legend
- ✅ Implemented & Tested
- 🔄 In Development
- 📋 Planned
- ⏳ Pending Dependencies
