
export enum QuestionType {
  MCQ = 'mcq',
  TextInput = 'textInput',
  Sorting = 'sorting',
  DragAndDrop = 'dragAndDrop',
  FillInTheBlank = 'fillInTheBlank',
  FourPicsOneWord = 'fourPicsOneWord',
  ImageChoice = 'imageChoice',
}

export interface QuestionPart {
  type: 'text' | 'math' | 'image' | 'diagram' | 'input' | 'svg';
  content?: string;
  imageUrl?: string;
  width?: number;
  height?: number;
  children?: QuestionPart[];
}

export interface Option {
  text?: string;
  imageUrl?: string;
  id?: string;
  isCorrect?: boolean; // Sometimes useful for frontend state locally in some designs
}

export interface DragDropGroup {
  id: string;
  label: string;
  imageUrl?: string;
}

export interface DragDropItem {
  id: string;
  content: string;
  type: 'text' | 'image' | 'svg';
  targetGroupId: string;
}

export interface Question {
  id: string;
  type: QuestionType;
  parts: QuestionPart[];
  options: Option[];
  correctAnswerIndex: number;
  correctAnswerIndices?: number[]; // For multi-select
  correctAnswerText?: string;
  solution: string; // Explanation
  difficulty: 'easy' | 'medium' | 'hard';
  dragGroups?: DragDropGroup[];
  dragItems?: DragDropItem[];
}
