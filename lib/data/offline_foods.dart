import '../models/food_item.dart';

/// Alle Werte pro 100 g (außer wo defaultPortion anders sinnvoll ist).
final List<FoodItem> kOfflineFoods = [
  // --- Getreide & Beilagen ---
  _f('haferflocken', 'Haferflocken', 370, 13.5, 58.7, 7.0, 10.0, 40),
  _f('reis_roh', 'Reis (roh)', 350, 7.0, 78.0, 0.6, 1.3, 60),
  _f('reis_gekocht', 'Reis (gekocht)', 130, 2.7, 28.0, 0.3, 0.4, 150),
  _f('nudeln_roh', 'Nudeln (roh)', 370, 13.0, 72.0, 1.5, 3.0, 80),
  _f('nudeln_gekocht', 'Nudeln (gekocht)', 160, 5.5, 31.0, 0.9, 1.8, 150),
  _f('kartoffel', 'Kartoffel', 70, 2.0, 15.0, 0.1, 2.1, 200),
  _f('kartoffel_püree', 'Kartoffelpüree', 90, 1.8, 14.0, 2.5, 1.5, 200),
  _f('süßkartoffel', 'Süßkartoffel', 86, 1.6, 20.0, 0.1, 3.0, 150),
  _f('quinoa_gekocht', 'Quinoa (gekocht)', 120, 4.4, 21.0, 1.9, 2.8, 120),
  _f('couscous_gekocht', 'Couscous (gekocht)', 112, 3.8, 23.0, 0.2, 1.4, 120),

  // --- Brot & Backwaren ---
  _f('vollkornbrot', 'Vollkornbrot', 220, 7.5, 40.0, 3.0, 7.0, 50),
  _f('weißbrot', 'Weißbrot', 265, 8.0, 50.0, 3.0, 2.5, 50),
  _f('toast', 'Toastbrot', 270, 8.0, 50.0, 3.5, 2.5, 30),
  _f('brötchen', 'Brötchen', 280, 9.0, 54.0, 2.5, 2.5, 60),
  _f('brezel', 'Brezel', 300, 8.0, 55.0, 4.0, 2.5, 60),
  _f('croissant', 'Croissant', 410, 8.0, 45.0, 22.0, 2.0, 50),

  // --- Milchprodukte ---
  _f('milch_15', 'Milch 1,5%', 47, 3.4, 4.9, 1.5, 0, 200),
  _f('milch_35', 'Milch 3,5%', 64, 3.3, 4.7, 3.5, 0, 200),
  _f('haferdrink', 'Haferdrink', 45, 0.5, 7.5, 1.5, 0.8, 200),
  _f('joghurt_15', 'Joghurt 1,5%', 50, 4.5, 5.0, 1.5, 0, 150),
  _f('joghurt_griechisch', 'Griechischer Joghurt', 120, 8.0, 4.0, 8.0, 0, 150),
  _f('quark_mager', 'Magerquark', 70, 13.0, 4.0, 0.3, 0, 150),
  _f('quark_20', 'Quark 20% i.Tr.', 140, 12.0, 3.5, 8.0, 0, 150),
  _f('skyr', 'Skyr', 65, 11.0, 4.0, 0.2, 0, 150),
  _f('käse_gouda', 'Gouda', 350, 25.0, 0, 28.0, 0, 30),
  _f('käse_mozzarella', 'Mozzarella', 280, 18.0, 2.0, 22.0, 0, 50),
  _f('frischkäse', 'Frischkäse', 240, 8.0, 3.0, 22.0, 0, 30),
  _f('butter', 'Butter', 740, 0.7, 0.6, 82.0, 0, 10),
  _f('margarine', 'Margarine', 720, 0.2, 0.5, 80.0, 0, 10),

  // --- Eier & Fleisch ---
  _f('ei', 'Ei (Hühnerei)', 155, 13.0, 1.1, 11.0, 0, 60),
  _f('eiklar', 'Eiklar', 50, 11.0, 0.7, 0.2, 0, 30),
  _f('hähnchenbrust', 'Hähnchenbrust', 110, 23.0, 0, 1.5, 0, 150),
  _f('hähnchenkeule', 'Hähnchenkeule', 180, 18.0, 0, 12.0, 0, 120),
  _f('pute', 'Putenbrust', 105, 24.0, 0, 1.0, 0, 150),
  _f('rind_hack', 'Rinderhackfleisch', 250, 20.0, 0, 18.0, 0, 120),
  _f('schwein_hack', 'Schweinehackfleisch', 270, 17.0, 0, 22.0, 0, 120),
  _f('hack_gemischt', 'Hackfleisch gemischt', 260, 18.0, 0, 20.0, 0, 120),
  _f('rind_steak', 'Rindersteak', 180, 26.0, 0, 8.0, 0, 150),
  _f('schweineschnitzel', 'Schweineschnitzel (roh)', 150, 22.0, 0, 7.0, 0, 130),
  _f('lachs', 'Lachs', 210, 20.0, 0, 14.0, 0, 120),
  _f('thunfisch', 'Thunfisch (Dose, abgetropft)', 110, 25.0, 0, 1.0, 0, 80),
  _f('garnele', 'Garnelen', 85, 18.0, 1.0, 1.0, 0, 100),
  _f('tofu', 'Tofu natur', 120, 12.0, 2.0, 7.0, 1.0, 100),

  // --- Wurst & Aufschnitt ---
  _f('schinken', 'Kochschinken', 110, 20.0, 1.0, 3.0, 0, 30),
  _f('salami', 'Salami', 400, 20.0, 1.0, 35.0, 0, 20),
  _f('leberwurst', 'Leberwurst', 320, 14.0, 2.0, 28.0, 0, 30),
  _f('wurst_bratwurst', 'Bratwurst', 300, 14.0, 1.0, 27.0, 0, 80),

  // --- Obst ---
  _f('apfel', 'Apfel', 52, 0.3, 14.0, 0.2, 2.4, 150),
  _f('banane', 'Banane', 89, 1.1, 23.0, 0.3, 2.6, 120),
  _f('orange', 'Orange', 47, 0.9, 12.0, 0.1, 2.4, 150),
  _f('birne', 'Birne', 57, 0.4, 15.0, 0.1, 3.1, 150),
  _f('erdbeere', 'Erdbeeren', 32, 0.7, 7.7, 0.3, 2.0, 100),
  _f('blaubeere', 'Heidelbeeren', 57, 0.7, 14.0, 0.3, 2.4, 100),
  _f('trauben', 'Trauben', 70, 0.6, 17.0, 0.2, 0.9, 100),
  _f('mango', 'Mango', 60, 0.8, 15.0, 0.4, 1.6, 150),
  _f('avocado', 'Avocado', 160, 2.0, 9.0, 15.0, 7.0, 100),

  // --- Gemüse ---
  _f('tomate', 'Tomate', 18, 0.9, 3.9, 0.2, 1.2, 100),
  _f('gurke', 'Gurke', 12, 0.6, 2.0, 0.1, 0.5, 100),
  _f('paprika', 'Paprika', 27, 1.0, 6.0, 0.3, 2.1, 100),
  _f('broccoli', 'Brokkoli', 34, 2.8, 7.0, 0.4, 2.6, 100),
  _f('spinat', 'Spinat', 23, 2.9, 3.6, 0.4, 2.2, 100),
  _f('möhre', 'Möhre', 41, 0.9, 10.0, 0.2, 2.8, 100),
  _f('zwiebel', 'Zwiebel', 40, 1.1, 9.0, 0.1, 1.7, 50),
  _f('salat', 'Kopfsalat', 14, 1.2, 2.0, 0.2, 1.2, 50),
  _f('mais', 'Mais (Dose)', 90, 3.0, 18.0, 1.2, 2.5, 80),
  _f('erbsen', 'Erbsen', 80, 5.5, 14.0, 0.4, 5.0, 80),
  _f('bohnen_weiß', 'Weiße Bohnen (gekocht)', 115, 8.0, 20.0, 0.5, 6.5, 100),
  _f('kichererbsen', 'Kichererbsen (gekocht)', 160, 8.5, 27.0, 2.5, 7.5, 100),
  _f('linse', 'Linsen (gekocht)', 115, 9.0, 20.0, 0.4, 8.0, 100),

  // --- Nüsse & Samen ---
  _f('mandel', 'Mandeln', 580, 21.0, 22.0, 50.0, 12.0, 20),
  _f('walnuss', 'Walnüsse', 650, 15.0, 14.0, 65.0, 7.0, 20),
  _f('erdnuss', 'Erdnüsse', 570, 25.0, 16.0, 48.0, 8.0, 20),
  _f('cashew', 'Cashewkerne', 550, 18.0, 30.0, 44.0, 3.0, 20),
  _f('chia', 'Chiasamen', 480, 17.0, 42.0, 31.0, 34.0, 15),
  _f('lein_samen', 'Leinsamen', 530, 18.0, 29.0, 42.0, 27.0, 15),

  // --- Öle & Fette ---
  _f('olivenöl', 'Olivenöl', 885, 0, 0, 100.0, 0, 10),
  _f('rapsöl', 'Rapsöl', 885, 0, 0, 100.0, 0, 10),
  _f('sonnenblumenöl', 'Sonnenblumenöl', 885, 0, 0, 100.0, 0, 10),

  // --- Süßes & Sonstiges ---
  _f('zucker', 'Zucker', 400, 0, 100.0, 0, 0, 10),
  _f('honig', 'Honig', 300, 0.3, 82.0, 0, 0, 15),
  _f('schokolade_vollmilch', 'Vollmilchschokolade', 530, 7.0, 58.0, 30.0, 3.0, 20),
  _f('schokolade_dunkel', 'Dunkle Schokolade 70%', 580, 8.0, 45.0, 42.0, 10.0, 20),
  _f('marmelade', 'Marmelade', 250, 0.4, 62.0, 0.1, 1.0, 20),
  _f('nutella', 'Nuss-Nougat-Creme', 540, 6.0, 57.0, 31.0, 3.0, 20),

  // --- Getränke (pro 100 ml ≈ 100 g) ---
  _f('cola', 'Cola', 42, 0, 10.6, 0, 0, 250),
  _f('orangensaft', 'Orangensaft', 45, 0.7, 10.0, 0.2, 0.2, 200),
  _f('apfelsaft', 'Apfelsaft', 46, 0.1, 11.0, 0.1, 0.1, 200),
  _f('bier', 'Bier (Pils)', 42, 0.5, 3.3, 0, 0, 300),
  _f('wein_rot', 'Rotwein', 85, 0.1, 2.6, 0, 0, 150),

  // --- Fast Food (Richtwerte, öffentlich üblich) ---
  _f('big_mac', 'McDonald\'s Big Mac', 257, 12.0, 20.0, 14.0, 1.5, 220), // pro 100g; Portion \~220g
  _f('pommes', 'Pommes frites', 300, 3.5, 38.0, 15.0, 3.5, 120),
  _f('chicken_nuggets', 'Chicken Nuggets', 280, 15.0, 18.0, 16.0, 1.0, 100),
  _f('pizza_salami', 'Pizza Salami', 270, 11.0, 30.0, 12.0, 2.0, 300),
  _f('döner', 'Döner Kebab', 220, 12.0, 18.0, 11.0, 1.5, 300),
  _f('burger_generic', 'Hamburger (Standard)', 250, 12.0, 24.0, 12.0, 1.5, 150),
  _f('currywurst', 'Currywurst mit Sauce', 250, 12.0, 10.0, 18.0, 0.5, 150),
];

FoodItem _f(
  String id,
  String name,
  double kcal,
  double protein,
  double carbs,
  double fat,
  double fiber,
  double portion,
) {
  return FoodItem(
    id: id,
    name: name,
    kcal: kcal,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: fiber,
    defaultPortion: portion,
  );
}
