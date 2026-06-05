import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/product.dart';
import '../models/ai_recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiRecipeService {
  Future<List<AiRecipe>> generateRecipes(List<Product> pantry) async {
    if (pantry.isEmpty) return [];

    final apiKey = dotenv.env['API_KEY'] ?? '';

    final urgent = pantry.where((p) => p.daysUntilExpiry <= 3).map((p) => p.name).toList();
    final altele = pantry.where((p) => p.daysUntilExpiry > 3).map((p) => p.name).toList();

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final prompt = '''
    Ești un asistent culinar inteligent într-o aplicație anti-risipă alimentară.
    Ingrediente care EXPIRĂ URGENT (folosește-le obligatoriu pe acestea): ${urgent.join(', ')}.
    Alte ingrediente din frigider: ${altele.join(', ')}.

    Generează 3 rețete care să folosească ingredientele urgente și, opțional, celelalte. 
    Poți adăuga ingrediente de bază (sare, ulei, etc.) pe lista de lipsuri.

    Răspunde STRICT și EXCLUSIV cu un format JSON valid, ca în exemplul de mai jos (fără blocuri de cod markdown sau text suplimentar). Nu folosi cuvântul json în răspuns.
    [
      {
        "title": "Numele rețetei",
        "description": "Descriere scurtă.",
        "cooking_time": Timpul de gătire în minute,
        "difficulty": "Dificultatea preparării",
        "used_ingredients": ["ingredient urgent", "alt ingredient pe care îl am"],
        "missing_ingredients": ["ingredient care îmi lipsește"],
        "instructions": ["Pasul 1", "Pasul 2", "Pasul 3"]
      }
    ]
    ''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      var text = response.text ?? '[]';
      
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> decodedJson = json.decode(text);
      
      return decodedJson.map((data) => AiRecipe.fromJson(data)).toList();
      
    } catch (e) {
      print('Eroare AI: $e');
      return [];
    }
  }
}