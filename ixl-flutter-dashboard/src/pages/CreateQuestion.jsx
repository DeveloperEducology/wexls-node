
import React, { useState } from 'react';
import { useForm, useFieldArray, Controller, useWatch } from 'react-hook-form';
import { ArrowLeft, Save, Plus, X, Image as ImageIcon, GripVertical, AlertCircle } from 'lucide-react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { cn } from '../lib/utils';
import { supabase } from '../lib/supabaseClient';

export function CreateQuestion() {
    const { id } = useParams();
    const navigate = useNavigate();
    const [activeTab, setActiveTab] = useState('edit'); // For mobile toggle
    const { register, control, handleSubmit, watch, setValue, reset } = useForm({
        defaultValues: {
            type: 'mcq',
            difficulty: 'Medium',
            skill_id: '',
            question_text: '',

            solution_text: '',
            marks: 1,
            // Generic Parts (Question Stem)
            parts: [{ type: 'text', content: '' }],
            // MCQ & Image Choice
            options: [{ text: '', isCorrect: false }],
            // Fill In The Blank
            fib_parts: [{ type: 'text', content: '' }],
            // Drag & Drop
            drag_groups: [{ id: 'g1', label: '', image: '' }],
            drag_items: [{ id: 'i1', text: '', group_id: 'g1' }],
            // Sorting
            sort_items: [{ text: '' }],
            // 4 Pics
            images: ['', '', '', ''],
            jumbled_letters: '',
            is_multi_select: false,
            is_vertical: true
        }
    });

    const questionType = watch('type');
    const watchedValues = watch();

    // Fetch Question for Edit Mode
    React.useEffect(() => {
        if (!id) return;

        console.log("Fetching question with ID:", id);

        const fetchQuestion = async () => {
            const { data, error } = await supabase.from('questions').select('*').eq('id', id).single();
            if (error) {
                console.error("Error fetching question:", error);
                return;
            }

            console.log("Fetched Data:", data);

            // Helper to flatten parts
            // Helper to flat-map parts recursive, handling 'sequence' and 'input'
            const parseParts = (partsRaw, isFib = false, fibAnswers = {}) => {
                let parts = typeof partsRaw === 'string' ? JSON.parse(partsRaw) : (partsRaw || []);
                const flattened = [];
                const traverse = (p) => {
                    if (Array.isArray(p)) {
                        p.forEach(traverse);
                    } else if (p.type === 'sequence' && p.children) {
                        p.children.forEach(traverse);
                    } else if (p.type === 'text' || p.type === 'image') {
                        flattened.push({
                            type: p.type,
                            content: p.type === 'image' ? (p.imageUrl || p.content) : p.content
                        });
                    } else if (isFib && p.type === 'input') {
                        // Resolve FIB answer
                        let val = fibAnswers[p.id] || '';
                        flattened.push({ type: 'input', content: val });
                    }
                };
                traverse(parts);
                return flattened.length ? flattened : [{ type: 'text', content: '' }];
            };

            const parseSolution = (sol) => {
                if (!sol) return '';
                let val = sol;
                if (typeof val === 'string' && (val.startsWith('[') || val.startsWith('{'))) {
                    try {
                        val = JSON.parse(val);
                    } catch (e) {
                        return sol; // Return original string if parse fails
                    }
                }
                if (Array.isArray(val)) {
                    return val.map(p => p.content || '').join('\n\n');
                }
                return val;
            };

            // Prepare FIB Answers
            let fibAnswers = {};
            if (data.type === 'fillInTheBlank' && data.correct_answer_text) {
                try {
                    fibAnswers = typeof data.correct_answer_text === 'string' ? JSON.parse(data.correct_answer_text) : data.correct_answer_text;
                } catch (e) { }
            }

            // Transform JSONB back to Form State
            const formData = {
                type: data.type,
                difficulty: data.difficulty,
                // Map 'micro_skill_id' to form 'skill_id'
                skill_id: data.micro_skill_id || data.skill_id,

                // Load parts directly using helper
                parts: data.type !== 'fillInTheBlank' ? parseParts(data.parts) : [{ type: 'text', content: '' }],

                is_multi_select: data.is_multi_select || false,
                is_vertical: data.is_vertical !== undefined ? data.is_vertical : true,

                // Fallback for older simpler questions: pop first text part to question_text just in case 
                question_text: '',

                solution_text: parseSolution(data.solution),
                options: typeof data.options === 'string' ? JSON.parse(data.options).map((t, i) => ({
                    text: t,
                    isCorrect: (data.correct_answer_indices && data.correct_answer_indices.includes(i)) || (i === data.correct_answer_index)
                })) : (data.options ? data.options.map((t, i) => ({
                    text: t,
                    isCorrect: (data.correct_answer_indices && data.correct_answer_indices.includes(i)) || (i === data.correct_answer_index)
                })) : []),

                drag_groups: data.drag_groups || [],
                drag_items: data.drag_items ? data.drag_items.map(i => ({ id: i.id, text: i.content, group_id: i.target_group_id })) : [],
                sort_items: data.type === 'sorting' && data.options ? data.options.map(t => ({ text: t })) : [{ text: '' }],
                images: data.type === 'fourPicsOneWord' && data.parts ? data.parts.filter(p => p.type === 'image').map(p => p.imageUrl) : ['', '', '', ''],
                jumbled_letters: data.correct_answer_text || '',
                marks: data.marks || 1,
                // FIB - Use flattened parser
                fib_parts: data.type === 'fillInTheBlank' ? parseParts(data.parts, true, fibAnswers) : [{ type: 'text', content: '' }]

            };

            console.log("Resetting form with:", formData);
            reset(formData);

            // Pre-fill Dropdowns (Reverse Lookup)
            const skillId = data.micro_skill_id || data.skill_id;
            if (skillId) {
                try {
                    // Get Skill -> Unit
                    const { data: skill } = await supabase.from('micro_skills').select('unit_id').eq('id', skillId).single();
                    if (skill?.unit_id) {
                        const unitId = skill.unit_id;

                        // Get Unit -> Grade
                        const { data: unit } = await supabase.from('units').select('grade_id').eq('id', unitId).single();
                        if (unit?.grade_id) {
                            const gradeId = unit.grade_id;

                            // We have GradeID and UnitID. Now populate the dropdown lists.
                            const unitsData = await fetchUnits(gradeId);
                            const skillsData = await fetchMicroSkills(unitId);

                            setUnits(unitsData);
                            setMicroSkills(skillsData);

                            // Set Selected Values
                            setSelectedGrade(gradeId);
                            setSelectedUnit(unitId);
                        }
                    }
                } catch (err) {
                    console.error("Error pre-filling cascading dropdowns:", err);
                }
            }
        };
        fetchQuestion();
    }, [id, reset]);



    const onSubmit = async (data) => {
        try {
            let payload = {
                type: data.type,
                difficulty: data.difficulty.toLowerCase(),
                micro_skill_id: data.skill_id,
                solution: data.solution_text,
                marks: parseInt(data.marks) || 1,
                is_multi_select: data.is_multi_select,
                is_vertical: data.is_vertical,

                // Defaults
                parts: [],
                options: [],
                correct_answer_index: -1,
                correct_answer_text: null,
                drag_groups: [],
                drag_items: []
            };

            // Builder Logic
            // Builder Logic
            if (data.type === 'mcq') {
                payload.parts = data.parts.map(p => ({
                    type: p.type,
                    content: p.content,
                    ...(p.type === 'image' && { imageUrl: p.content })
                }));
                if (payload.parts.length === 0 && data.question_text) {
                    payload.parts = [{ type: 'text', content: data.question_text }];
                }

                payload.options = data.options.map(o => o.text);

                // Calculate correctness
                const correctIndices = data.options.map((o, i) => o.isCorrect ? i : -1).filter(i => i !== -1);
                payload.correct_answer_indices = correctIndices;
                // Fallback for legacy calls
                payload.correct_answer_index = correctIndices.length > 0 ? correctIndices[0] : -1;

            } else if (data.type === 'imageChoice') {
                payload.parts = data.parts.map(p => ({
                    type: p.type,
                    content: p.content,
                    ...(p.type === 'image' && { imageUrl: p.content })
                }));
                // Fallback / Validation
                if (payload.parts.length === 0) {
                    payload.parts = [{ type: 'text', content: data.question_text || "Select the correct image." }];
                }
                payload.options = data.options.map(o => o.text); // URLs

                // Calculate correctness
                const correctIndices = data.options.map((o, i) => o.isCorrect ? i : -1).filter(i => i !== -1);
                payload.correct_answer_indices = correctIndices;
                payload.correct_answer_index = correctIndices.length > 0 ? correctIndices[0] : -1;

            } else if (data.type === 'fillInTheBlank') {
                let answerMap = {};
                let inputCount = 0;

                payload.parts = data.fib_parts.map(p => {
                    if (p.type === 'input') {
                        inputCount++;
                        const pid = `answer_${inputCount}`;
                        answerMap[pid] = p.content;
                        return { id: pid, type: 'input' };
                    } else if (p.type === 'image') {
                        return { type: 'image', content: p.content, imageUrl: p.content };
                    } else {
                        return { type: 'text', content: p.content };
                    }
                });
                payload.correct_answer_text = JSON.stringify(answerMap);

            } else if (data.type === 'dragAndDrop') {
                payload.parts = data.parts.map(p => ({
                    type: p.type,
                    content: p.content,
                    ...(p.type === 'image' && { imageUrl: p.content })
                }));

                payload.drag_groups = data.drag_groups;
                payload.drag_items = data.drag_items.map(i => ({
                    id: i.id,
                    type: 'text',
                    content: i.text,
                    target_group_id: i.group_id
                }));

            } else if (data.type === 'sorting') {
                payload.parts = data.parts.map(p => ({
                    type: p.type,
                    content: p.content,
                    ...(p.type === 'image' && { imageUrl: p.content })
                }));
                payload.options = data.sort_items.map(i => i.text);

            } else if (data.type === 'fourPicsOneWord') {
                payload.parts = [
                    { type: 'text', content: data.question_text || "Guess the word!" },
                    ...data.images.map(url => ({ type: 'image', content: url, imageUrl: url }))
                ];
                payload.correct_answer_text = data.jumbled_letters;
            }

            console.log("Saving payload:", payload);

            let result;
            if (id) {
                result = await supabase.from('questions').update(payload).eq('id', id);
            } else {
                result = await supabase.from('questions').insert([payload]);
            }

            if (result.error) throw result.error;
            alert(`Question ${id ? 'updated' : 'saved'} successfully!`);
            if (!id) navigate('/');

        } catch (err) {
            console.error("Error saving question:", err);
            alert('Failed to save question: ' + err.message);
        }
    };

    // State for Cascading Dropdowns
    const [grades, setGrades] = useState([]);
    const [units, setUnits] = useState([]);
    const [microSkills, setMicroSkills] = useState([]);

    // Selection state for controlled inputs
    const [selectedGrade, setSelectedGrade] = useState('');
    const [selectedUnit, setSelectedUnit] = useState('');

    // Fetch Helpers
    const fetchUnits = async (gradeId) => {
        // First get subjects for this grade
        const { data: subjects } = await supabase.from('subjects').select('id').eq('grade_id', gradeId);
        let units = [];

        if (subjects && subjects.length > 0) {
            const subjectIds = subjects.map(s => s.id);
            const { data } = await supabase.from('units').select('*').in('subject_id', subjectIds);
            units = data || [];
        }

        // Convert to Set to merge if we also want check grade_id fallback, 
        // but for now let's just use the fallback if no units found via subject?
        if (units.length === 0) {
            const { data } = await supabase.from('units').select('*').eq('grade_id', gradeId);
            if (data) units = data;
        }
        return units;
    };
    const fetchMicroSkills = async (unitId) => {
        const { data } = await supabase.from('micro_skills').select('*').eq('unit_id', unitId);
        return data || [];
    };

    // Fetch Grades on load
    React.useEffect(() => {
        const fetchGrades = async () => {
            const { data } = await supabase.from('grades').select('*');
            if (data) setGrades(data);
        };
        fetchGrades();
    }, []);

    // Fetch Units when Grade changes
    const handleGradeChange = async (e) => {
        const gradeId = e.target.value;
        setSelectedGrade(gradeId);

        // Reset Dependents
        setSelectedUnit('');
        setValue('skill_id', '');
        setUnits([]);
        setMicroSkills([]);

        if (gradeId) {
            const data = await fetchUnits(gradeId);
            setUnits(data);
        }
    };

    // Fetch Micro Skills when Unit changes
    const handleUnitChange = async (e) => {
        const unitId = e.target.value;
        setSelectedUnit(unitId);

        // Reset Dependents
        setValue('skill_id', '');
        setMicroSkills([]);

        if (unitId) {
            const data = await fetchMicroSkills(unitId);
            setMicroSkills(data);
        }
    };

    return (
        <div className="h-[calc(100vh-4rem)] flex flex-col">
            {/* Header */}
            <header className="flex items-center justify-between px-6 py-4 bg-white border-b border-slate-200">
                <div className="flex items-center gap-4">
                    <Link to="/" className="p-2 hover:bg-slate-100 rounded-full text-slate-500 hover:text-slate-900 transition-colors">
                        <ArrowLeft className="w-5 h-5" />
                    </Link>
                    <h1 className="text-xl font-bold text-slate-900">Create New Question</h1>
                </div>
                <button
                    onClick={handleSubmit(onSubmit)}
                    className="bg-brand-600 hover:bg-brand-700 text-white px-6 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors shadow-sm"
                >
                    <Save className="w-4 h-4" />
                    Save Question
                </button>
            </header>

            <div className="flex-1 flex overflow-hidden">
                {/* Left: Form */}
                <div className="flex-1 overflow-y-auto p-6 bg-slate-50 border-r border-slate-200 max-w-2xl">
                    <div className="space-y-8">

                        {/* Common Fields */}
                        <div className="space-y-4 bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                            <h3 className="text-lg font-semibold text-slate-800 mb-4 border-b border-slate-100 pb-2">Basic Info</h3>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Question Type</label>
                                    <select {...register('type')} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-slate-700 focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
                                        <option value="mcq">Multiple Choice (MCQ)</option>
                                        <option value="fillInTheBlank">Fill In The Blank</option>
                                        <option value="dragAndDrop">Drag & Drop</option>
                                        <option value="sorting">Sorting</option>
                                        <option value="fourPicsOneWord">4 Pics 1 Word</option>
                                        <option value="imageChoice">Image Choice</option>
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Difficulty</label>
                                    <select {...register('difficulty')} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-slate-700 focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500">
                                        <option value="Easy">Easy</option>
                                        <option value="Medium">Medium</option>
                                        <option value="Hard">Hard</option>
                                    </select>
                                </div>
                            </div>

                            {/* ... Grade/Unit/Skill Selects (unchanged) ... */}
                            <div className="grid grid-cols-3 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Grade</label>
                                    <select value={selectedGrade} onChange={handleGradeChange} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-slate-700 text-sm">
                                        <option value="">Select Grade</option>
                                        {grades.map(g => <option key={g.id} value={g.id}>{g.name || g.level}</option>)}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Unit</label>
                                    <select value={selectedUnit} onChange={handleUnitChange} disabled={!units.length} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-slate-700 text-sm disabled:bg-slate-100 disabled:text-slate-400">
                                        <option value="">Select Unit</option>
                                        {units.map(u => <option key={u.id} value={u.id}>{u.name || u.description}</option>)}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Micro Skill</label>
                                    <select {...register('skill_id')} disabled={!microSkills.length} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-slate-700 text-sm disabled:bg-slate-100 disabled:text-slate-400">
                                        <option value="">Select Skill</option>
                                        {microSkills.map(ms => <option key={ms.id} value={ms.id}>{ms.name || ms.code}</option>)}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Question Content</label>
                                {/* Only show specialized QuestionStemBuilder for types that use payload.parts directly.
                                    FIB uses fib_parts. 4Pics uses specific grid.
                                */}
                                {['mcq', 'imageChoice', 'dragAndDrop', 'sorting'].includes(questionType) ? (
                                    <QuestionStemBuilder control={control} register={register} />
                                ) : (
                                    <textarea {...register('question_text')} rows={3} className="w-full border border-slate-300 rounded-lg px-3 py-2 text-slate-700 focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500" placeholder="Enter the main question text here..." />
                                )}
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Marks</label>
                                <input {...register('marks')} type="number" className="w-24 border border-slate-300 rounded-lg px-3 py-2 text-slate-700" defaultValue={1} />
                            </div>

                            <div className="flex items-center gap-6 pt-2">
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" {...register('is_multi_select')} className="w-4 h-4 text-brand-600 rounded border-slate-300 focus:ring-brand-500" />
                                    <span className="text-sm font-medium text-slate-700">Multi-Select</span>
                                </label>
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input type="checkbox" {...register('is_vertical')} className="w-4 h-4 text-brand-600 rounded border-slate-300 focus:ring-brand-500" />
                                    <span className="text-sm font-medium text-slate-700">Vertical Layout</span>
                                </label>
                            </div>
                        </div>

                        {/* Dynamic Fields */}
                        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm min-h-[400px]">
                            <div className="flex items-center justify-between mb-6 border-b border-slate-100 pb-2">
                                <h3 className="text-lg font-semibold text-slate-800">Question Content</h3>
                            </div>

                            {questionType === 'mcq' && <MCQForm control={control} register={register} type="text" />}
                            {questionType === 'imageChoice' && <MCQForm control={control} register={register} type="image" />}
                            {questionType === 'fillInTheBlank' && <FillBlankForm control={control} register={register} />}
                            {questionType === 'dragAndDrop' && <DragDropForm control={control} register={register} />}
                            {questionType === 'sorting' && <SortingForm control={control} register={register} />}
                            {questionType === 'fourPicsOneWord' && <FourPicsForm register={register} />}
                        </div>

                        {/* Solution */}
                        <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                            <h3 className="text-lg font-semibold text-slate-800 mb-4 border-b border-slate-100 pb-2">Solution Explanation</h3>
                            <textarea {...register('solution_text')} rows={4} className="w-full border-0 bg-slate-50 rounded-lg p-4 text-slate-700 focus:ring-2 focus:ring-brand-500" placeholder="Explain the solution (supports Markdown)..." />
                        </div>

                    </div>
                </div>

                {/* Right: Preview */}
                <div className="w-[400px] bg-slate-900 border-l border-slate-800 flex flex-col shadow-2xl z-10">
                    <div className="p-4 bg-slate-800 border-b border-slate-700 text-slate-400 text-xs font-bold uppercase tracking-wider flex items-center justify-between">
                        <span>Mobile Preview</span>
                        <div className="flex gap-1">
                            <div className="w-2 h-2 rounded-full bg-red-500" />
                            <div className="w-2 h-2 rounded-full bg-yellow-500" />
                            <div className="w-2 h-2 rounded-full bg-green-500" />
                        </div>
                    </div>
                    <div className="flex-1 p-6 overflow-y-auto flex justify-center">
                        <div className="w-[320px] bg-white h-[640px] rounded-[2rem] border-[8px] border-slate-800 shadow-2xl overflow-hidden relative flex flex-col">
                            {/* Phone Notch */}
                            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-6 bg-slate-800 rounded-b-xl z-20"></div>

                            {/* Phone Status Bar */}
                            <div className="bg-slate-100 h-8 w-full flex items-center justify-between px-6 pt-2">
                                <div className="text-[10px] font-bold text-slate-900">9:41</div>
                                <div className="text-[10px] font-bold text-slate-900">100%</div>
                            </div>

                            {/* Content */}
                            <div className="flex-1 overflow-y-auto bg-slate-50 p-4">
                                <PreviewContent data={watchedValues} />
                            </div>

                            {/* Available Points / Bottom Bar */}
                            <div className="h-16 bg-white border-t border-slate-100 flex items-center justify-center p-4">
                                <button className="w-full bg-brand-600 text-white rounded-full py-3 font-bold text-sm shadow-lg shadow-brand-500/30">
                                    Check Answer
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

// Sub-forms

function QuestionStemBuilder({ control, register }) {
    const { fields, append, remove } = useFieldArray({ control, name: 'parts' });

    // Ensure there's at least one text block
    React.useEffect(() => {
        if (fields.length === 0) {
            append({ type: 'text', content: '' });
        }
    }, [fields.length, append]);

    return (
        <div className="space-y-4">
            <div className="space-y-2">
                {fields.map((field, index) => (
                    <div key={field.id} className="flex items-start gap-2 p-3 bg-slate-50 border border-slate-100 rounded-lg">
                        <div className="w-24">
                            <select {...register(`parts.${index}.type`)} className="w-full text-xs border border-slate-300 rounded px-2 py-1">
                                <option value="text">Text</option>
                                <option value="image">Image</option>
                            </select>
                        </div>
                        <div className="flex-1">
                            <textarea
                                {...register(`parts.${index}.content`)}
                                placeholder={field.type === 'image' ? "Image URL" : "Question text..."}
                                rows={2}
                                className="w-full text-sm border border-slate-300 rounded px-2 py-1"
                            />
                        </div>
                        <button type="button" onClick={() => remove(index)} disabled={fields.length === 1} className="text-slate-400 hover:text-red-500 disabled:opacity-30"><X className="w-4 h-4" /></button>
                    </div>
                ))}
            </div>
            <button type="button" onClick={() => append({ type: 'text', content: '' })} className="px-3 py-1 bg-slate-100 hover:bg-slate-200 rounded text-xs text-slate-700 font-medium flex items-center gap-1">
                <Plus className="w-3 h-3" /> Add Text/Image Block
            </button>
        </div>
    );
}

function MCQForm({ control, register, type = 'text' }) {
    const { fields, append, remove } = useFieldArray({ control, name: 'options' });
    const watchedOptions = useWatch({
        control,
        name: 'options'
    });

    return (
        <div className="space-y-3">
            <p className="text-xs text-slate-500 mb-2">{type === 'image' ? 'Enter Image URLs for options.' : 'Enter text for options.'} Select the radio button for the correct answer.</p>
            {fields.map((field, index) => {
                // Use watched value for live preview, fallback to field default
                const value = watchedOptions?.[index]?.text ?? field.text;

                return (
                    <div key={field.id} className="flex items-center gap-3">
                        <MCQCheckbox control={control} index={index} register={register} />
                        <div className="flex-1">
                            <input
                                {...register(`options.${index}.text`)}
                                placeholder={type === 'image' ? "Image URL" : `Option ${index + 1}`}
                                className="w-full border border-slate-200 rounded-lg px-3 py-2 text-sm"
                            />
                            {type === 'image' && value && (
                                <img
                                    src={value}
                                    className="h-10 w-10 mt-2 object-cover rounded border border-slate-200"
                                    onError={(e) => e.target.style.display = 'none'}
                                    alt="Preview"
                                />
                            )}
                        </div>
                        <button onClick={() => remove(index)} className="text-slate-400 hover:text-red-500"><X className="w-4 h-4" /></button>
                    </div>
                );
            })}
            <button type="button" onClick={() => append({ text: '', isCorrect: false })} className="text-sm text-brand-600 font-medium flex items-center gap-1">
                <Plus className="w-4 h-4" /> Add {type === 'image' ? 'Image' : 'Option'}
            </button>
        </div>
    );
}

function FillBlankForm({ control, register }) {
    const { fields, append, remove } = useFieldArray({ control, name: 'fib_parts' });
    return (
        <div className="space-y-4">
            <p className="text-xs text-slate-500">Build the sentence/equation. Use 'Input' for the blank space.</p>
            <div className="space-y-2">
                {fields.map((field, index) => (
                    <div key={field.id} className="flex items-start gap-2 p-3 bg-slate-50 border border-slate-100 rounded-lg">
                        <div className="w-24">
                            <select {...register(`fib_parts.${index}.type`)} className="w-full text-xs border border-slate-300 rounded px-2 py-1">
                                <option value="text">Text</option>
                                <option value="image">Image</option>
                                <option value="input">Input (Blank)</option>
                            </select>
                        </div>
                        <div className="flex-1">
                            <input
                                {...register(`fib_parts.${index}.content`)}
                                placeholder="Content (Text, URL, or Answer key)"
                                className="w-full text-sm border border-slate-300 rounded px-2 py-1"
                            />
                        </div>
                        <button onClick={() => remove(index)}><X className="w-4 h-4 text-slate-400" /></button>
                    </div>
                ))}
            </div>
            <div className="flex gap-2">
                <button type="button" onClick={() => append({ type: 'text', content: '' })} className="px-3 py-1 bg-slate-100 rounded text-xs text-slate-700">+ Add Block</button>
            </div>
        </div>
    );
}

function DragDropForm({ control, register }) {
    const { fields: groupFields, append: appendGroup, remove: removeGroup } = useFieldArray({ control, name: 'drag_groups', keyName: 'customId' });
    const { fields: itemFields, append: appendItem, remove: removeItem } = useFieldArray({ control, name: 'drag_items', keyName: 'customId' });

    return (
        <div className="space-y-8">
            <div>
                <h4 className="text-sm font-semibold text-slate-900 mb-3 flex items-center justify-between">
                    <span>Groups (Buckets)</span>
                    <button type="button" onClick={() => appendGroup({ id: Date.now(), label: '' })} className="text-xs bg-slate-100 hover:bg-slate-200 px-2 py-1 rounded text-slate-700">+ Add Group</button>
                </h4>
                <div className="grid grid-cols-2 gap-4">
                    {groupFields.map((field, index) => (
                        <div key={field.customId} className="p-3 border border-slate-200 rounded-lg bg-slate-50 relative group">
                            <button onClick={() => removeGroup(index)} className="absolute top-2 right-2 text-slate-400 hover:text-red-500"><X className="w-3 h-3" /></button>
                            {/* Register the ID so it persists in form data */}
                            <input type="hidden" {...register(`drag_groups.${index}.id`)} />

                            <input {...register(`drag_groups.${index}.label`)} placeholder="Group Label" className="w-full text-sm font-medium bg-transparent border-0 border-b border-transparent focus:border-brand-500 px-0 focus:ring-0 mb-2" />
                            <div className="flex items-center gap-2">
                                <div className="w-8 h-8 rounded bg-slate-200 flex items-center justify-center text-slate-400">
                                    <ImageIcon className="w-4 h-4" />
                                </div>
                                <input {...register(`drag_groups.${index}.image`)} placeholder="Image URL (optional)" className="flex-1 text-xs border border-slate-200 rounded px-2 py-1" />
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <div>
                <h4 className="text-sm font-semibold text-slate-900 mb-3 flex items-center justify-between">
                    <span>Draggable Items</span>
                    <button type="button" onClick={() => appendItem({ id: Date.now(), text: '' })} className="text-xs bg-slate-100 hover:bg-slate-200 px-2 py-1 rounded text-slate-700">+ Add Item</button>
                </h4>
                <div className="space-y-2">
                    {itemFields.map((field, index) => (
                        <div key={field.customId} className="flex items-center gap-3 p-2 bg-slate-50 rounded border border-slate-100">
                            <GripVertical className="w-4 h-4 text-slate-400" />
                            {/* Register Item ID */}
                            <input type="hidden" {...register(`drag_items.${index}.id`)} />

                            <input {...register(`drag_items.${index}.text`)} placeholder="Item Text" className="flex-1 bg-white border border-slate-200 rounded px-2 py-1 text-sm" />
                            {/* Use a separate component to access watched groups without re-rendering the whole list constantly? 
                                Actually, just inline is fine for now, but we need to pass the watched values. 
                                Let's Pass control to a sub-component or just use generic indices if ID is tricky?
                                No, use a sub-component for the select so it can useWatch isolate.
                            */}
                            <GroupSelector control={control} register={register} index={index} />

                            <button onClick={() => removeItem(index)} className="text-slate-400 hover:text-red-500"><X className="w-4 h-4" /></button>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

function GroupSelector({ control, register, index }) {
    const groups = useWatch({ control, name: 'drag_groups' });
    return (
        <select {...register(`drag_items.${index}.group_id`)} className="text-xs border border-slate-200 rounded px-2 py-1 bg-white max-w-[120px]">
            <option value="">Select Group</option>
            {groups && groups.map((g, i) => (
                <option key={g.id || i} value={g.id}>
                    {g.label || `Group ${i + 1}`}
                </option>
            ))}
        </select>
    )
}

function SortingForm({ control, register }) {
    const { fields, append, remove } = useFieldArray({ control, name: 'sort_items' });
    return (
        <div className="space-y-2">
            <p className="text-xs text-slate-500 mb-2">Add items in the CORRECT order. They will be shuffled for the user.</p>
            {fields.map((field, index) => (
                <div key={field.id} className="flex items-center gap-2">
                    <span className="text-xs font-mono text-slate-400 w-4">{index + 1}</span>
                    <input {...register(`sort_items.${index}.text`)} className="flex-1 border border-slate-200 rounded px-3 py-2 text-sm" placeholder="Item content" />
                    <button onClick={() => remove(index)}><X className="w-4 h-4 text-slate-400 hover:text-red-500" /></button>
                </div>
            ))}
            <button onClick={() => append({ text: '' })} className="text-sm text-brand-600 font-medium mt-2 flex items-center gap-1"><Plus className="w-4 h-4" /> Add Item</button>
        </div>
    )
}

function FourPicsForm({ register }) {
    return (
        <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
                {[0, 1, 2, 3].map(i => (
                    <div key={i} className="aspect-square bg-slate-100 rounded-lg border border-slate-200 flex items-center justify-center relative overflow-hidden group">
                        <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                            <input {...register(`images.${i}`)} placeholder="URL" className="w-3/4 text-xs p-1 rounded" />
                        </div>
                        <ImageIcon className="w-8 h-8 text-slate-300" />
                    </div>
                ))}
            </div>
            <div>
                <label className="text-sm font-medium block mb-1">Jumbled Letters (Answer)</label>
                <input {...register('jumbled_letters')} className="w-full border border-slate-300 rounded px-3 py-2 uppercase tracking-widest font-bold text-center" placeholder="ANSWER" />
            </div>
        </div>
    )
}

// Preview Component

function PreviewContent({ data }) {
    if (!data) return null;

    return (
        <div className="space-y-6">
            {/* Question Header */}
            <div>
                <div className="flex items-center justify-between mb-2">
                    <span className={cn(
                        "text-[10px] font-bold px-2 py-0.5 rounded text-white uppercase",
                        data.difficulty === 'Easy' ? 'bg-green-500' : data.difficulty === 'Medium' ? 'bg-yellow-500' : 'bg-red-500'
                    )}>
                        {data.difficulty}
                    </span>
                    <span className="text-[10px] text-slate-400 font-medium">10 Points</span>
                </div>

                <h4 className="text-slate-900 font-bold text-lg leading-tight space-y-2">
                    {/* Render Parts */}
                    {data.parts?.map((p, i) => (
                        <div key={i}>
                            {p.type === 'image' ? (
                                <img src={p.content || p.imageUrl} className="max-w-full rounded-lg" alt="" />
                            ) : (
                                <p>{p.content}</p>
                            )}
                        </div>
                    ))}
                    {!data.parts?.length && (data.question_text || "Question content...")}
                </h4>
            </div>

            {/* Type Specific Preview */}
            <div className="mt-6">
                {data.type === 'mcq' && (
                    <div className="space-y-3">
                        {data.options?.map((opt, i) => (
                            <div key={i} className={cn(
                                "p-4 rounded-xl border-2 transition-all",
                                opt.isCorrect ? "border-green-500 bg-green-50/50" : "border-slate-200 bg-white"
                            )}>
                                <span className="font-semibold text-slate-800">{opt.text || `Option ${i + 1}`}</span>
                                {opt.isCorrect && <span className="float-right text-green-600 text-xs font-bold">✓ Correct</span>}
                            </div>
                        ))}
                    </div>
                )}

                {data.type === 'drag_drop' && (
                    <div className="space-y-6">
                        <div className="flex gap-2 flex-wrap justify-center">
                            {data.drag_items?.map((item, i) => (
                                <div key={i} className="bg-white px-4 py-2 rounded-lg shadow-sm border border-slate-200 text-sm font-medium text-slate-700">
                                    {item.text || "Item"}
                                </div>
                            ))}
                        </div>
                        <div className="grid grid-cols-2 gap-3">
                            {data.drag_groups?.map((group, i) => (
                                <div key={i} className="aspect-square rounded-xl bg-slate-200/50 border-2 border-dashed border-slate-300 flex flex-col items-center justify-center p-2 text-center">
                                    {group.image ? <img src={group.image} className="w-8 h-8 mb-2 object-cover rounded" /> : <div className="w-8 h-8 bg-slate-300 rounded mb-2" />}
                                    <span className="text-xs font-bold text-slate-600">{group.label || "Group"}</span>
                                </div>
                            ))}
                        </div>
                    </div>
                )}

                {data.type === 'sorting' && (
                    <div className="space-y-2">
                        {data.sort_items?.map((item, i) => (
                            <div key={i} className="bg-white p-3 rounded-lg border border-slate-300 shadow-sm flex items-center justify-between">
                                <span className="font-medium text-slate-700">{item.text || "Item"}</span>
                                <GripVertical className="w-4 h-4 text-slate-400" />
                            </div>
                        ))}
                    </div>
                )}

                {data.type === '4pics' && (
                    <div>
                        <div className="grid grid-cols-2 gap-2 mb-6">
                            {data.images?.map((img, i) => (
                                <div key={i} className="aspect-square bg-slate-200 rounded-lg overflow-hidden">
                                    {img && <img src={img} className="w-full h-full object-cover" />}
                                </div>
                            ))}
                        </div>
                        <div className="flex flex-wrap gap-2 justify-center">
                            {(data.jumbled_letters || 'ANSWER').split('').map((char, i) => (
                                <div key={i} className="w-8 h-8 bg-slate-800 rounded text-white font-bold flex items-center justify-center shadow-lg">
                                    {char}
                                </div>
                            ))}
                        </div>
                    </div>
                )}
            </div>
        </div>
    )
}

function MCQCheckbox({ control, index, register }) {
    const isMultiSelect = useWatch({ control, name: 'is_multi_select' });
    return (
        <input
            type={isMultiSelect ? "checkbox" : "radio"}
            {...register(`options.${index}.isCorrect`)}
            className="w-4 h-4 text-brand-600 focus:ring-brand-500"
        />
    );
}
