
import { Option, Question } from "@/lib/types/question";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { motion } from "framer-motion";
import { Check, X } from "lucide-react";

interface MCQQuestionProps {
    question: Question;
    selectedOptionId?: string;
    onSelectOption: (optionId: string) => void;
    isSubmitted: boolean;
}

export function MCQQuestion({
    question,
    selectedOptionId,
    onSelectOption,
    isSubmitted,
}: MCQQuestionProps) {
    return (
        <div className="grid gap-4 sm:grid-cols-2">
            {question.options.map((option, index) => {
                const isSelected = selectedOptionId === option.id;
                // Determine if this option is the correct one used for displaying feedback
                const isCorrect = index === question.correctAnswerIndex;

                let variant = "outline";
                let className = "h-auto py-6 px-4 justify-start text-left hover:bg-slate-50 border-2";

                if (isSubmitted) {
                    if (isCorrect) {
                        className += " border-green-500 bg-green-50 text-green-900";
                    } else if (isSelected && !isCorrect) {
                        className += " border-red-500 bg-red-50 text-red-900";
                    } else {
                        className += " border-slate-200 opacity-50";
                    }
                } else {
                    if (isSelected) {
                        className += " border-blue-500 bg-blue-50 ring-1 ring-blue-500";
                    } else {
                        className += " border-slate-200";
                    }
                }

                return (
                    <motion.div
                        key={option.id}
                        whileHover={!isSubmitted ? { scale: 1.02 } : {}}
                        whileTap={!isSubmitted ? { scale: 0.98 } : {}}
                    >
                        <Button
                            variant={"ghost"}
                            className={cn("w-full relative", className)}
                            onClick={() => !isSubmitted && onSelectOption(option.id!)}
                            disabled={isSubmitted}
                        >
                            <div className="flex items-center gap-3 w-full">
                                <div className={cn(
                                    "flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center border text-sm font-bold transition-colors",
                                    isSelected ? "bg-blue-500 text-white border-blue-500" : "bg-white text-slate-500 border-slate-300",
                                    isSubmitted && isCorrect && "bg-green-500 text-white border-green-500",
                                    isSubmitted && isSelected && !isCorrect && "bg-red-500 text-white border-red-500",
                                )}>
                                    {String.fromCharCode(65 + index)}
                                </div>

                                <span className="flex-1 text-base font-medium">
                                    {option.text}
                                    {/* Handle image options if present */}
                                    {option.imageUrl && (
                                        <img src={option.imageUrl} alt={`Option ${index + 1}`} className="mt-2 rounded-md max-h-32 object-contain" />
                                    )}
                                </span>

                                {isSubmitted && isCorrect && (
                                    <Check className="h-5 w-5 text-green-600" />
                                )}
                                {isSubmitted && isSelected && !isCorrect && (
                                    <X className="h-5 w-5 text-red-600" />
                                )}
                            </div>
                        </Button>
                    </motion.div>
                );
            })}
        </div>
    );
}
