# Recipe Saver & Finder - Functional Features

## Application Overview
**App Name**: Recipe Saver & Finder  
**Platform**: Flutter (iOS, Android, Web)  
**Backend**: Firebase (Authentication, Firestore Database, Cloud Storage)  
**State Management**: Riverpod  
**Architecture**: MVVM with Providers

---

## 🔐 AUTHENTICATION & ONBOARDING

### 1. Google Sign-In
Users can authenticate using their Google account credentials.

**Functionality:**
- Sign in with Google account credentials
- Platform-specific implementation for mobile and web platforms
- Automatic user profile creation on first login
- User session stored in Firebase Authentication
- Different authentication flows for iOS, Android, and web
- Network error handling and retry mechanisms

**Workflow:**
1. User enters login screen
2. User taps "Sign in with Google"
3. System routes to platform-specific Google authentication
4. Google authentication dialog appears to user
5. User authorizes app access to Google account
6. User profile created in Firestore (first login only)
7. User authenticated and redirected to home screen
8. Subsequent logins skip profile creation

**Error Handling:**
- Network connection failures display error messages
- Authentication cancellation handled gracefully
- Failed authentication shows retry option

---

## 🏠 HOME SCREEN & NAVIGATION

### 2. Home Screen & Dashboard
Dashboard that shows personalized greeting and quick access to all app features.

**Functionality:**
- Display personalized greeting with user's name
- Show user profile picture from Google account
- Provide quick navigation to all major features:
  - View all recipes
  - Create new recipe
  - Manage pantry inventory
  - Browse ingredients
  - Plan meals
  - Filter recipes by availability
- Access navigation drawer for account and app settings
- Logout functionality available

**Workflow:**
1. User logs in or returns to app
2. System fetches user profile from Firestore
3. Home screen displays with user's display name and profile photo
4. User can tap any navigation card to access feature
5. User can access drawer for additional navigation
6. User can logout from navbar

**Features:**
- Automatic redirect if already logged in
- Loads user profile on app startup
- Provides central hub for all features

---

## 📖 RECIPE MANAGEMENT

### 3. View All Recipes
Display collection of all recipes created by the user.

**Functionality:**
- Fetch all recipes for logged-in user from Firestore
- Display recipes in searchable list/grid format
- Show recipe name and total ingredient count
- Load recipe images from Firebase Storage with caching
- Real-time search by recipe name with text input
- Search results update as user types
- Filter recipes to show only those makeable with current pantry items
- Display active filter status visually
- Show count of recipes matching current filters
- Handle empty state when no recipes exist

**Workflow:**
1. User navigates to recipes screen
2. System loads all recipes from Firestore for user
3. System caches recipe images from Firebase Storage
4. User sees grid/list of all recipes
5. User can type in search field to filter by name
6. User can toggle "pantry items" filter
7. System updates recipe list in real-time
8. User can tap recipe to view details
9. User can create new recipe using FAB

**Data Handling:**
- Recipe list fetched from `userRecipesProvider`
- Search state managed locally in component
- Search query passed to `searchRecipesProvider`
- Images cached to improve performance
- Pantry data fetched to enable filtering

---

### 4. Create Recipe
Add new recipe with ingredients, instructions, and optional image.

**Functionality:**
- Enter recipe name (required field)
- Enter cooking instructions (required field, multi-line support)
- Add tags/categories (comma-separated, custom and predefined options)
- Select multiple ingredients from available ingredient catalog
- Input quantity for each ingredient
- Select measurement unit for each ingredient
- Upload recipe image from device gallery or Search and select image from web(inside from)
- Preview selected image before saving
- Form validation before submission
- Upload recipe to Firestore database
- Upload image to Firebase Storage
- Handle upload timeouts (15-second limit)
- Success notification after creation
- Automatic redirect to recipes list after success
- Error notifications with detailed messages

**Workflow:**
1. User taps "Create Recipe" button
2. User enters recipe name in form
3. User enters cooking instructions
4. User optionally enters tags (comma-separated)
5. User clicks ingredient multi-select picker
6. User selects one or more ingredients from categorized list
7. System displays selected ingredients with quantity fields
8. User enters quantity and selects unit for each ingredient
9. User picks image from gallery or search web for image and select image inside the form
10. System shows image preview
11. User validates form (checks name, instructions, at least 1 ingredient)
12. On error, shows validation message
13. User submits form
14. System uploads image to Firebase Storage
15. System compresses image before upload
16. System creates recipe document in Firestore
17. System shows loading indicator during upload
18. On timeout or error, shows error notification
19. On success, shows success notification
20. System redirects to recipes list

**Validation:**
- Recipe name required
- Instructions required
- At least one ingredient required
- Quantity must be positive number
- Unit selection required for each ingredient

**Data Storage:**
- Recipe data stored in Firestore `recipes` collection
- Image uploaded to Firebase Storage with user ID and recipe ID organization
- Recipe includes: name, instructions, tags, ingredient IDs/quantities/units, image URL, timestamps

---

### 5. View Recipe Details
Display complete information about a single recipe.

**Functionality:**
- Fetch recipe details from Firestore by recipe ID
- Display recipe image (loaded from Firebase Storage)
- Show recipe name and metadata
- Display all ingredients with names and quantities
- Show cooking instructions
- Display tags/categories (if any)
- Show creation and modification timestamps
- Access option to edit recipe
- Access option to delete recipe
- Delete actions require confirmation dialogs
- Return to previous screen or home

**Workflow:**
1. User taps recipe from list
2. System loads recipe details from Firestore
3. System resolves ingredient IDs to ingredient names and details
4. System loads image from Firebase Storage
5. User sees recipe icon/image with parallax effect
6. User sees recipe name, ingredients, and instructions
7. User can view tags displayed
8. User can tap edit button to modify recipe
9. User can tap delete button
10. System shows confirmation dialog for delete
11. User confirms deletion
12. System removes recipe from Firestore
13. System removes image from Firebase Storage
14. System redirects to recipes list
15. User can tap back/home to return

**Data Resolution:**
- Ingredient IDs resolved to ingredient objects
- Ingredient names and units displayed to user
- Image loaded and optimized for display
- Timestamps formatted for readability

---

### 6. Edit Recipe
Modify existing recipe details.

**Functionality:**
- Load existing recipe data into form
- Allow editing of recipe name
- Allow editing of instructions
- Allow adding/removing/modifying tags
- Allow changing selected ingredients
- Allow changing ingredient quantities and units
- Allow uploading new recipe image or keeping existing
- Preview new image before saving
- Form validation before submission
- Update recipe in Firestore
- Update image in Firebase Storage if changed
- Show success notification after update
- Redirect to recipe details after success

**Workflow:**
1. User taps edit button on recipe details
2. System loads existing recipe data
3. Form fields populated with current values
4. User modifies desired fields
5. User can change ingredients using multi-select
6. User can change quantities/units for ingredients
7. User can optionally select new image
8. User validates and submits form
9. System updates recipe in Firestore
10. System handles image changes in Firebase Storage
11. System shows success notification
12. System redirects to recipe details with updated data

---

## 🛒 PANTRY MANAGEMENT

### 7. Manage Pantry Inventory
Track stored ingredients with quantities and expiry dates.

**Functionality:**
- Display all items in user's pantry
- Show ingredient name, quantity, unit, and dates
- Show date when item was added to pantry
- Show expiry date for perishable items (optional)
- Identify items expiring within next 3 days with visual indicator
- Identify expired items with visual indicator
- Delete pantry items with confirmation
- Edit pantry item quantity and expiry date
- Add new items to pantry with:
  - Ingredient selection from catalog
  - Quantity input (numeric)
  - Unit selection (kg, g, L, mL, pieces, cups, tbsp, tsp, etc.)
  - Optional expiry date picker
- Form validation for new items
- Success notification after adding item
- Handle empty pantry state

**Workflow - Adding Items:**
1. User navigates to pantry screen
2. User sees current pantry items list
3. User clicks "Add Item" section
4. User searches for ingredient in searchable selector
5. System filters ingredients by search term
6. User selects ingredient
7. User enters quantity (numeric value)
8. User selects unit from dropdown
9. User optionally selects expiry date from calendar picker
10. User clicks "Add to Pantry"
11. System validates quantity is positive and unit selected
12. System creates pantry item in Firestore
13. System shows success notification
14. System updates pantry list display

**Workflow - Managing Items:**
1. User sees pantry items with expiry indicators
2. User can tap edit button on item
3. User modifies quantity or expiry date
4. System updates item in Firestore
5. User can tap delete button on item
6. System shows confirmation dialog
7. User confirms deletion
8. System removes item from Firestore
9. System updates pantry list

**Data Handling:**
- Pantry items fetched from Firestore `pantryItems` collection
- Ingredient details resolved from ingredient IDs
- Expiry status calculated: expired (date < today), expiring soon (date within 3 days)
- Items displayed with resolved ingredient names

---

## 🥘 INGREDIENT MANAGEMENT

### 8. Browse Ingredient Catalog
View all available ingredients in the application.

**Functionality:**
- Display complete catalog of ingredients
- Organize ingredients by category:
  - Vegetables, Proteins, Grains, Spices, Oils & Condiments, Dairy, Fruits, Baking, etc.
- Show category headers with expand/collapse ability
- Display ingredient names within each category
- For each ingredient, allow adding to pantry with:
  - Quantity input field (numeric)
  - Unit selector dropdown
  - Optional expiry date picker
- Form validation for adding items
- Success notification after adding to pantry
- Error messages for invalid input

**Workflow:**
1. User navigates to ingredients screen
2. System loads all ingredients from Firestore `ingredients` collection
3. System organizes ingredients by category
4. Categories displayed as collapsible sections
5. User can expand/collapse categories
6. User sees ingredient list within each category
7. For each ingredient, user can:
   - Enter quantity needed
   - Select measurement unit
   - Select optional expiry date
   - Click "Add to Pantry"
8. System validates input
9. System creates pantry item in Firestore
10. System shows success notification
11. Pantry item appears in user's pantry

**Data Catalog:**
- All ingredients stored in Firestore `ingredients` collection
- Ingredients organized by category field
- Categories fixed and managed by application
- New ingredients can be added to catalog (admin feature, future)

---

## 🍽️ MEAL PLANNING

### 9. Create & Manage Meal Plans
Plan meals for specific dates using available recipes.

**Functionality:**
- Select date for meal plan using calendar picker
- Date range limited to today through 30 days in future
- View existing meal plan for selected date
- Display all recipes assigned to that date
- Show count of ingredients needed for all recipes in plan
- Add recipes to meal plan from available recipes
- Multi-select recipe picker shows all user recipes
- Remove individual recipes from meal plan
- Generate aggregated ingredient list for all recipes in plan
- Display ingredient count with measurement units
- Delete entire meal plan with confirmation
- Handle empty meal plan state

**Workflow:**
1. User navigates to meal plan screen
2. User selects date using calendar date picker
3. System fetches meal plan for selected date from Firestore
4. System displays recipes currently in meal plan for date
5. User can tap "Plan Meal" button
6. System opens recipe selection dialog
7. User selects one or more recipes using checkboxes
8. User confirms selection
9. System adds selected recipes to meal plan in Firestore
10. System displays updated list of recipes
11. System shows aggregated ingredient list
12. User can tap delete on any recipe to remove it
13. System removes recipe from Firestore meal plan
14. System updates ingredient list
15. User can select different date to create new meal plan
16. User can view existing meal plans for other dates

**Data Handling:**
- Meal plans stored in Firestore `mealPlans` collection with date as key
- Meal plan contains user ID and list of recipe IDs
- Ingredient aggregation done by combining all ingredients from selected recipes
- Quantities summed when same ingredient appears in multiple recipes
- Results calculated client-side from recipe data

**Ingredient Aggregation:**
- System combines all ingredients from selected recipes
- For same ingredient in multiple recipes: quantities added together
- Results displayed with totals needed for full meal plan
- Helps user determine shopping needs

---

##  🔍 RECIPE FILTERING & SEARCH

### 10. Advanced Recipe Filtering
Filter recipes based on ingredient availability and custom selection.

**Functionality:**
- View recipes with multiple filter options applied simultaneously
- **Pantry-Only Filter**: Show only recipes where ALL ingredients exist in pantry
  - Toggle pantry-only filter on/off
  - System compares recipe ingredients with pantry inventory
  - Only recipes with complete ingredient availability shown
  - Use case: "What can I make right now?"
- **Custom Ingredient Filter**: Filter by specific selected ingredients
  - Multi-select ingredient picker
  - Choose ingredients from complete catalog
  - Toggle filter on/off
- **Match Mode Toggle**: Control how custom ingredients are matched
  - All Mode: Only show recipes containing ALL selected ingredients
  - Any Mode: Show recipes containing AT LEAST ONE selected ingredient
  - Different selection affects recipe results
- Clear all filters button to reset
- Real-time filter application
- Display count of recipes matching current filters
- Handle no-results state with suggestions

**Workflow:**
1. User navigates to filter recipes screen
2. User can toggle pantry-only filter switch
3. If pantry-only enabled: system shows only recipes with all ingredients in pantry
4. User can toggle custom ingredient filter switch
5. If custom filter enabled: system opens ingredient multi-select
6. User selects desired ingredients from categorized list
7. User selects match mode: "All ingredients required" or "Any ingredient"
8. System filters recipes in real-time:
   - If "All" mode: only recipes containing all selected ingredients shown
   - If "Any" mode: recipes with any selected ingredient shown
9. System displays filtered recipe list
10. User can clear all filters to reset to unfiltered view
11. User can modify filters and see updated results immediately
12. User can click recipe to view details

**Filter Logic:**
- **Pantry-Only**: Intersection of recipe ingredients with pantry inventory
- **Custom + All Mode**: Recipes that contain ALL selected ingredients
- **Custom + Any Mode**: Recipes that contain AT least ONE selected ingredient
- Filters can be used simultaneously
- Results reflect combination of all active filters

**Data Processing:**
- Recipe list filtered on client-side using provider logic
- Pantry data fetched to compare with recipe ingredients
- Ingredient details resolved for display
- No additional API calls required for filtering

---

## 👤 USER AUTHENTICATION & PROFILE

### 11. User Profile Management
View and manage user account information.

**Functionality:**
- Display user's profile information:
  - Display name (from Google account)
  - Email address
  - Profile photo (from Google account)
  - Account creation date
- Access profile data from Firebase Authentication and Firestore
- Logout functionality available from home screen
- Sign out from Firebase Authentication
- Clear user session
- Redirect to login screen after logout
- Automatic session persistence on app startup

**Workflow:**
1. User logs in with Google account
2. System stores user in Firebase Auth
3. System creates user profile in Firestore if new user
4. User profile document includes: email, displayName, photoUrl, createdAt
5. On app startup or home screen, user profile loaded and displayed
6. User can access account information from app
7. User can tap logout button
8. System signs out user from Firebase Auth
9. System clears local session
10. System redirects to login screen

**Session Management:**
- Firebase Auth handles session persistence automatically
- Automatic redirect to home if user already authenticated
- Automatic redirect to login if user not authenticated
- Session remains active across app restarts

---

## 🗄️ DATA MODELS & STORAGE

### Database Structure

**Firestore Collections:**

#### Users Collection (`users/`)
Stores user profile information.
```
fields:
- uid: Unique user identifier from Firebase Auth
- email: User's email address
- displayName: User's display name
- photoUrl: URL to user's profile photo
- createdAt: Timestamp when user account created
```

#### Ingredients Collection (`ingredients/`)
Master catalog of all available ingredients.
```
fields:
- id: Unique ingredient identifier
- name: Ingredient name
- category: Category classification (Vegetables, Proteins, Grains, etc.)
```

#### Recipes Collection (`recipes/`)
User-created recipes with ingredients and instructions.
```
fields:
- id: Unique recipe identifier
- userId: Reference to recipe creator
- name: Recipe title
- ingredientIds: Array of ingredient IDs used in recipe
- ingredients: Array of ingredient objects with quantities and units
- instructions: Cooking instructions text
- imageUrl: URL to recipe image in Firebase Storage
- tags: Array of recipe tags/categories
- createdAt: Timestamp when recipe created
- updatedAt: Timestamp when recipe last modified
```

#### Pantry Items Collection (`pantryItems/`)
User's inventory of stored ingredients.
```
fields:
- id: Unique pantry item identifier
- userId: Reference to pantry owner
- ingredientId: Reference to ingredient
- amount: Quantity stored (numeric)
- unit: Measurement unit (kg, g, L, mL, pieces, cups, tbsp, tsp)
- addedDate: Timestamp when item added to pantry
- expiryDate: Optional expiry date for perishable items
```

#### Meal Plans Collection (`mealPlans/`)
User's meal plans for specific dates.
```
fields:
- id: Unique meal plan identifier
- userId: Reference to meal plan owner
- planDate: Target date for meal plan
- recipeIds: Array of recipe IDs assigned to this date
- createdAt: Timestamp when meal plan created
```

### Firebase Storage
- Recipe images stored in organized folder structure
- Path: `users/{userId}/recipes/{recipeId}/image`
- Image compression before upload for performance
- Image caching on client-side to reduce bandwidth

---

## 🔧 STATE MANAGEMENT & DATA FLOW

### Provider Architecture
Application uses Riverpod for state management and data synchronization.

**Authentication Providers:**
- `authServiceProvider`: Firebase authentication service with sign-in/sign-out methods
- `currentUserProvider`: Current authenticated user from Firebase Auth
- `currentUserProfileProvider`: User profile data from Firestore (display name, photo, etc.)
- `authStateProvider`: Stream of authentication state changes for automatic redirects

**Recipe Providers:**
- `userRecipesProvider`: All recipes for logged-in user (cached, updates on data changes)
- `recipeByIdProvider(id)`: Single recipe details fetched from Firestore
- `searchRecipesProvider(query)`: Search recipes by name with text matching
- `recipeServiceProvider`: Service for recipe CRUD operations

**Ingredient Providers:**
- `allIngredientsProvider`: Complete ingredient catalog (shared across app)
- `ingredientServiceProvider`: Service for ingredient operations
- `currentIngredientIdsProvider`: User's available ingredients

**Pantry Providers:**
- `pantryItemsProvider`: User's pantry items from Firestore
- `pantryIngredientsProvider`: Pantry items with resolved ingredient details
- `pantryServiceProvider`: Service for pantry CRUD operations

**Meal Plan Providers:**
- `mealPlanForDateProvider(date)`: Meal plan for specific date
- `mealPlanServiceProvider`: Service for meal plan operations

**Filter Providers:**
- `filteredRecipesProvider(FilterOptions)`: Apply filters to recipe list
- `FilterOptions`: Data class containing filter state (pantry-only, custom ingredients, match mode)

### Data Synchronization
- Real-time updates from Firestore streams automatically refresh provider data
- Provider listeners can trigger UI updates on data changes
- Client-side caching reduces database queries
- Image caching with `cached_network_image` improves performance
- Search and filter operations executed client-side for instant feedback

---

## 🧠 BUSINESS LOGIC & CALCULATIONS

### Recipe Filtering Logic
**Pantry-Only Mode:**
- System compares recipe's ingredient list with user's pantry items
- Recipe shows only if every ingredient in recipe exists in pantry with sufficient quantity
- Ingredient need resolved from recipe specification
- Pantry amount checked for availability

**Custom Ingredient Filter with Match Modes:**

*All Ingredients Mode:*
- User selects multiple ingredients
- Recipe must contain ALL selected ingredients to appear in results
- Example: User selects "chicken" and "rice" → only recipes with both shown
- More restrictive, fewer results
- Useful for finding recipes with specific requirements

*Any Ingredient Mode:*
- User selects multiple ingredients
- Recipe appears if it contains AT LEAST ONE selected ingredient
- Example: User selects "chicken" and "mushrooms" → recipes with either shown
- Broader results, more options
- Useful for using up available ingredients

**Combined Filters:**
- Multiple filters apply simultaneously if all enabled
- Cumulative effect: recipe must satisfy all active filter conditions
- Order of operations: AND logic between different filter types

### Ingredient Aggregation for Meal Plans
- When multiple recipes assigned to meal plan
- System collects all ingredients from all recipes
- Same ingredient appearing in multiple recipes: quantities added together
- Results show total amount needed for complete meal plan
- Units remain as specified in individual recipes

### Expiry Date Calculations
- Item marked "Expired" when expiry date < today
- Item marked "Expiring Soon" when expiry date within next 3 days
- Calculation run on each pantry display to ensure accuracy
- Optional field: item without expiry date has no expiry indicator

---

## ✅ FEATURE COMPLETENESS & WORKFLOWS

### Complete User Workflows:

**Workflow 1: Create Recipe & View Details**
1. Login with Google
2. Navigate to Recipes
3. Click Create Recipe
4. Enter recipe details (name, instructions, ingredients, image)
5. Submit recipe
6. Click recipe to view details
7. See all ingredients with quantities
8. See cooking instructions

**Workflow 2: Manage Pantry & Cook with Available Items**
1. Navigate to Pantry
2. Add ingredients with quantities and expiry dates
3. See inventory organized with expiry indicators
4. Navigate to Filter Recipes
5. Enable "Pantry Only" filter
6. See only recipes makeable with current inventory
7. Select recipe to see detailed ingredients
8. Cook with available items

**Workflow 3: Plan Meals for Week**
1. Navigate to Meal Plan
2. Select Monday using calendar
3. Choose recipes to cook Monday
4. System shows aggregated ingredients needed
5. Repeat for other days of week
6. View complete weekly ingredient shopping list

**Workflow 4: Filter Recipes by Preferences**
1. Navigate to Filter Recipe screen
2. Search for recipes containing specific ingredients
3. Select "chicken", "tomato", "garlic"
4. Choose "All ingredients" mode to find recipes with all three
5. View recipes that use chicken, tomato, and garlic
6. Switch to "Any ingredient" mode
7. See broader list of recipes with any of those ingredients

---

## 📱 MULTI-PLATFORM SUPPORT

### Cross-Platform Functionality
- All features work identically on iOS, Android, and Web
- Authentication adapts per platform (Apple, Google, web flow)
- Image picker uses platform-specific implementations
- Data synchronization synchronized across devices via Firebase
- User can start on mobile, continue on web, return to mobile with data in sync

---

## 🔄 REAL-TIME UPDATES & SYNC

### Live Data Synchronization
- Recipe list updates when new recipes created
- Pantry updates when items added/removed/edited
- Ingredient catalog loads once and available to all screens
- Meal plans update across screens when date selected
- Filter results update in real-time as filters toggled
- Profile photo and name display updates on home screen
- Authentication state monitored for automatic redirects

### Offline Handling
- Firebase handles offline connectivity gracefully
- Pending writes queue when offline
- Writes sync when connection restored
- Reads show cached data if offline

---

## 📊 FUTURE FUNCTIONALITY ROADMAP

### High Priority Features:
- Rating and reviewing recipes
- Sharing recipes with other users
- Saving favorite recipes for quick access
- Shopping list generation from meal plan (export to notes/share)
- Advanced search by recipe difficulty (easy, medium, hard)
- Prep and cook time estimates per recipe

### Medium Priority Features:
- Dietary restriction filtering (vegan, gluten-free, keto, etc.)
- Recipe scaling calculator for different serving sizes
- Nutritional information display per recipe
- User account settings and preferences page
- App theme customization (dark mode)

### Low Priority Features:
- Social features (follow users, view other user recipes)
- Community recipe sharing and discovery
- AI recipe recommendations based on user history
- Barcode scanning for quick pantry item addition
- Voice input for hands-free recipe entry
- Offline mode with local database sync
- Multi-language support

---

## 📦 DEPENDENCY & INTEGRATION

### External Services:
- **Google Authentication**: OAuth 2.0 for user login
- **Firebase Authentication**: User session management
- **Firestore**: Real-time database for all data storage
- **Firebase Storage**: Image storage for recipe photos
- **Image Picker**: Device gallery access for recipe images

### Local Storage:
- Image caching for performance
- Provider state caching

---

## 🎯 USER CAPABILITIES SUMMARY

**What Users Can Do:**

✅ Create Google account-based login  
✅ Create, view, edit, and delete recipes  
✅ Add ingredients to recipes with quantities and units  
✅ Upload and manage recipe images  
✅ Categorize recipes with tags  
✅ Manage pantry inventory with quantities and expiry tracking  
✅ Add ingredients from catalog to personal pantry  
✅ Browse complete ingredient catalog organized by category  
✅ Search recipes by name  
✅ Filter recipes by pantry ingredient availability  
✅ Filter recipes by specific selected ingredients  
✅ Plan meals by selecting recipes for specific dates  
✅ View aggregated ingredient list for meal plans  
✅ Track ingredient expiry with visual indicators  
✅ Access all features from multiple devices via cloud sync  
✅ Logout and manage authentication  
✅ View personal profile information  

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Screens** | 9 |
| **Data Collections** | 5 |
| **Key Features** | 10+ |
| **Provider Types** | 20+ |
| **User Workflows** | 4+ |
| **Data Models** | 5 |
| **External Services** | 3 |

