
"use client";

import { useEffect, useState, use } from "react";
import { Question, QuestionType } from "@/lib/types/question";
import { QuestionRenderer } from "@/components/practice/QuestionRenderer";
import { Scoreboard } from "@/components/practice/Scoreboard";
import { Button } from "@/components/ui/button";
import { ArrowRight, CheckCircle2, XCircle, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";
import confetti from "canvas-confetti";
import { useWindowSize } from "react-use";
import { getQuestionsBySkillId } from "@/lib/supabase/fetchers";

// Fallback Mock Questions Data incase API fails or for demo
const fallbackQuestions: Question[] = [
    {
        id: "q1",
        type: QuestionType.MCQ,
        difficulty: "easy",
        parts: [
            { type: "text", content: "Which number sentence is true?" },
            { type: "text", content: "80 ____ 83" },
        ],
        options: [
            { id: "opt1", text: "is greater than" },
            { id: "opt2", text: "is less than" },
            { id: "opt3", text: "is equal to" },
        ],
        correctAnswerIndex: 1, // "is less than"
        solution: "80 comes before 83 on the number line, so 80 is less than 83.",
    },
    {
        id: "q2", // Drag and Drop
        type: QuestionType.DragAndDrop,
        difficulty: "medium",
        parts: [
            { type: "text", content: "Drag each item to the correct group." },
        ],
        options: [], // Not used for DnD
        correctAnswerIndex: -1,
        solution: "Living things grow and breathe. Non-living things do not.",
        dragGroups: [
            { id: "living", label: "Living Things" },
            { id: "non-living", label: "Non-Living Things" }
        ],
        dragItems: [
            { id: "cat", content: "Cat", type: "text", targetGroupId: "living" },
            { id: "rock", content: "Rock", type: "text", targetGroupId: "non-living" },
            { id: "tree", content: "Tree", type: "text", targetGroupId: "living" },
            { id: "car", content: "Car", type: "text", targetGroupId: "non-living" }
        ]
    },
    {
        id: "q3",
        type: QuestionType.MCQ,
        difficulty: "easy",
        parts: [
            { type: "text", content: "Which number is even?" },
        ],
        options: [
            { id: "opt1", text: "5" },
            { id: "opt2", text: "3" },
            { id: "opt3", text: "8" },
            { id: "opt4", text: "9" },
        ],
        correctAnswerIndex: 2, // "8"
        solution: "Even numbers end in 0, 2, 4, 6, or 8. 8 is an even number.",
    },
];

export default function PracticeSessionPage({ params }: { params: Promise<{ skillId: string }> }) {
    const { skillId } = use(params);

    // State for questions (dynamic)
    const [questions, setQuestions] = useState<Question[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    // Practice Engine State
    const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
    const [selectedOptionId, setSelectedOptionId] = useState<any>(undefined); // Can be string or object
    const [isSubmitted, setIsSubmitted] = useState(false);
    const [isCorrect, setIsCorrect] = useState(false);
    const [smartScore, setSmartScore] = useState(0);
    const [questionsAnswered, setQuestionsAnswered] = useState(0);
    const [startTime] = useState(Date.now());
    const [elapsedTime, setElapsedTime] = useState("00:00");

    // Real Data Fetching
    useEffect(() => {
        async function loadQuestions() {
            setIsLoading(true);
            try {
                const data = await getQuestionsBySkillId(skillId);
                if (data && data.length > 0) {
                    setQuestions(data);
                } else {
                    // If fetching returns empty, maybe fallback to a "No questions found" state
                    // kept previous fallback logic for robustness if needed, but trying to use real data now
                }
            } catch (error) {
                // console.error("Error fetching questions:", error);
            } finally {
                setIsLoading(false);
            }
        }

        if (skillId) loadQuestions();
    }, [skillId]);

    // Confetti logic
    useEffect(() => {
        if (isSubmitted && isCorrect) {
            confetti({
                particleCount: 100,
                spread: 70,
                origin: { y: 0.6 }
            });
        }
    }, [isSubmitted, isCorrect]);

    // Timer logic
    useEffect(() => {
        const interval = setInterval(() => {
            const now = Date.now();
            const totalSeconds = Math.floor((now - startTime) / 1000);
            const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
            const seconds = (totalSeconds % 60).toString().padStart(2, '0');
            setElapsedTime(`${minutes}:${seconds}`);
        }, 1000);
        return () => clearInterval(interval);
    }, [startTime]);

    const handleSubmit = () => {
        if (!selectedOptionId) return;

        const currentQuestion = questions[currentQuestionIndex];
        let correct = false;

        if (currentQuestion.type === QuestionType.MCQ) {
            const correctOptionId = currentQuestion.options[currentQuestion.correctAnswerIndex].id;
            correct = selectedOptionId === correctOptionId;
        } else if (currentQuestion.type === QuestionType.DragAndDrop) {
            // Validate DnD
            const answerMap = selectedOptionId as Record<string, string>;
            // Check if every item is in the correct group
            const allItemsCorrect = currentQuestion.dragItems?.every(item => {
                return answerMap[item.id] === item.targetGroupId;
            });
            correct = !!allItemsCorrect;
        }

        setIsCorrect(correct);
        setIsSubmitted(true);
        setQuestionsAnswered(prev => prev + 1);

        if (correct) {
            setSmartScore(prev => Math.min(100, prev + 10));
        } else {
            setSmartScore(prev => Math.max(0, prev - 5));
        }
    };

    const handleNext = () => {
        if (currentQuestionIndex < questions.length - 1) {
            setCurrentQuestionIndex(prev => prev + 1);
            setSelectedOptionId(undefined);
            setIsSubmitted(false);
            setIsCorrect(false);
        } else {
            // End of session logic
            alert("Practice Complete! You scored " + smartScore);
        }
    };

    if (isLoading) {
        return (
            <div className="flex h-screen w-full items-center justify-center flex-col gap-4 bg-slate-50">
                <Loader2 className="h-12 w-12 animate-spin text-green-600" />
                <p className="text-slate-500 font-medium text-lg">Loading practice session...</p>
            </div>
        );
    }

    const currentQuestion = questions[currentQuestionIndex];

    return (
        <div className="container mx-auto max-w-6xl py-8 px-4 flex flex-col lg:flex-row gap-8 items-start h-full">
            {/* Main Practice Area */}
            <div className="flex-1 w-full space-y-6">
                <div className="flex items-center justify-between">
                    <h2 className="text-xl font-bold text-slate-700 truncate">
                        Practicing: {skillId}
                    </h2>
                </div>

                <div className="relative">
                    <QuestionRenderer
                        question={currentQuestion}
                        selectedOptionId={selectedOptionId}
                        onSelectOption={setSelectedOptionId}
                        isSubmitted={isSubmitted}
                    />

                    {/* Feedback Overlay / Footer */}
                    {isSubmitted && (
                        <div className={cn(
                            "mt-6 p-6 rounded-lg border-2 flex flex-col md:flex-row items-center justify-between gap-4 animate-in fade-in slide-in-from-bottom-2 duration-300 shadow-xl",
                            isCorrect ? "bg-green-50 border-green-200" : "bg-red-50 border-red-200"
                        )}>
                            <div className="flex items-center gap-4">
                                {isCorrect ? (
                                    <CheckCircle2 className="h-10 w-10 text-green-600" />
                                ) : (
                                    <XCircle className="h-10 w-10 text-red-600" />
                                )}
                                <div>
                                    <h3 className={cn("text-xl font-bold", isCorrect ? "text-green-800" : "text-red-800")}>
                                        {isCorrect ? "Excellent!" : "Sorry, incorrect..."}
                                    </h3>
                                    {!isCorrect && (
                                        <p className="text-slate-600 mt-1 max-w-lg">
                                            <strong>Explanation:</strong> {currentQuestion.solution}
                                        </p>
                                    )}
                                    {isCorrect && (
                                        <p className="text-green-700 font-medium italic">
                                            Keep up the great work!
                                        </p>
                                    )}
                                </div>
                            </div>
                            <Button onClick={handleNext} size="lg" className={cn("px-8 font-bold text-lg min-w-[150px]", isCorrect ? "bg-green-600 hover:bg-green-700" : "bg-slate-800 hover:bg-slate-900")}>
                                {currentQuestionIndex < questions.length - 1 ? "Next Question" : "Finish"}
                                <ArrowRight className="ml-2 h-5 w-5" />
                            </Button>
                        </div>
                    )}

                    {/* Submit Button (Only show if not submitted) */}
                    {!isSubmitted && (
                        <div className="mt-6 flex justify-end">
                            <Button
                                onClick={handleSubmit}
                                disabled={!selectedOptionId}
                                size="lg"
                                className="bg-green-600 hover:bg-green-700 text-white font-bold text-lg px-12 py-6 rounded-full shadow-lg hover:shadow-green-200 hover:-translate-y-1 transition-all disabled:opacity-50 disabled:shadow-none disabled:translate-y-0"
                            >
                                Submit
                            </Button>
                        </div>
                    )}
                </div>
            </div>

            {/* Sidebar Stats */}
            <div className="w-full lg:w-auto">
                <Scoreboard
                    questionsAnswered={questionsAnswered}
                    timeElapsed={elapsedTime}
                    smartScore={smartScore}
                />
            </div>
        </div>
    );
}
