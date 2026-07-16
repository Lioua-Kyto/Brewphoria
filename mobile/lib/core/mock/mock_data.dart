// ─────────────────────────────────────────────────────────────────────────────
//  FAKE DATA for the offline demo mode (AppConfig.useMockData == true).
//
//  This is the file to edit if you want to add/adjust demo products, reviews,
//  the demo account, etc. Everything here is plain JSON-shaped maps that match
//  the real API responses, so the rest of the app treats them exactly like
//  backend data. Product images point at files in  assets/Products/  (make sure
//  the filename matches and the folder is registered in pubspec.yaml).
//
//  Demo login: any email + any password works (see AuthRepository). The account
//  below is what you'll be signed in as.
// ─────────────────────────────────────────────────────────────────────────────

String _iso(int daysAgo) =>
    DateTime.now().subtract(Duration(days: daysAgo)).toIso8601String();

String _img(String file) => 'assets/Products/$file';

// ── The demo account ─────────────────────────────────────────────────────────
final Map<String, dynamic> mockUser = {
  'id': 'u_demo',
  'firebaseUid': 'demo-uid',
  'email': 'demo@brewphoria.app',
  'displayName': 'Alex Rivera',
  'firstName': 'Alex',
  'lastName': 'Rivera',
  'avatarUrl': null,
  'role': 'USER',
  'createdAt': _iso(210),
};

final Map<String, dynamic> mockLoyalty = {
  'id': 'l_demo',
  'currentPoints': 640,
  'lifetimePoints': 2190,
  'tier': 'GOLD',
};

// ── Categories ───────────────────────────────────────────────────────────────
Map<String, dynamic> _cat(String id, String name, String slug) =>
    {'id': id, 'name': name, 'slug': slug, 'imageUrl': null, 'isActive': true};

final List<Map<String, dynamic>> mockCategories = [
  _cat('c_espresso', 'Espresso & Hot Drinks', 'espresso-hot-drinks'),
  _cat('c_cold', 'Cold Brew & Iced', 'cold-brew-iced'),
  _cat('c_pastry', 'Pastries & Baked Goods', 'pastries-baked-goods'),
  _cat('c_beans', 'Coffee Beans & Grounds', 'coffee-beans-grounds'),
  _cat('c_tea', 'Tea & Alternatives', 'tea-alternatives'),
  _cat('c_merch', 'Merchandise', 'merchandise'),
];

// ── Modifier groups (returned on product detail, gated by product `type`) ──────
Map<String, dynamic> _opt(String id, String label, num delta,
        {bool isDefault = false}) =>
    {'id': id, 'label': label, 'priceDelta': delta, 'isDefault': isDefault};

final List<Map<String, dynamic>> _drinkGroups = [
  {
    'id': 'g_size',
    'name': 'Size',
    'selectionType': 'SINGLE',
    'isRequired': true,
    'sortOrder': 0,
    'options': [
      _opt('o_sm', 'Small', -0.4),
      _opt('o_md', 'Medium', 0, isDefault: true),
      _opt('o_lg', 'Large', 0.6),
    ],
  },
  {
    'id': 'g_milk',
    'name': 'Milk',
    'selectionType': 'SINGLE',
    'isRequired': false,
    'sortOrder': 1,
    'options': [
      _opt('o_whole', 'Whole', 0, isDefault: true),
      _opt('o_oat', 'Oat', 0.6),
      _opt('o_almond', 'Almond', 0.6),
      _opt('o_skim', 'Skim', 0),
    ],
  },
  {
    'id': 'g_sweet',
    'name': 'Sweetness',
    'selectionType': 'SINGLE',
    'isRequired': false,
    'sortOrder': 2,
    'options': [
      _opt('o_nosugar', 'No sugar', 0),
      _opt('o_light', 'Light', 0, isDefault: true),
      _opt('o_regular', 'Regular', 0),
      _opt('o_extra', 'Extra sweet', 0),
    ],
  },
  {
    'id': 'g_addons',
    'name': 'Add-ons',
    'selectionType': 'MULTI',
    'isRequired': false,
    'sortOrder': 3,
    'options': [
      _opt('o_shot', 'Extra espresso shot', 0.8),
      _opt('o_vanilla', 'Vanilla syrup', 0.5),
      _opt('o_caramel', 'Caramel drizzle', 0.5),
      _opt('o_whip', 'Whipped cream', 0.4),
    ],
  },
];

final List<Map<String, dynamic>> _beansGroups = [
  {
    'id': 'g_grind',
    'name': 'Grind',
    'selectionType': 'SINGLE',
    'isRequired': false,
    'sortOrder': 0,
    'options': [
      _opt('o_whole_bean', 'Whole Bean', 0, isDefault: true),
      _opt('o_ground', 'Ground', 0),
    ],
  },
];

/// Modifier groups for a product's type — matches the backend gating.
List<Map<String, dynamic>> mockGroupsForType(String type) => switch (type) {
      'DRINK' => _drinkGroups,
      'BEANS' => _beansGroups,
      _ => const [],
    };

// ── Products ─────────────────────────────────────────────────────────────────
int _pid = 0;
Map<String, dynamic> _p({
  required String name,
  required String slug,
  required num price,
  required String image,
  required String type,
  required String categoryId,
  required String categoryName,
  required String categorySlug,
  required String description,
  int stock = 60,
  bool featured = false,
  num avgRating = 4.6,
  int reviewCount = 0,
  String? roastLevel,
  int? calories,
  int? caffeineMg,
  int? prepMinutes,
  List<String> tastingNotes = const [],
}) {
  return {
    'id': 'p_${_pid++}',
    'name': name,
    'slug': slug,
    'description': description,
    'price': price,
    'images': [_img(image)],
    'stock': stock,
    'isActive': true,
    'isFeatured': featured,
    'avgRating': avgRating,
    'reviewCount': reviewCount,
    'type': type,
    'roastLevel': roastLevel,
    'calories': calories,
    'caffeineMg': caffeineMg,
    'prepMinutes': prepMinutes,
    'tastingNotes': tastingNotes,
    'categoryId': categoryId,
    'category': {
      'id': categoryId,
      'name': categoryName,
      'slug': categorySlug,
    },
  };
}

Map<String, dynamic> _drink(String name, String slug, num price, String image,
        String cat, String catName, String catSlug, String desc,
        {bool featured = false,
        num rating = 4.6,
        int reviews = 0,
        String roast = 'Medium',
        int cal = 180,
        int caff = 120,
        int prep = 4,
        List<String> notes = const ['Chocolate', 'Caramel', 'Nutty']}) =>
    _p(
      name: name,
      slug: slug,
      price: price,
      image: image,
      type: 'DRINK',
      categoryId: cat,
      categoryName: catName,
      categorySlug: catSlug,
      description: desc,
      featured: featured,
      avgRating: rating,
      reviewCount: reviews,
      roastLevel: roast,
      calories: cal,
      caffeineMg: caff,
      prepMinutes: prep,
      tastingNotes: notes,
    );

final List<Map<String, dynamic>> mockProducts = [
  // ── Espresso & Hot Drinks (DRINK) ──
  _drink('Classic Espresso', 'classic-espresso', 3.50, 'classic espresso.png',
      'c_espresso', 'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'A concentrated shot of rich, bold espresso with a silky crema.',
      featured: true, rating: 4.8, reviews: 42, roast: 'Dark', caff: 150),
  _drink('Cappuccino', 'cappuccino', 4.50, 'cappuccino.png', 'c_espresso',
      'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'Equal parts espresso, steamed milk, and velvety foam.',
      featured: true, rating: 4.7, reviews: 31, notes: ['Chocolate', 'Vanilla', 'Honey']),
  _drink('Flat White', 'flat-white', 4.75, 'flat white.png', 'c_espresso',
      'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'A smooth, velvety espresso drink with silky microfoam.',
      rating: 4.6, reviews: 18),
  _drink('Cortado', 'cortado', 4.25, 'cortado.png', 'c_espresso',
      'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'Equal parts espresso and warm milk — balanced and bold.',
      rating: 4.5, reviews: 9),
  _drink('Americano', 'americano', 3.75, 'americano.png', 'c_espresso',
      'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'Espresso lengthened with hot water for a clean, full body.',
      rating: 4.4, reviews: 12, cal: 15, caff: 150),
  _drink('Vanilla Latte', 'vanilla-latte', 5.25, 'vanilla latte.png',
      'c_espresso', 'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'Espresso and steamed milk with a sweep of vanilla.',
      featured: true, rating: 4.7, reviews: 27, notes: ['Vanilla', 'Caramel', 'Toffee']),
  _drink('Mocha', 'mocha', 5.50, 'mocha.png', 'c_espresso',
      'Espresso & Hot Drinks', 'espresso-hot-drinks',
      'Espresso, steamed milk, and rich dark chocolate.',
      rating: 4.6, reviews: 21, cal: 290, notes: ['Chocolate', 'Berry', 'Toffee']),

  // ── Cold Brew & Iced (DRINK) ──
  _drink('Classic Cold Brew', 'classic-cold-brew', 4.75, 'classic cold brew.png',
      'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Steeped 18 hours for a smooth, low-acid, naturally sweet cup.',
      featured: true, rating: 4.8, reviews: 38, roast: 'Medium-Dark', cal: 5, caff: 200),
  _drink('Nitro Cold Brew', 'nitro-cold-brew', 5.50, 'nitro cold brew.png',
      'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Cold brew charged with nitrogen for a creamy, cascading pour.',
      rating: 4.7, reviews: 24, caff: 215),
  _drink('Cold Brew Tonic', 'cold-brew-tonic', 5.75, 'cold brew tonic.png',
      'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Cold brew over tonic and ice — bright, effervescent, refreshing.',
      rating: 4.5, reviews: 11, notes: ['Citrus', 'Floral', 'Berry']),
  _drink('Iced Caramel Latte', 'iced-caramel-latte', 5.75,
      'iced caramel latte.png', 'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Espresso, cold milk, and caramel over ice.',
      featured: true, rating: 4.7, reviews: 33, notes: ['Caramel', 'Vanilla', 'Toffee']),
  _drink('Iced Matcha Latte', 'iced-matcha-latte', 5.95, 'iced matcha latte.png',
      'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Ceremonial matcha whisked into cold oat milk over ice.',
      featured: true, rating: 4.8, reviews: 29, roast: 'Light', caff: 70, notes: ['Floral', 'Nutty', 'Honey']),
  _drink('Iced Vanilla Sweet Cream', 'iced-vanilla-sweet-cream', 5.50,
      'iced vanilla sweet cream.png', 'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Cold brew crowned with house vanilla sweet cream.',
      rating: 4.6, reviews: 16),
  _drink('Mango Dragonfruit Refresh', 'mango-dragonfruit-refresh', 5.25,
      'mango dragonfruit refresh.png', 'c_cold', 'Cold Brew & Iced', 'cold-brew-iced',
      'Caffeine-free fruit refresher with real fruit pieces.',
      rating: 4.4, reviews: 8, caff: 0, cal: 90, notes: ['Berry', 'Citrus', 'Floral']),

  // ── Coffee Beans & Grounds (BEANS) ──
  _p(
    name: 'Espresso Blend 1kg', slug: 'espresso-blend-1kg', price: 42.99,
    image: 'black coffee 1kg.png', type: 'BEANS', categoryId: 'c_beans',
    categoryName: 'Coffee Beans & Grounds', categorySlug: 'coffee-beans-grounds',
    description: 'A 1 kg bag of our crowd-favourite espresso blend.',
    featured: true, stock: 40, avgRating: 4.7, reviewCount: 19,
    roastLevel: 'Medium-Dark', tastingNotes: ['Chocolate', 'Toffee', 'Nutty'],
  ),
  _p(
    name: 'House Blend 250g', slug: 'house-blend-250g', price: 14.99,
    image: 'cream-white 250g.png', type: 'BEANS', categoryId: 'c_beans',
    categoryName: 'Coffee Beans & Grounds', categorySlug: 'coffee-beans-grounds',
    description: 'Our signature medium roast — dark chocolate and hazelnut.',
    stock: 80, avgRating: 4.6, reviewCount: 22,
    roastLevel: 'Medium', tastingNotes: ['Chocolate', 'Nutty', 'Caramel'],
  ),
  _p(
    name: 'Ethiopian Yirgacheffe 250g', slug: 'ethiopian-yirgacheffe-250g',
    price: 17.99, image: 'kraft-brown 250g.png', type: 'BEANS',
    categoryId: 'c_beans', categoryName: 'Coffee Beans & Grounds',
    categorySlug: 'coffee-beans-grounds',
    description: 'Light roast with jasmine, bergamot, and stone-fruit brightness.',
    featured: true, stock: 55, avgRating: 4.9, reviewCount: 27,
    roastLevel: 'Light', tastingNotes: ['Floral', 'Citrus', 'Berry'],
  ),
  _p(
    name: 'Single-Origin Sampler Box', slug: 'single-origin-sampler-box',
    price: 34.99, image: 'Single-Origin Sampler Box.png', type: 'BEANS',
    categoryId: 'c_beans', categoryName: 'Coffee Beans & Grounds',
    categorySlug: 'coffee-beans-grounds',
    description: 'Four 62 g taster bags from four different origins.',
    featured: true, stock: 30, avgRating: 4.8, reviewCount: 14,
    roastLevel: 'Medium', tastingNotes: ['Berry', 'Citrus', 'Chocolate'],
  ),

  // ── Tea & Alternatives (MERCH — retail packaged goods) ──
  _p(
    name: 'Ceremonial Matcha 30g', slug: 'ceremonial-matcha-30g', price: 18.99,
    image: 'Ceremonial Matcha 30g.png', type: 'MERCH', categoryId: 'c_tea',
    categoryName: 'Tea & Alternatives', categorySlug: 'tea-alternatives',
    description: 'First-harvest, stone-ground ceremonial-grade matcha from Uji.',
    featured: true, stock: 45, avgRating: 4.8, reviewCount: 17,
  ),
  _p(
    name: 'Chai Concentrate 500ml', slug: 'chai-concentrate-500ml', price: 9.99,
    image: 'Chai Concentrate 500ml.png', type: 'MERCH', categoryId: 'c_tea',
    categoryName: 'Tea & Alternatives', categorySlug: 'tea-alternatives',
    description: 'Bold house-made spiced chai — just add milk.',
    stock: 60, avgRating: 4.6, reviewCount: 12,
  ),
  _p(
    name: 'Earl Grey Loose Leaf 75g', slug: 'earl-grey-loose-leaf-75g',
    price: 11.99, image: 'Earl Grey Loose Leaf 75g.png', type: 'MERCH',
    categoryId: 'c_tea', categoryName: 'Tea & Alternatives',
    categorySlug: 'tea-alternatives',
    description: 'Classic bergamot-scented black tea, loose leaf.',
    stock: 70, avgRating: 4.5, reviewCount: 9,
  ),
  _p(
    name: 'Oat Milk Barista 1L', slug: 'oat-milk-barista-1l', price: 4.99,
    image: 'Oat Milk Barista 1L.png', type: 'MERCH', categoryId: 'c_tea',
    categoryName: 'Tea & Alternatives', categorySlug: 'tea-alternatives',
    description: 'Professionally formulated oat milk for silky microfoam.',
    stock: 90, avgRating: 4.7, reviewCount: 15,
  ),

  // ── Pastries & Baked Goods (MERCH) ──
  _p(
    name: 'Butter Croissant', slug: 'butter-croissant', price: 3.00,
    image: 'butter croissant.png', type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Flaky, all-butter croissant baked fresh each morning.',
    featured: true, stock: 40, avgRating: 4.7, reviewCount: 20,
    calories: 280, prepMinutes: 2,
  ),
  _p(
    name: 'Almond Croissant', slug: 'almond-croissant', price: 3.75,
    image: 'almond croissant.png', type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Butter croissant filled with frangipane and toasted almonds.',
    stock: 35, avgRating: 4.8, reviewCount: 14, calories: 430, prepMinutes: 2,
  ),
  _p(
    name: 'Pain au Chocolat', slug: 'pain-au-chocolat', price: 3.50,
    image: 'pain au chocolat.png', type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Laminated pastry wrapped around two dark chocolate batons.',
    stock: 38, avgRating: 4.7, reviewCount: 11, calories: 310, prepMinutes: 2,
  ),
  _p(
    name: 'Blueberry Muffin', slug: 'blueberry-muffin', price: 3.25,
    image: 'blueberry muffin.png', type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Moist muffin bursting with wild blueberries.',
    stock: 42, avgRating: 4.5, reviewCount: 8, calories: 380, prepMinutes: 1,
  ),
  _p(
    name: 'Cinnamon Roll', slug: 'cinnamon-roll', price: 3.95,
    image: 'cinnamon roll.png', type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Soft swirl of cinnamon sugar under a cream-cheese glaze.',
    featured: true, stock: 30, avgRating: 4.9, reviewCount: 23,
    calories: 420, prepMinutes: 2,
  ),
  _p(
    name: 'Brownie Bar', slug: 'brownie-bar', price: 3.25, image: 'brownie bar.png',
    type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Dense, fudgy dark-chocolate brownie.',
    stock: 44, avgRating: 4.6, reviewCount: 10, calories: 340, prepMinutes: 1,
  ),
  _p(
    name: 'Avocado Toast', slug: 'avocado-toast', price: 7.50,
    image: 'avocado toast.png', type: 'MERCH', categoryId: 'c_pastry',
    categoryName: 'Pastries & Baked Goods', categorySlug: 'pastries-baked-goods',
    description: 'Sourdough, smashed avocado, chilli flakes, and lemon.',
    stock: 25, avgRating: 4.5, reviewCount: 7, calories: 290, prepMinutes: 4,
  ),

  // ── Merchandise (MERCH) ──
  _p(
    name: 'BrewPhoria Ceramic Mug', slug: 'brewphoria-ceramic-mug', price: 18.00,
    image: 'BrewPhoria Ceramic Mug.png', type: 'MERCH', categoryId: 'c_merch',
    categoryName: 'Merchandise', categorySlug: 'merchandise',
    description: 'Handcrafted 12 oz ceramic mug with the BrewPhoria logo.',
    featured: true, stock: 50, avgRating: 4.8, reviewCount: 18,
  ),
  _p(
    name: 'Travel Tumbler 16oz', slug: 'travel-tumbler-16oz', price: 32.00,
    image: 'Travel Tumbler 16oz.png', type: 'MERCH', categoryId: 'c_merch',
    categoryName: 'Merchandise', categorySlug: 'merchandise',
    description: 'Vacuum-insulated stainless tumbler — cold 24 h / hot 12 h.',
    stock: 35, avgRating: 4.7, reviewCount: 13,
  ),
  _p(
    name: 'BrewPhoria Tote Bag', slug: 'brewphoria-tote-bag', price: 15.00,
    image: 'BrewPhoria Tote Bag.png', type: 'MERCH', categoryId: 'c_merch',
    categoryName: 'Merchandise', categorySlug: 'merchandise',
    description: 'Heavyweight organic-cotton tote with the BrewPhoria wordmark.',
    stock: 60, avgRating: 4.6, reviewCount: 9,
  ),
  _p(
    name: 'AeroPress Original', slug: 'aeropress-original', price: 39.99,
    image: 'AeroPress Original.png', type: 'MERCH', categoryId: 'c_merch',
    categoryName: 'Merchandise', categorySlug: 'merchandise',
    description: 'The cult-classic immersion brewer for a clean, rich cup.',
    featured: true, stock: 28, avgRating: 4.9, reviewCount: 31,
  ),
];

// ── Reviews (keyed by product slug) — many across multiple products ───────────
Map<String, dynamic> _rev(String id, int rating, String comment, String name,
        int daysAgo, {List<String> images = const []}) =>
    {
      'id': id,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': _iso(daysAgo),
      'user': {'displayName': name, 'avatarUrl': null},
    };

final Map<String, List<Map<String, dynamic>>> mockReviews = {
  'cappuccino': [
    _rev('r1', 5,
        "Genuinely the best cappuccino I've had from an app order. The foam is perfect and it wasn't drowning in milk. My new morning ritual.",
        'Maya R.', 2, images: ['assets/Products/cappuccino.png']),
    _rev('r2', 4,
        "Really solid. Docked one star only because mine came a touch cooler than I'd like — flavour was excellent though.",
        'James T.', 6),
    _rev('r3', 5, 'The oat milk swap is spot on. Sweet enough without being sugary.',
        'Sofia L.', 11),
    _rev('r4', 5, 'Consistently great. I order one almost every day now.', 'Daniel K.', 18),
    _rev('r5', 4, 'Lovely microfoam. Wish the large were a little bigger.', 'Priya N.', 25),
  ],
  'classic-espresso': [
    _rev('r6', 5, 'Proper crema, bold but not bitter. Exactly what an espresso should be.',
        'Marco V.', 1),
    _rev('r7', 5, 'Rich and smooth. You can tell the beans are fresh.', 'Elena F.', 4),
    _rev('r8', 4, 'Great shot, though I like mine a touch longer.', 'Tom H.', 9),
    _rev('r9', 5, 'My daily double. Never disappoints.', 'Aisha M.', 15),
  ],
  'iced-matcha-latte': [
    _rev('r10', 5, 'Vibrant green, creamy, and not chalky at all. Ceremonial grade shows.',
        'Yuki S.', 3, images: ['assets/Products/iced matcha latte.png']),
    _rev('r11', 5, 'The oat milk + matcha combo is unreal. Obsessed.', 'Chloe B.', 7),
    _rev('r12', 4, 'Delicious but I add extra sweet — a little earthy for me otherwise.',
        'Ryan P.', 13),
  ],
  'classic-cold-brew': [
    _rev('r13', 5, 'Smooth, low acid, naturally sweet. I stopped adding milk entirely.',
        'Nina W.', 2),
    _rev('r14', 5, 'This is my summer fuel. Huge caffeine kick without the bitterness.',
        'Omar A.', 8),
    _rev('r15', 4, 'Really good. Would love a larger takeaway size.', 'Grace L.', 20),
  ],
  'aeropress-original': [
    _rev('r16', 5, 'Best \$40 I have spent on coffee gear. Clean, rich cup every time.',
        'Ben C.', 5, images: ['assets/Products/AeroPress Original.png']),
    _rev('r17', 5, 'Travels everywhere with me. Bulletproof and easy to clean.', 'Lena D.', 12),
    _rev('r18', 5, 'The BrewPhoria recommendation nailed it. Total game changer.', 'Sam R.', 19),
    _rev('r19', 4, 'Slight learning curve but worth it once dialled in.', 'Iris K.', 30),
  ],
  'ethiopian-yirgacheffe-250g': [
    _rev('r20', 5, 'Floral and bright — like a completely different drink. Incredible beans.',
        'Hana J.', 4),
    _rev('r21', 5, 'Bergamot and blueberry come through beautifully as pour-over.',
        'Victor S.', 10),
    _rev('r22', 4, 'Lovely but goes fast — wish the 250g were bigger.', 'Mona T.', 22),
  ],
  'cinnamon-roll': [
    _rev('r23', 5, 'Warm, gooey, and the glaze is not too sweet. Pairs perfectly with a flat white.',
        'Derek O.', 3),
    _rev('r24', 5, 'Bakery-quality. Gone in about four bites.', 'Amara E.', 9),
  ],
  'brewphoria-ceramic-mug': [
    _rev('r25', 5, 'Beautiful weight and the glaze is gorgeous. Keeps coffee warm nicely.',
        'Paul M.', 6),
    _rev('r26', 4, 'Great mug, slightly smaller than I pictured but lovely.', 'Zoe H.', 16),
  ],
  'vanilla-latte': [
    _rev('r27', 5, 'Just the right amount of vanilla. Comforting and not cloying.', 'Ella R.', 5),
    _rev('r28', 4, 'Solid go-to. I ask for an extra shot.', 'Karim B.', 14),
  ],
};

// Generic pool for products without a hand-written review set, so the reviews
// screen is never empty. Selection is seeded by slug so a product's reviews are
// stable across reloads.
const List<(int, String)> _genericReviewPool = [
  (5, 'Exactly as described and arrived quickly. Already planning my next order.'),
  (5, 'Really impressed — the quality is a clear step above what I expected.'),
  (4, 'Very good overall. One or two small tweaks and it would be perfect.'),
  (5, 'Slotted straight into my daily routine. Can’t fault it.'),
  (5, 'You can tell real care went into this one. Highly recommend.'),
  (4, 'Dependable and exactly what I hoped for. Happy customer.'),
  (5, 'Genuinely great — the BrewPhoria standard really shows here.'),
  (4, 'Enjoyed it a lot and would gladly buy again.'),
];

const List<String> _genericReviewers = [
  'Alex M.', 'Jordan P.', 'Sam W.', 'Riley T.',
  'Casey L.', 'Morgan D.', 'Taylor R.', 'Jamie K.',
];

/// Curated reviews when they exist, otherwise a deterministic generated set
/// sized to the product's [reviewCount] (capped) so no product reads as empty.
List<Map<String, dynamic>> reviewsForSlug(String slug, int reviewCount) {
  final curated = mockReviews[slug];
  if (curated != null && curated.isNotEmpty) return curated;
  final n = reviewCount.clamp(0, 6);
  if (n == 0) return const [];
  final seed = slug.hashCode.abs();
  return List.generate(n, (i) {
    final (rating, comment) =
        _genericReviewPool[(seed + i) % _genericReviewPool.length];
    return _rev('rg_${slug}_$i', rating, comment,
        _genericReviewers[(seed + i * 3) % _genericReviewers.length], 2 + i * 5);
  });
}

// ── Saved addresses ──────────────────────────────────────────────────────────
final List<Map<String, dynamic>> mockAddresses = [
  {
    'id': 'a_home',
    'label': 'Home',
    'fullName': 'Alex Rivera',
    'phone': '+1 555 0142',
    'street': '124 Maple Street',
    'city': 'Portland',
    'state': 'OR',
    'postalCode': '97201',
    'country': 'US',
    'isDefault': true,
  },
  {
    'id': 'a_work',
    'label': 'Work',
    'fullName': 'Alex Rivera',
    'phone': '+1 555 0199',
    'street': '900 Riverside Ave, Suite 4',
    'city': 'Portland',
    'state': 'OR',
    'postalCode': '97204',
    'country': 'US',
    'isDefault': false,
  },
];
