import 'package:flutter/material.dart';

class Subject {
  final String name;
  final double progress; // 0.0 to 1.0
  final int questionCount;
  final Color color;
  final IconData icon;

  Subject({
    required this.name,
    required this.progress,
    required this.questionCount,
    required this.color,
    required this.icon,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'] ?? 'Subject',
      progress: (json['progress'] ?? 0.0).toDouble(), // TODO: Fetch real user progress later
      questionCount: json['question_count'] ?? 0,
      color: _parseColor(json['color_hex']),
      icon: _parseIcon(json['icon_name']),
    );
  }

  static Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hexString));
    } catch (e) {
      return Colors.blue;
    }
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'psychology': return Icons.psychology;
      case 'calculate': return Icons.calculate;
      case 'language': return Icons.language;
      case 'science': return Icons.science;
      case 'functions': return Icons.functions;
      case 'biotech': return Icons.biotech;
      case 'eco': return Icons.eco;
      case 'menu_book': return Icons.menu_book;
      case 'public': return Icons.public;
      default: return Icons.book;
    }
  }
}

class ExamCategory {
  final String id;
  final String displayName;
  final String subText;
  final String iconName;
  final bool isActive;

  ExamCategory({
    required this.id, 
    required this.displayName,
    required this.subText,
    required this.iconName,
    required this.isActive,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) {
    return ExamCategory(
      id: json['id'].toString(),
      displayName: json['display_name'] ?? '',
      subText: json['sub_text'] ?? '',
      iconName: json['icon_name'] ?? 'menu_book',
      isActive: json['is_active'] ?? false,
    );
  }
}

class Test {
  final String id;
  final String title;
  final DateTime date;
  final int duration; // Changed to int (minutes) as per JSON example
  final String description;
  final String category;
  final String targetClass;
  final bool isFree;
  final String type; // 'mock' or 'previous'

  Test({
    this.id = '', 
    required this.title, 
    required this.date, 
    required this.duration,
    required this.description,
    required this.category,
    required this.targetClass,
    required this.isFree,
    this.type = 'mock',
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'].toString(),
      title: json['title'] ?? 'Untitled Test',
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration'].toString()) ?? 0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      targetClass: json['target_class'] ?? '',
      isFree: json['is_free'] ?? false,
      type: json['type'] ?? 'mock',
    );
  }
}

class Activity {
  final String testName;
  final int score;
  final int totalScore;
  final bool passed;
  final String date;

  Activity({
    required this.testName,
    required this.score,
    required this.totalScore,
    required this.passed,
    required this.date,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      testName: json['test_title'] ?? 'Unknown Test',
      score: json['score'] ?? 0,
      totalScore: json['total_score'] ?? 0,
      passed: json['passed'] ?? false,
      date: _formatDate(json['created_at']),
    );
  }

  static String _formatDate(String? isoString) {
    if (isoString == null) return 'Unknown Date';
    try {
      final dt = DateTime.parse(isoString);
      // Simple format: DD Mon, HH:MM
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[dt.month - 1];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return "${dt.day} $month, $hour:$min $ampm";
    } catch (e) {
      return isoString;
    }
  }
}

enum QuestionPartType { text, math, diagram, image }

// Helper to safely parse parts from List<Map>, List<String>, or String
List<QuestionPart> _parseParts(dynamic input) {
  if (input is List) {
    return input.map((e) {
      if (e is Map) {
         return QuestionPart.fromJson(Map<String, dynamic>.from(e));
      } else if (e is String) {
        String trimmed = e.trim();
        // Auto-detect type if just string
        if (trimmed.startsWith(r'\(') || trimmed.startsWith(r'$$')) {
           return QuestionPart(type: QuestionPartType.math, content: e);
        } else if (trimmed.toLowerCase().startsWith('<svg')) {
           return QuestionPart(type: QuestionPartType.diagram, content: e);
        } else if (trimmed.startsWith('http') && (
           trimmed.contains('.png') || 
           trimmed.contains('.jpg') || 
           trimmed.contains('.jpeg') || 
           trimmed.contains('.gif') || 
           trimmed.contains('.webp'))) {
           return QuestionPart(type: QuestionPartType.image, content: e);
        }
        return QuestionPart(type: QuestionPartType.text, content: e);
      }
      return QuestionPart(type: QuestionPartType.text, content: e.toString());
    }).toList();
  } else if (input is String) {
      String trimmed = input.trim();
      if (trimmed.toLowerCase().startsWith('<svg')) {
         return [QuestionPart(type: QuestionPartType.diagram, content: input)];
      } else if (trimmed.startsWith('http') && (
           trimmed.contains('.png') || 
           trimmed.contains('.jpg') || 
           trimmed.contains('.jpeg') || 
           trimmed.contains('.gif') || 
           trimmed.contains('.webp'))) {
           return [QuestionPart(type: QuestionPartType.image, content: input)];
      }
    return [QuestionPart(type: QuestionPartType.text, content: input)];
  }
  return [];
}

class QuestionPart {
  final QuestionPartType type;
  final String content;

  QuestionPart({required this.type, required this.content});

  factory QuestionPart.fromJson(Map<String, dynamic> json) {
    return QuestionPart(
      type: QuestionPartType.values.firstWhere((e) => e.toString().split('.').last == json['type'], orElse: () => QuestionPartType.text),
      content: json['content'] ?? '',
    );
  }
}

class QuestionOption {
  final String id;
  final List<QuestionPart> parts;

  QuestionOption({required this.id, required this.parts});

  factory QuestionOption.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      // Robustly handle 'parts' which might be list of strings or list of maps or just string
      return QuestionOption(
        id: json['id'] ?? '',
        parts: _parseParts(json['parts']),
      );
    } else if (json is String) {
      // Handle case where option is just a string, e.g. "A", or SVG string
      return QuestionOption(id: "", parts: _parseParts(json));
    }
    // Fallback
    return QuestionOption(id: "", parts: []); 
  }
}

class Question {
  final String id;
  final List<QuestionPart> parts;
  final List<QuestionOption> options;
  final int correctOptionIndex;
  final String explanation; // For Practice Mode
  final String layout; // 'list' (default) or 'grid'

  Question({
    required this.id,
    required this.parts,
    required this.options,
    required this.correctOptionIndex,
    this.explanation = "",
    this.layout = 'list',
  });

  factory Question.fromJson(Map<String, dynamic> json) {
     var partsList = _parseParts(json['parts']);
     
     List<QuestionOption> optionsList = [];
     var opts = json['options'];
     if (opts is List) {
       optionsList = opts.map((e) {
         if (e is Map) {
           return QuestionOption.fromJson(Map<String, dynamic>.from(e));
         } 
         return QuestionOption.fromJson(e);
       }).toList();
     }
     
     return Question(
       id: json['id'].toString(),
       parts: partsList,
       options: optionsList,
       correctOptionIndex: json['correct_option_index'] ?? 0,
       explanation: json['explanation'] ?? '',
       layout: json['layout'] ?? 'list',
     );
  }
}
class Quiz {
  static List<Question> get sampleData => [
    Question(
      id: "1",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: "What is the unit of Force?"),
      ],
      options: [
        QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.text, content: "Newton")]),
        QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.text, content: "Joule")]),
        QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.text, content: "Watt")]),
        QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.text, content: "Pascal")]),
      ],
      correctOptionIndex: 0,
       explanation: "Force is essentially a push or a pull. The SI unit of Force is the Newton (N).",
    ),
    Question(
      id: "2",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: "Calculate the force required to accelerate a 2kg mass by"),
        QuestionPart(type: QuestionPartType.math, content: r"5 m/s^2"),
      ],
      options: [
         QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.text, content: "2 N")]),
         QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.text, content: "5 N")]),
         QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.text, content: "10 N")]),
         QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.text, content: "7 N")]),
      ],
      correctOptionIndex: 2,
      explanation: r"Using Newton's Second Law: $F = ma$. $F = 2 \times 5 = 10 \text{ N}$",
    ),
    Question(
      id: "3",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: "The value of g is approximately:"),
      ],
      options: [
        QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.text, content: "9.8 m/s²")]),
        QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.text, content: "10.5 m/s²")]),
        QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.text, content: "8.9 m/s²")]),
        QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.text, content: "9.1 m/s²")]),
      ],
      correctOptionIndex: 0,
      explanation: "Standard gravity on Earth is 9.80665 m/s².",
    ),
    Question(
      id: "4",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: "Which formula represents Ohm's Law?"),
        QuestionPart(type: QuestionPartType.math, content: r"V = IR"),
      ],
       options: [
        QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.math, content: r"V = I/R")]),
        QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.math, content: r"V = IR")]),
        QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.math, content: r"R = VI")]),
        QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.math, content: r"I = VR")]),
      ],
      correctOptionIndex: 1,
      explanation: "Ohm's law states that the voltage V across a conductor is proportional to the current I. V = IR.",
    ),
  ];

  static List<Question> get jeeMathsMock => [
    Question(
      id: "101",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: "Evaluate the limit:"),
        QuestionPart(type: QuestionPartType.math, content: r"\lim_{x \to 0} \frac{\sin(x) - x}{x^3}"),
      ],
      options: [
         QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.math, content: r"-\frac{1}{6}")]),
         QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.math, content: r"\frac{1}{6}")]),
         QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.math, content: r"0")]),
         QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.math, content: r"1")]),
      ],
      correctOptionIndex: 0,
      explanation: r"Using L'Hospital's Rule thrice or Taylor Series expansion of $\sin(x)$: $\sin(x) \approx x - \frac{x^3}{3!} + \dots$. Then $\frac{(x - x^3/6) - x}{x^3} = -\frac{1}{6}$.",
    ),
    Question(
      id: "102",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: r"If $z$ is a complex number such that $|z| = 1$, find the real part of:"),
        QuestionPart(type: QuestionPartType.math, content: r"\frac{z - 1}{z + 1}"),
      ],
      options: [
         QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.text, content: "1")]),
         QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.text, content: "0")]),
         QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.text, content: "1/2")]),
         QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.text, content: "-1")]),
      ],
      correctOptionIndex: 1,
      explanation: r"Let $z = e^{i\theta}$. Then $\frac{e^{i\theta}-1}{e^{i\theta}+1} = \frac{e^{i\theta/2}(e^{i\theta/2}-e^{-i\theta/2})}{e^{i\theta/2}(e^{i\theta/2}+e^{-i\theta/2})} = \frac{2i\sin(\theta/2)}{2\cos(\theta/2)} = i\tan(\theta/2)$. Purely imaginary, so real part is 0.",
    ),
    Question(
      id: "103",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: "Find the value of the integral:"),
        QuestionPart(type: QuestionPartType.math, content: r"\int_{0}^{\pi/2} \frac{\sin x}{\sin x + \cos x} dx"),
      ],
      options: [
         QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.math, content: r"\pi/2")]),
         QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.math, content: r"\pi/4")]),
         QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.math, content: r"\pi")]),
         QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.math, content: r"0")]),
      ],
      correctOptionIndex: 1,
      explanation: r"Use the property $\int_0^a f(x)dx = \int_0^a f(a-x)dx$. Let $I = \int \dots$. Then $I = \int \frac{\cos x}{\cos x + \sin x}$. $2I = \int 1 dx = \pi/2 \implies I = \pi/4$.",
    ),
    Question(
      id: "104",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: r"The number of real solutions of the equation $x^2 + 5|x| + 4 = 0$ is:"),
      ],
      options: [
         QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.text, content: "4")]),
         QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.text, content: "2")]),
         QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.text, content: "0")]),
         QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.text, content: "1")]),
      ],
      correctOptionIndex: 2,
      explanation: r"Since $|x| \ge 0$, $x^2 + 5|x| + 4$ is always $\ge 4$ (sum of positive terms + 4). It can never be 0. Thus, no solution.",
    ),
    Question(
      id: "105",
      parts: [
        QuestionPart(type: QuestionPartType.text, content: r"If the matrix $A$ is involutory, then $A^2$ is equal to:"),
      ],
      options: [
         QuestionOption(id: "A", parts: [QuestionPart(type: QuestionPartType.math, content: "A")]),
         QuestionOption(id: "B", parts: [QuestionPart(type: QuestionPartType.math, content: "I")]),
         QuestionOption(id: "C", parts: [QuestionPart(type: QuestionPartType.math, content: "0")]),
         QuestionOption(id: "D", parts: [QuestionPart(type: QuestionPartType.math, content: "-I")]),
      ],
      correctOptionIndex: 1,
      explanation: r"An involutory matrix is a matrix that is its own inverse, i.e., $A^2 = I$.",
    ),
  ];
}

class MicroSkill {
  final String id;
  final String title;
  final double progress; // 0.0 to 1.0
  final bool isLocked;

  MicroSkill({
    required this.id,
    required this.title,
    this.progress = 0.0,
    this.isLocked = false,
  });

  factory MicroSkill.fromJson(Map<String, dynamic> json) {
    return MicroSkill(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      progress: 0.0, // Default to 0, TODO: fetch progress
      isLocked: false, // Default to unlocked for now
    );
  }
}

class Unit {
  final String id;
  final String title;
  final String description;
  final List<MicroSkill> microSkills;

  Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.microSkills,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    var skills = <MicroSkill>[];
    if (json['micro_skills'] != null) {
      skills = (json['micro_skills'] as List).map((e) => MicroSkill.fromJson(e)).toList();
      skills.sort((a, b) => (json['order_index'] ?? 0).compareTo(json['order_index'] ?? 0)); // Simple sort
    }

    return Unit(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      microSkills: skills,
    );
  }

  static List<Unit> getSampleUnits(String subjectName) {
    if (subjectName == "Physics") {
      return [
        Unit(
          id: "p0",
          title: "Kinematics",
          description: "Motion in a straight line and vectors.",
          microSkills: [
            MicroSkill(id: "ms1", title: "Distance vs Displacement", progress: 0.8),
            MicroSkill(id: "ms2", title: "Velocity & Speed", progress: 0.5),
            MicroSkill(id: "ms3", title: "Acceleration", progress: 0.2),
            MicroSkill(id: "ms4", title: "Equations of Motion", isLocked: true),
          ],
        ),
        Unit(
          id: "p1",
          title: "Introduction",
          description: "Introduction to physics.",
          microSkills: [
            MicroSkill(id: "ms1", title: "Distance vs Displacement", progress: 0.8),
            MicroSkill(id: "ms2", title: "Velocity & Speed", progress: 0.5),
            MicroSkill(id: "ms3", title: "Acceleration", progress: 0.2),
            MicroSkill(id: "ms4", title: "Equations of Motion", isLocked: true),
          ],
        ),
        Unit(
          id: "p2",
          title: "Laws of Motion",
          description: "Newton's laws and their applications.",
          microSkills: [
            MicroSkill(id: "ms5", title: "Newton's First Law", isLocked: true),
            MicroSkill(id: "ms6", title: "Newton's Second Law", isLocked: true),
          ],
        ),
      ];
    } else if (subjectName == "Math") {
      return [
        Unit(
          id: "m1",
          title: "Algebra",
          description: "Basic algebraic operations and equations.",
          microSkills: [
             MicroSkill(id: "ms7", title: "Linear Equations", progress: 1.0),
             MicroSkill(id: "ms8", title: "Quadratic Equations", progress: 0.4),
             MicroSkill(id: "ms9", title: "Polynomials", isLocked: true),
          ]
        ),
         Unit(
          id: "m2",
          title: "Trigonometry",
          description: "Angles, triangles and functions.",
          microSkills: [
             MicroSkill(id: "ms10", title: "Introduction", isLocked: true),
             MicroSkill(id: "ms11", title: "Heights and Distances", isLocked: true),
          ]
        ),
      ];
    } else if (subjectName == "Mental Ability") {
      return [
        Unit(
          id: "ma1",
          title: "Odd Man Out",
          description: "Identify the figure that is different from others.",
          microSkills: [
             MicroSkill(id: "ma_ms1", title: "Figure Classification", progress: 0.5),
             MicroSkill(id: "ma_ms2", title: "Pattern Spotting", isLocked: true),
          ]
        ),
        Unit(
          id: "ma2",
          title: "Figure Matching",
          description: "Find the exact match to the problem figure.",
          microSkills: [
             MicroSkill(id: "ma_ms3", title: "Exact Match", isLocked: true),
          ]
        ),
        Unit(
          id: "ma3",
          title: "Pattern Completion",
          description: "Complete the missing part of the pattern.",
          microSkills: [
             MicroSkill(id: "ma_ms4", title: "Square Completion", isLocked: true),
          ]
        ),
        Unit(
          id: "ma4",
          title: "Mirror Imaging",
          description: "Identify the mirror reflection.",
          microSkills: [
             MicroSkill(id: "ma_ms5", title: "Mirror Reflections", isLocked: true),
          ]
        ),
      ];
    } else if (subjectName == "Arithmetic") {
      return [
        Unit(
          id: "ar1",
          title: "Number System",
          description: "Understanding numbers and operations.",
          microSkills: [
             MicroSkill(id: "ar_ms1", title: "Types of Numbers", progress: 0.3),
             MicroSkill(id: "ar_ms2", title: "Place Value", isLocked: true),
          ]
        ),
        Unit(
          id: "ar2",
          title: "Fractional Numbers",
          description: "Operations on fractions.",
          microSkills: [
             MicroSkill(id: "ar_ms3", title: "Addition & Subtraction", isLocked: true),
             MicroSkill(id: "ar_ms4", title: "Multiplication & Division", isLocked: true),
          ]
        ),
         Unit(
          id: "ar3",
          title: "LCM and HCF",
          description: "Least Common Multiple and Factors.",
          microSkills: [
             MicroSkill(id: "ar_ms5", title: "Finding Factors", isLocked: true),
             MicroSkill(id: "ar_ms6", title: "Applications", isLocked: true),
          ]
        ),
      ];
    } else if (subjectName == "Language") {
      return [
        Unit(
          id: "ln1",
          title: "Comprehension Passage",
          description: "Reading phrases and understanding context.",
          microSkills: [
             MicroSkill(id: "ln_ms1", title: "Passage Reading 1", progress: 0.1),
             MicroSkill(id: "ln_ms2", title: "Passage Reading 2", isLocked: true),
          ]
        ),
        Unit(
          id: "ln2",
          title: "Grammar Basics",
          description: "Fundamentals of grammar.",
          microSkills: [
             MicroSkill(id: "ln_ms3", title: "Synonyms & Antonyms", isLocked: true),
             MicroSkill(id: "ln_ms4", title: "Correct Usage", isLocked: true),
          ]
        ),
      ];
    }
    // Default/Fallback
    return [
      Unit(
        id: "u1",
        title: "Introduction",
        description: "Basic concepts of $subjectName.",
        microSkills: [
          MicroSkill(id: "ms100", title: "Overview", progress: 0.1),
          MicroSkill(id: "ms101", title: "Key Terminology", isLocked: true),
        ],
      ),
      Unit(
        id: "u2", 
        title: "Advanced Topics",
        description: "Deeper dive into $subjectName.",
        microSkills: [
           MicroSkill(id: "ms102", title: "Concept 1", isLocked: true),
           MicroSkill(id: "ms103", title: "Concept 2", isLocked: true),
        ]
      )
    ];
  }
}
