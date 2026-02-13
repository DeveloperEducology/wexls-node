import 'dart:convert';

enum QuestionType {
  mcq,
  textInput,
  sorting,
  dragAndDrop,
  fillInTheBlank,
  fourPicsOneWord,
  imageChoice,
  measure,
}

enum QuestionPartType {
  text,    
  math,     
  image,    
  diagram,
  input,
  sequence,
  svg,
}

class QuestionPart {
  final QuestionPartType type;
  final String? content;
  final String? imageUrl;
  final double? width;
  final double? height;
  final String? diagramId; 
  final String? id; // For input parts
  final List<QuestionPart>? children;

  QuestionPart({
    required this.type,
    this.content,
    this.imageUrl,
    this.width,
    this.height,
    this.diagramId,
    this.id,
    this.children,
  });

  factory QuestionPart.fromJson(Map<String, dynamic> json) {
    QuestionPartType type = QuestionPartType.values.firstWhere(
        (e) => e.name == json['type'], orElse: () => QuestionPartType.text);

    String? content = json['content'];

    // Auto-detect SVG if labeled as text but contains SVG XML
    if (type == QuestionPartType.text && content != null && content.trim().startsWith('<svg')) {
      type = QuestionPartType.svg;
    }

    return QuestionPart(
      type: type,
      content: content,
      imageUrl: json['imageUrl'] ?? json['url'],
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      diagramId: json['diagramId'],
      id: json['id'],
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => QuestionPart.fromJson(e))
          .toList(),
    );
  }
}

// New Model for Drag & Drop
class DragDropGroup {
  final String id;
  final String label;
  final String? imageUrl;

  DragDropGroup({required this.id, required this.label, this.imageUrl});

  factory DragDropGroup.fromJson(Map<String, dynamic> json) => DragDropGroup(
    id: json['id']?.toString() ?? '',
    label: json['label'] ?? '',
    imageUrl: json['imageUrl'] ?? json['image'],
  );
}

class DragDropItem {
  final String id;
  final String content; // Text or ImageURL
  final String type; // 'text' or 'image'
  final String targetGroupId; // Correct Answer

  DragDropItem({required this.id, required this.content, required this.type, required this.targetGroupId});

  factory DragDropItem.fromJson(Map<String, dynamic> json) {
    String content = json['content'] ?? '';
    // Infer type if missing: check for http/https or file extensions
    String type = json['type'] ?? (
      (content.toLowerCase().endsWith('.svg')) 
      ? 'svg'
      : (content.startsWith('http') || content.endsWith('.png') || content.endsWith('.jpg'))
      ? 'image'
      : 'text'
    );
    
    // Hot-fix for potential mislabeled data where type is 'text' but content is a URL
    final lowerContent = content.toLowerCase();
    if (content.trim().startsWith('<svg') || lowerContent.endsWith('.svg') || lowerContent.contains('.svg?')) {
      type = 'svg';
    } else if (content.startsWith('http') && 
               (lowerContent.contains('.png') || lowerContent.contains('.jpg') || lowerContent.contains('.jpeg') || lowerContent.contains('.webp') || lowerContent.contains('.gif'))) {
       // Relaxed check: if it starts with http and contains an image extension anywhere (to handle query params) -> treat as image
      type = 'image';
    }


    return DragDropItem(
      id: json['id']?.toString() ?? '',
      content: content,
      type: type,
      targetGroupId: json['target_group_id']?.toString() ?? '',
    );
  }
}

class RichOption {
  final String? text;
  final String? imageUrl;
  final String? id;

  RichOption({this.text, this.imageUrl, this.id});

  factory RichOption.fromDynamic(dynamic data) {
    if (data is String) {
      if (data.trim().startsWith('<svg') || data.toLowerCase().startsWith('http') || data.toLowerCase().endsWith('.png') || data.toLowerCase().endsWith('.jpg') || data.toLowerCase().endsWith('.svg')) {
        return RichOption(imageUrl: data, text: null);
      }
      return RichOption(text: data, imageUrl: null);
    }
    if (data is Map<String, dynamic>) {
      return RichOption(
        text: data['text'] ?? data['content'],
        imageUrl: data['imageUrl'] ?? data['url'],
        id: data['id'],
      );
    }
    return RichOption(text: data.toString());
  }
}


enum Difficulty { easy, medium, hard }

class QuestionModel {
  final String id;
  final QuestionType type; 
  final List<QuestionPart> parts;
  final List<String> options;
  final List<RichOption> richOptions;
  final int correctAnswerIndex; 
  final String? correctAnswerText; 
  final String solution;
  // Parsed solution parts for rich text
  final List<QuestionPart> solutionParts;
  final String category;
  final String? subCategory;
  final Difficulty difficulty;
  final List<String> tags;
  final int marks;
  final String layout;
  final bool isVertical;
  final bool showSubmitButton;
  
  // MCQ Multi-Select
  final List<int>? correctAnswerIndices;
  final bool isMultiSelect;
  
  // Adaptive Learning Fields
  final String? subTopic;
  final int? complexity; // 0-100
  
  // D&D Fields
  final List<DragDropGroup> groups;
  final List<DragDropItem> dragItems;
  
  // Adaptive Learning Config (Misconceptions, Remediation, Tags)
  final Map<String, dynamic>? adaptiveConfig;

  QuestionModel({
    required this.id,
    required this.type,
    required this.parts,
    this.options = const [],
    this.richOptions = const [],
    this.correctAnswerIndex = -1,
    this.correctAnswerIndices,
    this.isMultiSelect = false,
    this.correctAnswerText,
    required this.solution,
    this.solutionParts = const [],
    required this.category,
    this.subCategory,
    this.difficulty = Difficulty.medium,
    this.tags = const [],
    this.marks = 1,
    this.layout = "list",
    this.isVertical = false,
    this.showSubmitButton = false,
    this.subTopic,
    this.complexity,
    this.groups = const [],
    this.dragItems = const [],
    this.adaptiveConfig,
  });
  
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    String rawSolution = json['solution'] ?? '';
    List<QuestionPart> solParts = [];
    
    // Try to parse solution as JSON array
    try {
      if (rawSolution.trim().startsWith('[')) {
        final decoded = jsonDecode(rawSolution);
        if (decoded is List) {
          solParts = decoded.map((e) => QuestionPart.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Fallback: treat as plain text
      // print("Error parsing solution JSON: $e");
    }

    // If parsing failed or was just text, ensure we have at least one part if text exists
    if (solParts.isEmpty && rawSolution.isNotEmpty) {
      solParts = [QuestionPart(type: QuestionPartType.text, content: rawSolution)];
    }


    List<String> simpleOptions = [];
    List<RichOption> parsedRichOptions = [];

    if (json['options'] != null) {
      var opts = json['options'];
      if (opts is List) {
        for (var o in opts) {
          // Populate simple text list for backward compat (best effort)
          if (o is String) {
            simpleOptions.add(o);
          } else if (o is Map) {
             simpleOptions.add(o['text'] ?? o['imageUrl'] ?? '');
          }
          // Populate rich options
          parsedRichOptions.add(RichOption.fromDynamic(o));
        }
      }
    }

    return QuestionModel(
      id: json['id']?.toString() ?? '',
      type: QuestionType.values.firstWhere(
          (e) => e.name == json['type'], orElse: () => QuestionType.mcq),
      
      parts: (json['parts'] as List<dynamic>?)
          ?.map((e) => QuestionPart.fromJson(e))
          .toList() ?? [],
          
      options: simpleOptions,
      richOptions: parsedRichOptions,
      
      correctAnswerIndex: json['correct_answer_index'] ?? -1,
      correctAnswerIndices: (json['correct_answer_indices'] as List<dynamic>?)?.map((e) => e as int).toList(),
      isMultiSelect: json['is_multi_select'] ?? false,
      correctAnswerText: json['correct_answer_text'], 
      solution: rawSolution,
      solutionParts: solParts,
      category: json['category'] ?? 'General',
      subCategory: json['sub_category'],
      
      difficulty: _parseDifficulty(json['difficulty']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      marks: json['marks'] ?? 1,
      layout: json['layout'] ?? "list",
      subTopic: json['sub_topic'],
      complexity: json['complexity'],
      isVertical: json['is_vertical'] ?? false,
      showSubmitButton: json['show_submit_button'] ?? false,
      
      // Parse D&D from extra JSONB columns or generic 'meta'
      // We'll assume columns 'drag_groups' and 'drag_items' exist
      groups: (json['drag_groups'] as List<dynamic>?)
          ?.map((e) => DragDropGroup.fromJson(e))
          .toList() ?? [],
      dragItems: (json['drag_items'] as List<dynamic>?)
          ?.map((e) => DragDropItem.fromJson(e))
          .toList() ?? [],
          
      // Adaptive Metadata Config
      adaptiveConfig: json['adaptive_config'] as Map<String, dynamic>?,
    );
  }
  
  static Difficulty _parseDifficulty(String? level) {
    switch (level?.toLowerCase()) {
      case 'easy': return Difficulty.easy;
      case 'hard': return Difficulty.hard;
      default: return Difficulty.medium;
    }
  }
}
