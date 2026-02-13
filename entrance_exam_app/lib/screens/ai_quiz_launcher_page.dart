import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'ai_review_screen.dart';

class AIQuizLauncherPage extends StatefulWidget {
  const AIQuizLauncherPage({super.key});

  @override
  State<AIQuizLauncherPage> createState() => _AIQuizLauncherPageState();
}

class _AIQuizLauncherPageState extends State<AIQuizLauncherPage> with SingleTickerProviderStateMixin {
  // IMPORTANT: In production, API keys should not be stored in git/code directly.
  static const String _apiKey = 'AIzaSyCNrB0T8geApumdfyCEdLjqXkP9TjcFXgA';
  
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = "";
  String? _selectedSubject;
  String? _activeTopic; 
  bool _isTelugu = false;
  
  String _selectedDifficulty = "Moderate";
  final List<String> _difficultyLevels = ["Easy", "Moderate", "Hard", "Super Hard"];

  final List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isSubmitted = false;
  bool _quizCompleted = false;

  final Map<String, Map<String, Map<String, List<String>>>> _curriculum = {
    "Class 6": {
      "Mathematics": {
        "Number System": ["Place Value", "HCF & LCM", "Factors & Multiples", "Rounding Off"],
        "Arithmetic": ["Decimals", "Percentage", "Profit & Loss", "Simple Interest"],
        "Geometry": ["Area & Perimeter", "Volume of Cuboid", "Angles"],
      },
      "Mental Ability": {
        "Visual Reasoning": ["Mirror Imaging", "Pattern Completion", "Odd Man Out", "Figure Matching"],
      }
    },
    "Class 9": {
      "Mathematics": {
        "Algebra": ["Rational Numbers", "Exponents & Powers", "Square & Cube Roots", "Linear Equations"],
        "Geometry": ["Quadrilaterals", "Surface Area & Volume", "Data Handling"],
      },
      "Science": {
        "Biology": ["Crop Production", "Microorganisms", "Cell Structure"],
        "Physics": ["Force & Pressure", "Sound", "Light"],
      }
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _generateAIQuiz(String topic) async {
    setState(() {
      _isLoading = true;
      _activeTopic = topic;
      _questions.clear();
      _quizCompleted = false;
      _currentIndex = 0;
      _score = 0;
      _isSubmitted = false;
    });

    final grade = _tabController.index == 0 ? "Class 6" : "Class 9";

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      
      final prompt = """
        Generate a 5-question Navodaya Exam Mock Test for $grade.
        Topic: $topic. Difficulty: $_selectedDifficulty.
        Language: ${_isTelugu ? "Bilingual (English and Telugu)" : "English"}.
        
        RULES:
        1. Use LaTeX for ALL math.
        2. If the topic is Geometry or Mensuration, provide an SVG diagram string in a "diagram" field.
        3. Format: Return ONLY a STRICT JSON array.
        Schema: [{"question": "text", "math": "latex", "diagram": "svg_string_optional", "options": [{"text": "text", "math": "latex"}], "answerIndex": 0, "steps": ["step 1"], "exp_math": "latex"}]
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      
      String cleanJson = response.text!.trim();
      // Remove markdown code blocks if present
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      
      final List<dynamic> data = jsonDecode(cleanJson);

      setState(() {
        _questions.addAll(data.cast<Map<String, dynamic>>());
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI Study Room", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Row(
            children: [
              const Text("తెలుగు", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Switch(value: _isTelugu, onChanged: (v) => setState(() => _isTelugu = v)),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() { _selectedSubject = null; _searchQuery = ""; _searchController.clear(); }),
          tabs: const [Tab(text: "Class 6"), Tab(text: "Class 9")],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _questions.isEmpty 
              ? _buildSelectionUI() 
              : (_quizCompleted ? _buildSummaryView() : _buildQuizView()),
    );
  }

  // FIXED: Selection UI with layout constraints to prevent overflow
  Widget _buildSelectionUI() {
    final grade = _tabController.index == 0 ? "Class 6" : "Class 9";
    final subjects = _curriculum[grade]!;
    
    final List<String> allTopics = [];
    subjects.forEach((s, units) => units.forEach((u, topics) => allTopics.addAll(topics)));
    final filteredTopics = allTopics.where((t) => t.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Expanded Difficulty Dropdown to prevent Row overflow
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: "Difficulty",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: _difficultyLevels.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level, style: const TextStyle(fontSize: 12)),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedDifficulty = v!),
                  ),
                ),
                const SizedBox(width: 8),
                // Expanded Search Bar
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: "Search topics...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_searchQuery.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Select Subject", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            // Use Wrap for Chips to prevent overflow if subjects grow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects.keys.map((s) => ChoiceChip(
                  label: Text(s),
                  selected: _selectedSubject == s,
                  onSelected: (v) => setState(() => _selectedSubject = s),
                )).toList(),
              ),
            ),
            if (_selectedSubject != null) ...[
              const SizedBox(height: 24),
              ...subjects[_selectedSubject]!.keys.map((unit) => ExpansionTile(
                title: Text(unit, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: subjects[_selectedSubject]![unit]!.map((topic) => ListTile(
                  title: Text(topic),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _generateAIQuiz(topic),
                )).toList(),
              )).toList(),
            ]
          ] else _buildSearchResultsView(filteredTopics),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView(List<String> results) {
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Icon(Icons.psychology, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No curriculum found for '$_searchQuery'"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _generateAIQuiz(_searchQuery),
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Create Custom AI Quiz"),
            )
          ],
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.bolt, color: Colors.orange),
        title: Text(results[index]),
        onTap: () => _generateAIQuiz(results[index]),
      ),
    );
  }

  Widget _buildQuizView() {
    final q = _questions[_currentIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question ${_currentIndex + 1}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              Chip(label: Text(_selectedDifficulty, style: const TextStyle(fontSize: 10)), backgroundColor: Colors.orange.shade50),
            ],
          ),
          const SizedBox(height: 10),
          Text(q['question'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          
          // DIAGRAM RENDERER: Renders SVG if provided by AI
          if (q['diagram'] != null && q['diagram'].toString().contains('<svg')) ...[
            const SizedBox(height: 20),
            Center(
              child: SvgPicture.string(
                q['diagram'],
                height: 180,
                placeholderBuilder: (context) => const CircularProgressIndicator(),
              ),
            ),
          ],

          if (q['math'] != null) ...[
            const SizedBox(height: 10),
            Math.tex(q['math'], textStyle: const TextStyle(fontSize: 22)),
          ],
          const SizedBox(height: 30),
          ...List.generate(4, (i) => _buildOption(q, i)),
          if (_isSubmitted) _buildSolutionBox(q),
          const SizedBox(height: 30),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildOption(Map<String, dynamic> q, int i) {
    if (q['options'] == null || i >= (q['options'] as List).length) return SizedBox.shrink();
    
    final isCorrect = i == q['answerIndex'];
    final isSelected = _selectedAnswerIndex == i;
    Color color = Colors.white;
    if (_isSubmitted) {
      if (isCorrect) color = Colors.green.shade50;
      else if (isSelected) color = Colors.red.shade50;
    } else if (isSelected) {
      color = Colors.blue.shade50;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
      ),
      color: color,
      child: ListTile(
        title: Text(q['options'][i]['text']),
        onTap: _isSubmitted ? null : () => setState(() => _selectedAnswerIndex = i),
      ),
    );
  }

  Widget _buildSolutionBox(Map<String, dynamic> q) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Step-by-Step Explanation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const Divider(),
          if (q['steps'] != null)
          ...(q['steps'] as List).map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("• $s", style: const TextStyle(fontSize: 14)),
          )),
          if (q['exp_math'] != null) Math.tex(q['exp_math'], textStyle: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (!_isSubmitted) {
      return SizedBox(
        width: double.infinity, 
        height: 50, 
        child: ElevatedButton(
          onPressed: _selectedAnswerIndex == null ? null : () => setState(() {
            _isSubmitted = true;
            if (_selectedAnswerIndex == _questions[_currentIndex]['answerIndex']) _score++;
          }),
          child: const Text("Submit Answer"),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity, 
        height: 50, 
        child: ElevatedButton(
          onPressed: () => setState(() {
            if (_currentIndex < _questions.length - 1) {
              _currentIndex++; _selectedAnswerIndex = null; _isSubmitted = false;
            } else { _quizCompleted = true; }
          }),
          child: Text(_currentIndex < _questions.length - 1 ? "Next Question" : "View Results"),
        ),
      );
    }
  }

  Widget _buildSummaryView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 100, color: Colors.orange),
          const SizedBox(height: 20),
          const Text("Session Complete!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text("Score: $_score / ${_questions.length}", style: const TextStyle(fontSize: 24, color: Colors.green)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIReviewScreen(aiData: _questions, topic: _activeTopic ?? "Navodaya"))),
            icon: const Icon(Icons.rate_review),
            label: const Text("Review & Save to Cloud"),
          ),
        ],
      ),
    );
  }
}
