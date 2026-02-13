
"use client";

import React, { useState, useEffect } from "react";
import {
    DndContext,
    DragOverlay,
    useDraggable,
    useDroppable,
    DragEndEvent,
    DragStartEvent,
} from "@dnd-kit/core";
import { Question, DragDropItem, DragDropGroup } from "@/lib/types/question";
import { cn } from "@/lib/utils";
import { createPortal } from "react-dom";

interface DragDropQuestionProps {
    question: Question;
    isSubmitted: boolean;
    onAnswerChange?: (items: DragDropItem[]) => void;
}

function DraggableItem({ item, isOverlay = false }: { item: DragDropItem; isOverlay?: boolean }) {
    const { attributes, listeners, setNodeRef, isDragging } = useDraggable({
        id: item.id,
        data: { item },
        disabled: false, // Could disable if isSubmitted, but let's allow movement for fun or disable it
    });

    return (
        <div
            ref={setNodeRef}
            {...listeners}
            {...attributes}
            className={cn(
                "cursor-grab active:cursor-grabbing p-3 bg-white rounded-md shadow-sm border border-slate-200 text-sm font-medium touch-none select-none transition-transform hover:scale-105 hover:shadow-md",
                isDragging && "opacity-50",
                isOverlay && "scale-105 shadow-xl cursor-grabbing z-50 ring-2 ring-green-500",
                item.type === 'image' && "p-1"
            )}
        >
            {item.type === 'image' ? (
                <img src={item.content} alt="drag item" className="w-16 h-16 object-contain pointer-events-none" />
            ) : (
                item.content
            )}
        </div>
    );
}

function DroppableZone({
    group,
    items,
    isSubmitted,
    question
}: {
    group: DragDropGroup;
    items: DragDropItem[];
    isSubmitted: boolean;
    question: Question;
}) {
    const { setNodeRef, isOver } = useDroppable({
        id: group.id,
    });

    return (
        <div
            ref={setNodeRef}
            className={cn(
                "flex-1 min-h-[150px] bg-slate-50 rounded-lg border-2 border-dashed border-slate-300 p-4 transition-colors flex flex-col gap-2 relative",
                isOver && "bg-blue-50 border-blue-400",
                isSubmitted && "border-solid" // visual cue
            )}
        >
            <div className="text-center font-bold text-slate-700 mb-2">{group.label}</div>
            {group.imageUrl && (
                <div className="flex justify-center mb-2">
                    <img src={group.imageUrl} alt={group.label} className="h-16 object-contain opacity-50" />
                </div>
            )}

            <div className="flex flex-wrap gap-2 justify-center content-start flex-1 z-10">
                {items.map((item) => (
                    <div key={item.id} className="relative">
                        <DraggableItem item={item} />
                        {isSubmitted && (
                            <div className={cn(
                                "absolute -top-2 -right-2 w-5 h-5 rounded-full flex items-center justify-center text-xs font-bold ring-2 ring-white",
                                item.targetGroupId === group.id ? "bg-green-500 text-white" : "bg-red-500 text-white"
                            )}>
                                {item.targetGroupId === group.id ? "✓" : "✕"}
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
}

export function DragDropQuestion({
    question,
    isSubmitted,
    onAnswerChange,
}: DragDropQuestionProps) {
    // Initialize items in a "pool" (group "source") or distributed if desired.
    // Ideally, items start in a source container.
    // We need to track where each item is.
    const [items, setItems] = useState<DragDropItem[]>(question.dragItems || []);
    const [itemLocations, setItemLocations] = useState<Record<string, string>>(() => {
        // Map item ID to 'source' initially
        const locs: Record<string, string> = {};
        question.dragItems?.forEach(item => {
            locs[item.id] = 'source';
        });
        return locs;
    });

    const [activeId, setActiveId] = useState<string | null>(null);

    const handleDragStart = (event: DragStartEvent) => {
        if (isSubmitted) return; // Freeze if submitted
        setActiveId(event.active.id as string);
    };

    const handleDragEnd = (event: DragEndEvent) => {
        const { active, over } = event;
        setActiveId(null);

        if (active && over) {
            const itemId = active.id as string;
            const targetId = over.id as string;

            // Update location
            const newLocations = { ...itemLocations, [itemId]: targetId };
            setItemLocations(newLocations);

            // Notify parent of "answer" state if needed for validation logic external to component
            // In this specific component logic, we can also check correctness visually in the renderer
            // But for the Page controller to know if it's correct, we might need to bubble up.
            // For now, let's assume validation happens by checking `item.targetGroupId` vs `location`
            // But the Page component 'handleSubmit' validates.
            // So we need to pass the CURRENT STATE back to the parent.

            // Construct "current answer" to pass back
            // effectively mapping items to their current group
            // This part depends on how the parent expects data. 
            // Let's implement a callback.
            if (onAnswerChange) {
                // Create a copy of items with updated locations (conceptually)
                // Actually the parent just needs to know if "item X is in correct group Y"
                // but that logic is often inside the question component or parent.
                // Let's pass the map `itemLocations`.
                // For the mock parent `handleSubmit`, we need to check if ALL items are in `item.targetGroupId`.
                // We can do this by exposing a check function or passing state up.
                // Let's pass the simplified `itemLocations` up via `onAnswerChange` is tricky if types don't match.
                // Let's just update local state and let the user see visual feedback when `isSubmitted` becomes true
            }
        }
    };

    // Helper to get items in a specific group
    const getItemsInGroup = (groupId: string) => {
        return items.filter(item => itemLocations[item.id] === groupId);
    };

    // Check if correct (exposed to parent via ref or callback? simpler to self-validate visual here)
    // The parent needs to know "isCorrect" for the score. 
    // We can use a useEffect to report validity?
    useEffect(() => {
        if (onAnswerChange) {
            // Fake passing "items" but actually we might want to pass correctness status or the map
            // Let's pass the map disguised or appended to items
            // For simplicity, let's stick to the current UI: this component handles the drag logic.
            // The parent `handleSubmit` in `page.tsx` is generic MCQ currently.
            // We need to upgrade `page.tsx` to handle generic answers.

            // Let's assume onAnswerChange accepts valid/invalid boolean or the answers
            // For now, we'll implement self-contained visual feedback. 
            // Parent `handleSubmit` needs to check correctness. 
            // Strategy: Parent uses `ref` or Context? 
            // Simpler Strategy: Pass a `onCheckAnswer` callback that returns boolean?
            // No, React data flow: Parent passes `selectedOption` for MCQ. 
            // For DnD, Parent should maintain `u_state`? 
            // To make it easy: We'll lift state up or use a comprehensive 'answer' object in parent.
            // For this demo, let's keep state local and use `onAnswerChange` to signal the parent "Ready to submit" + "Current Answer State".

            const isAllCorrect = items.every(item => itemLocations[item.id] === item.targetGroupId);
            // Dirty hack: emit "correct" string as ID if all correct, else "wrong"
            // This is just for the mock parent to register "something selected" and "is it right"
            // In a real app, use a proper answer object { [itemId]: groupId }
            const currentMap = { ...itemLocations };
            // We'll pass this map to a custom checking function if we could.
            // Let's send a custom event or callback. 
            // We will add `onAnswerChange` prop to `QuestionRenderer` too.

            // Mocking the parent callback requirements:
            // Parent expects `setSelectedOptionId`. 
            // We can repurpose that as `setAnswerState(any)`.

            // Actually, let's just emit the `itemLocations` object.
            // The parent expects string. We can JSON.stringify it?
            onAnswerChange(currentMap as any);
        }
    }, [itemLocations]); // items is constant for a question usually

    return (
        <DndContext onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
            <div className="flex flex-col gap-8">
                {/* Drop Zones */}
                <div className="flex flex-col md:flex-row gap-4">
                    {question.dragGroups?.map(group => (
                        <DroppableZone
                            key={group.id}
                            group={group}
                            items={getItemsInGroup(group.id)}
                            isSubmitted={isSubmitted}
                            question={question}
                        />
                    ))}
                </div>

                {/* Source Zone (Pool) */}
                <div className="bg-slate-100 p-4 rounded-xl border border-slate-200">
                    <span className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 block">Drag items from here</span>
                    <DroppableZone
                        group={{ id: 'source', label: '' }}
                        items={getItemsInGroup('source')}
                        isSubmitted={isSubmitted}
                        question={question}
                    />
                </div>
            </div>

            {createPortal(
                <DragOverlay>
                    {activeId ? (
                        <DraggableItem item={items.find(i => i.id === activeId)!} isOverlay />
                    ) : null}
                </DragOverlay>,
                document.body
            )}
        </DndContext>
    );
}
