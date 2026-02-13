
"use client";

import { Question, QuestionType } from "@/lib/types/question";
import { MCQQuestion } from "@/components/practice/MCQQuestion";
import { DragDropQuestion } from "@/components/practice/DragDropQuestion";
import { MathText } from "@/components/practice/MathText";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Lightbulb, Volume2 } from "lucide-react";
import { Button } from "@/components/ui/button";

interface QuestionRendererProps {
    question: Question;
    selectedOptionId?: any; // Changed to any to support complex answer types (string | object)
    onSelectOption: (answer: any) => void;
    isSubmitted: boolean;
}

export function QuestionRenderer({
    question,
    selectedOptionId,
    onSelectOption,
    isSubmitted,
}: QuestionRendererProps) {
    return (
        <Card className="border-0 shadow-lg bg-white overflow-hidden">
            {/* Question Header / Type Badge could go here */}
            <div className="bg-gradient-to-r from-blue-50 to-white px-6 py-3 border-b border-blue-100 flex items-center justify-between">
                <Badge variant="outline" className="bg-white text-blue-600 border-blue-200 uppercase tracking-widest text-[10px] font-bold">
                    {question.difficulty}
                </Badge>
                <div className="flex gap-2">
                    <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400 hover:text-blue-500">
                        <Volume2 className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="sm" className="h-8 text-slate-500 hover:text-yellow-600 gap-1 text-xs">
                        <Lightbulb className="h-4 w-4" />
                        Learn with an example
                    </Button>
                </div>
            </div>

            <CardContent className="p-6 md:p-10 space-y-8">
                {/* Question Parts Renderer */}
                <div className="space-y-4 text-lg md:text-xl font-medium text-slate-800 leading-relaxed">
                    {question.parts.map((part, index) => {
                        if (part.type === 'text') {
                            return <p key={index}>{part.content}</p>
                        }
                        if (part.type === 'image') {
                            return (
                                <div key={index} className="flex justify-center my-4">
                                    <img
                                        src={part.imageUrl}
                                        alt="Question illustration"
                                        className="max-w-full h-auto rounded-lg shadow-sm border border-slate-100"
                                        style={{ maxWidth: part.width, maxHeight: part.height }}
                                    />
                                </div>
                            )
                        }
                        if (part.type === 'math') {
                            // Latex rendering
                            return <MathText key={index} content={part.content || ''} />
                        }
                        return null;
                    })}
                </div>

                {/* Specific Question Type Renderers */}
                <div className="pt-4">
                    {question.type === QuestionType.MCQ && (
                        <MCQQuestion
                            question={question}
                            selectedOptionId={selectedOptionId as string}
                            onSelectOption={onSelectOption}
                            isSubmitted={isSubmitted}
                        />
                    )}

                    {question.type === QuestionType.DragAndDrop && (
                        <div className="h-full w-full">
                            <DragDropQuestion
                                question={question}
                                isSubmitted={isSubmitted}
                                onAnswerChange={onSelectOption}
                            />
                        </div>
                    )}

                    {question.type !== QuestionType.MCQ && question.type !== QuestionType.DragAndDrop && (
                        <div className="p-8 text-center text-slate-400 bg-slate-50 rounded-lg border border-dashed border-slate-300">
                            This question type ({question.type}) is not yet implemented.
                        </div>
                    )}
                </div>
            </CardContent>
        </Card>
    );
}
