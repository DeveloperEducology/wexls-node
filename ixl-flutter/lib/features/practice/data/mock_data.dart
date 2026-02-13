import 'dart:math';
import '../domain/models.dart';

class MockData {
  static final Random _rnd = Random();

  static final List<QuestionModel> _questions = [
    // 1. Counting with Images (MCQ)
    QuestionModel(
      id: '1',
      type: QuestionType.mcq,
      parts: [
        QuestionPart(type: QuestionPartType.text, content: 'Count the birds by 1s.'),
        QuestionPart(
          type: QuestionPartType.image, 
          // Placeholder image (in real app us assets or network)
          imageUrl: 'https://cdn-icons-png.flaticon.com/512/3069/3069172.png', 
          height: 100,
        ),
         QuestionPart(type: QuestionPartType.text, content: 'How many birds are conceptually in this image? (Let\'s say 5)'),
      ],
      options: ['3', '4', '5', '6'],
      correctAnswerIndex: 2, // '5'
      solution: 'Count them one by one: 1, 2, 3, 4, 5.',
      category: 'Counting',
    ),

    // 2. Skip Counting (Text Input)
    QuestionModel(
      id: '2',
      type: QuestionType.textInput,
      parts: [
        QuestionPart(type: QuestionPartType.text, content: 'Skip-counting by 5s.'),
        QuestionPart(type: QuestionPartType.math, content: r'5, 10, \_, 20'),
      ],
      correctAnswerText: '15',
      solution: 'We are adding 5 each time. 10 + 5 = 15.',
      category: 'NumPatterns',
    ),

    // 3. Comparison (MCQ)
    QuestionModel(
      id: '3',
      type: QuestionType.mcq,
      parts: [
        QuestionPart(type: QuestionPartType.text, content: 'Which number is greater?'),
      ],
      options: ['12', '45', '8', '21'],
      correctAnswerIndex: 1, // '45'
      solution: 'Compare the tens place. 4 tens is more than 1 or 2 tens.',
      category: 'Comparing',
    ),
    
    // 4. Geometry (Diagram/Image)
    QuestionModel(
      id: '4',
      type: QuestionType.mcq,
      parts: [
        QuestionPart(type: QuestionPartType.text, content: 'What shape is this?'),
        // Using emoji as a poor man's diagram if SVG not setup, but use Math/Text
        QuestionPart(type: QuestionPartType.text, content: '🔺'),
      ],
      options: ['Circle', 'Square', 'Triangle'],
      correctAnswerIndex: 2,
      solution: 'A shape with 3 sides is a triangle.',
      category: 'Geometry',
    ),
  ];

  static QuestionModel getNextQuestion(int currentScore) {
    return _questions[_rnd.nextInt(_questions.length)];
  }
}
