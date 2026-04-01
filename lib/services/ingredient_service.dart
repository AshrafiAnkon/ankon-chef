import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ingredient_model.dart';

/// Service for managing ingredients
class IngredientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all ingredients from master list
  Stream<List<Ingredient>> get allIngredients {
    return _firestore
        .collection('ingredients')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Ingredient.fromFirestore(doc)).toList()
                ..sort((a, b) => a.name.compareTo(b.name)),
        );
  }

  /// Get all ingredients from master list as a Future
  Future<List<Ingredient>> getAllIngredientsFuture() async {
    final snapshot = await _firestore.collection('ingredients').get();
    final ingredients = snapshot.docs.map((doc) => Ingredient.fromFirestore(doc)).toList();
    ingredients.sort((a, b) => a.name.compareTo(b.name));
    return ingredients;
  }

  /// Get ingredients by category
  Stream<List<Ingredient>> getIngredientsByCategory(String category) {
    return _firestore
        .collection('ingredients')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Ingredient.fromFirestore(doc))
              .toList(),
        );
  }

  /// Add new ingredient to master list (admin function)
  Future<String> addIngredient(String name, String category) async {
    final docRef = await _firestore
        .collection('ingredients')
        .add({'name': name, 'category': category})
        .timeout(const Duration(seconds: 10));
    return docRef.id;
  }

  /// Get or create an ingredient by name
  Future<String> getOrCreateIngredient(String name, String category) async {
    final query = await _firestore
        .collection('ingredients')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    return await addIngredient(name, category);
  }

  /// Get user's current ingredients
  Stream<List<UserIngredient>> getCurrentIngredients(String userId) {
    return _firestore
        .collection('userIngredients')
        .where('userId', isEqualTo: userId)
        .where('isCurrent', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserIngredient.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get user's current ingredient IDs
  Future<List<String>> getCurrentIngredientIds(String userId) async {
    final snapshot = await _firestore
        .collection('userIngredients')
        .where('userId', isEqualTo: userId)
        .where('isCurrent', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['ingredientId'] as String)
        .toList();
  }

  /// Update user's ingredient status
  Future<void> updateIngredientStatus(
    String userId,
    String ingredientId,
    bool isCurrent,
  ) async {
    final docId = '${userId}_$ingredientId';
    final docRef = _firestore.collection('userIngredients').doc(docId);

    final userIngredient = UserIngredient(
      userId: userId,
      ingredientId: ingredientId,
      isCurrent: isCurrent,
      updatedAt: DateTime.now(),
    );

    await docRef.set(userIngredient.toFirestore());
  }

  /// Toggle ingredient status
  Future<void> toggleIngredient(String userId, String ingredientId) async {
    final docId = '${userId}_$ingredientId';
    final docRef = _firestore.collection('userIngredients').doc(docId);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentStatus = doc.data()?['isCurrent'] as bool? ?? false;
      await updateIngredientStatus(userId, ingredientId, !currentStatus);
    } else {
      await updateIngredientStatus(userId, ingredientId, true);
    }
  }

  /// Seed initial ingredients (for first-time setup)
  Future<void> seedIngredients() async {
    final ingredients = [
      // Vegetables (Shobji | সবজি)
      {
        'name': 'Tomato (Tomato | টমেটো)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Onion (Peyaj | পেঁয়াজ)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Garlic (Roshun | রসুন)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {'name': 'Ginger (Ada | আদা)', 'category': 'Vegetables (Shobji | সবজি)'},
      {'name': 'Potato (Alu | আলু)', 'category': 'Vegetables (Shobji | সবজি)'},
      {
        'name': 'Carrot (Gajor | গাজর)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Green Chili (Morich | মরিচ)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Cucumber (Shosha | শসা)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Eggplant (Begun | বেগুন)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Bottle Gourd (Lau | লাউ)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Ridge Gourd (Jhinga | ঝিঙা)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Snake Gourd (Chichinga | চিচিঙ্গা)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Bitter Gourd (Korola | করলা)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Pumpkin (Kumra | কুমড়া)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Green Papaya (Kacha Pepe | কাঁচা পেঁপে)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Cabbage (Bandha Kopi | বাঁধাকপি)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Cauliflower (Phulkopi | ফুলকপি)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Okra (Dherosh | ঢেঁড়স)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Radish (Mula | মূলা)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Drumstick (Sajna | সজনে)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Jackfruit (Kathal | কাঁঠাল)',
        'category': 'Vegetables (Shobji | সবজি)',
      },
      {
        'name': 'Raw Banana (Kacha Kola | কাঁচা কলা)',
        'category': 'Vegetables (Shobji | সবজি)',
      },

      // Leafy Greens (Shak | শাক)
      {
        'name': 'Spinach (Palong Shak | পালং শাক)',
        'category': 'Leafy Greens (Shak | শাক)',
      },
      {
        'name': 'Red Amaranth (Lal Shak | লাল শাক)',
        'category': 'Leafy Greens (Shak | শাক)',
      },
      {
        'name': 'Water Spinach (Kolmi Shak | কলমি শাক)',
        'category': 'Leafy Greens (Shak | শাক)',
      },
      {
        'name': 'Mustard Greens (Shorisha Shak | সরিষা শাক)',
        'category': 'Leafy Greens (Shak | শাক)',
      },
      {
        'name': 'Pumpkin Leaves (Kumra Shak | কুমড়া শাক)',
        'category': 'Leafy Greens (Shak | শাক)',
      },
      {
        'name': 'Coriander Leaves (Dhonepata | ধনেপাতা)',
        'category': 'Leafy Greens (Shak | শাক)',
      },
      {
        'name': 'Mint Leaves (Pudina | পুদিনা)',
        'category': 'Leafy Greens (Shak | শাক)',
      },

      // Proteins – Meat & Fish (Protin – Machh o Mangsho | প্রোটিন – মাছ ও মাংস)
      {
        'name': 'Chicken (Murgi | মুরগি)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Beef (Goru Mangsho | গরুর মাংস)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Mutton (Khashi Mangsho | খাসির মাংস)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {'name': 'Duck (Hash | হাঁস)', 'category': 'Proteins (Protin | প্রোটিন)'},
      {'name': 'Eggs (Dim | ডিম)', 'category': 'Proteins (Protin | প্রোটিন)'},
      {
        'name': 'Hilsa Fish (Ilish | ইলিশ)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Rui Fish (Rui | রুই)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Katla Fish (Katla | কাতলা)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Pangash Fish (Pangash | পাঙ্গাস)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Tilapia (Telapia | তেলাপিয়া)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Shrimp (Chingri | চিংড়ি)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },
      {
        'name': 'Dry Fish (Shutki | শুঁটকি)',
        'category': 'Proteins (Protin | প্রোটিন)',
      },

      // Lentils (Dal | ডাল)
      {
        'name': 'Red Lentils (Masoor Dal | মসুর ডাল)',
        'category': 'Lentils (Dal | ডাল)',
      },
      {
        'name': 'Yellow Lentils (Mug Dal | মুগ ডাল)',
        'category': 'Lentils (Dal | ডাল)',
      },
      {
        'name': 'Split Chickpeas (Chola Dal | ছোলা ডাল)',
        'category': 'Lentils (Dal | ডাল)',
      },
      {
        'name': 'Black Gram (Mashkalai Dal | মাষকলাই ডাল)',
        'category': 'Lentils (Dal | ডাল)',
      },
      {'name': 'Green Gram (Moong | মুগ)', 'category': 'Lentils (Dal | ডাল)'},
      {'name': 'Chickpeas (Chola | ছোলা)', 'category': 'Lentils (Dal | ডাল)'},

      // Grains & Rice (Shossho o Chal | শস্য ও চাল)
      {'name': 'Rice (Chal | চাল)', 'category': 'Grains (Shossho | শস্য)'},
      {
        'name': 'Basmati Rice (Basmoti Chal | বাসমতি চাল)',
        'category': 'Grains (Shossho | শস্য)',
      },
      {
        'name': 'Miniket Rice (Miniket Chal | মিনিকেট চাল)',
        'category': 'Grains (Shossho | শস্য)',
      },
      {
        'name': 'Atap Rice (Atap Chal | আতপ চাল)',
        'category': 'Grains (Shossho | শস্য)',
      },
      {
        'name': 'Flattened Rice (Chira | চিঁড়া)',
        'category': 'Grains (Shossho | শস্য)',
      },
      {
        'name': 'Puffed Rice (Muri | মুড়ি)',
        'category': 'Grains (Shossho | শস্য)',
      },
      {'name': 'Flour (Atta | আটা)', 'category': 'Grains (Shossho | শস্য)'},
      {
        'name': 'Rice Flour (Chaler Gura | চালের গুঁড়া)',
        'category': 'Grains (Shossho | শস্য)',
      },
      {'name': 'Semolina (Suji | সুজি)', 'category': 'Grains (Shossho | শস্য)'},

      // Spices (Moshla | মসলা)
      {'name': 'Salt (Lobon | লবণ)', 'category': 'Spices (Moshla | মসলা)'},
      {
        'name': 'Turmeric Powder (Holud | হলুদ)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Red Chili Powder (Morich Gura | মরিচ গুঁড়া)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Cumin Powder (Jeera Gura | জিরা গুঁড়া)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Coriander Powder (Dhone Gura | ধনে গুঁড়া)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Garam Masala (Gorom Moshla | গরম মসলা)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Bay Leaf (Tejpata | তেজপাতা)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Cinnamon (Daruchini | দারুচিনি)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {'name': 'Cardamom (Elach | এলাচ)', 'category': 'Spices (Moshla | মসলা)'},
      {
        'name': 'Cloves (Lobongo | লবঙ্গ)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Mustard Seeds (Shorisha | সরিষা)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Nigella Seeds (Kalo Jeera | কালোজিরা)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Fenugreek Seeds (Methi | মেথি)',
        'category': 'Spices (Moshla | মসলা)',
      },
      {
        'name': 'Dry Red Chili (Shukna Morich | শুকনা মরিচ)',
        'category': 'Spices (Moshla | মসলা)',
      },

      // Oils & Fats (Tel o ChorbI | তেল ও চর্বি)
      {
        'name': 'Mustard Oil (Shorishar Tel | সরিষার তেল)',
        'category': 'Oils (Tel | তেল)',
      },
      {
        'name': 'Soybean Oil (Soyabin Tel | সয়াবিন তেল)',
        'category': 'Oils (Tel | তেল)',
      },
      {
        'name': 'Vegetable Oil (Rannar Tel | রান্নার তেল)',
        'category': 'Oils (Tel | তেল)',
      },
      {'name': 'Ghee (Ghee | ঘি)', 'category': 'Oils (Tel | তেল)'},

      // Dairy (Dugdhojat | দুগ্ধজাত)
      {'name': 'Milk (Dudh | দুধ)', 'category': 'Dairy (Dugdhojat | দুগ্ধজাত)'},
      {'name': 'Yogurt (Doi | দই)', 'category': 'Dairy (Dugdhojat | দুগ্ধজাত)'},
      {
        'name': 'Butter (Makhan | মাখন)',
        'category': 'Dairy (Dugdhojat | দুগ্ধজাত)',
      },
      {
        'name': 'Cream (Cream | ক্রিম)',
        'category': 'Dairy (Dugdhojat | দুগ্ধজাত)',
      },
      {
        'name': 'Paneer (Chhana | ছানা)',
        'category': 'Dairy (Dugdhojat | দুগ্ধজাত)',
      },

      // Condiments & Others (Onnanno | অন্যান্য)
      {
        'name': 'Tamarind (Tetul | তেঁতুল)',
        'category': 'Condiments (Onnanno | অন্যান্য)',
      },
      {
        'name': 'Sugar (Chini | চিনি)',
        'category': 'Condiments (Onnanno | অন্যান্য)',
      },
      {
        'name': 'Jaggery (Gur | গুড়)',
        'category': 'Condiments (Onnanno | অন্যান্য)',
      },
      {
        'name': 'Vinegar (Sirca | সিরকা)',
        'category': 'Condiments (Onnanno | অন্যান্য)',
      },
      {
        'name': 'Green Chili Paste (Morich Bata | মরিচ বাটা)',
        'category': 'Condiments (Onnanno | অন্যান্য)',
      },
    ];

    final batch = _firestore.batch();
    for (final ingredient in ingredients) {
      final docRef = _firestore.collection('ingredients').doc();
      batch.set(docRef, ingredient);
    }
    await batch.commit();
  }
}
