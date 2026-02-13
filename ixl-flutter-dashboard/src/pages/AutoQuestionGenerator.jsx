
import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabaseClient';
import { Wand2, Loader2, Save, FileText, CheckCircle, Key, Copy, Check, Code, Type } from 'lucide-react';
import { GoogleGenerativeAI } from "@google/generative-ai";

const QUESTION_TEMPLATES = {
    mcq: {
        label: "Multiple Choice",
        formats: [
            {
                name: "Standard MCQ",
                instructions: "Generate standard multiple-choice questions with 4 options.",
                schema: {
                    "type": "mcq",
                    "difficulty": "Medium",
                    "marks": 1,
                    "complexity": 5,
                    "sub_topic": "Topic Name",
                    "is_multi_select": false,
                    "is_vertical": true,
                    "parts": [
                        { "type": "text", "content": "Question text here" }
                    ],
                    "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
                    "correct_answer_index": 0,
                    "solution": "Brief explanation of the correct answer"
                }
            },
            {
                name: "Image Based MCQ",
                instructions: "Generate multiple-choice questions that include an image prompt.",
                schema: {
                    "type": "mcq",
                    "difficulty": "Medium",
                    "marks": 1,
                    "is_multi_select": false,
                    "parts": [
                        { "type": "text", "content": "Identify the image:" },
                        { "type": "image", "imageUrl": "https://placehold.co/200", "height": 150 }
                    ],
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correct_answer_index": 0,
                    "solution": "Explanation"
                }
            }
        ]
    },
    place_value: {
        label: "Place Value",
        formats: [
            {
                name: "Visual Blocks (Tens/Ones)",
                instructions: "For each question, randomize a number between 10 and 99. Break it down into Tens and Ones visual blocks.",
                schema: {
                    "type": "fillInTheBlank",
                    "difficulty": "Easy",
                    "marks": 1,
                    "complexity": 10,
                    "sub_topic": "Counting Tens and Ones",
                    "parts": [
                        { "type": "text", "content": "Look at the blocks. How many Tens and Ones are there?" },
                        {
                            "type": "sequence",
                            "children": [
                                { "type": "image", "height": 60, "imageUrl": "https://placehold.co/10x60/orange/white?text=10" },
                                { "type": "image", "height": 20, "imageUrl": "https://placehold.co/10x10/blue/white?text=1" }
                            ]
                        },
                        { "type": "text", "content": "Tens: " },
                        { "id": "t", "type": "input" },
                        { "type": "text", "content": " Ones: " },
                        { "id": "o", "type": "input" }
                    ],
                    "correct_answer_text": { "t": "2", "o": "3" },
                    "solution": "Step-by-step explanation counting the strips and blocks."
                }
            }
        ]
    },
    true_false: {
        label: "True / False",
        formats: [
            {
                name: "Standard True/False",
                instructions: "Generate True/False questions based on the topic.",
                schema: {
                    "type": "mcq",
                    "difficulty": "Easy",
                    "marks": 1,
                    "sub_topic": "Concept Check",
                    "parts": [
                        { "type": "text", "content": "The statement is true." }
                    ],
                    "options": ["True", "False"],
                    "correct_answer_index": 0,
                    "solution": "Explanation"
                }
            }
        ]
    },
    fill_blank: {
        label: "Fill in the Blank",
        formats: [
            {
                name: "Single Input",
                instructions: "Generate fill-in-the-blank questions with a single missing value.",
                schema: {
                    "type": "fillInTheBlank",
                    "difficulty": "Medium",
                    "marks": 1,
                    "parts": [
                        { "type": "text", "content": "The output of 2 + 2 is " },
                        { "type": "input", "id": "ans" }
                    ],
                    "correct_answer_text": { "ans": "4" },
                    "solution": "2 + 2 = 4"
                }
            }
        ]
    },
    match: {
        label: "Match the Following",
        formats: [
            {
                name: "Pairs",
                instructions: "Generate matching questions with 2-4 pairs.",
                schema: {
                    "type": "match",
                    "difficulty": "Medium",
                    "marks": 2,
                    "parts": [
                        { "type": "text", "content": "Match the following items:" }
                    ],
                    "pairs": [
                        { "left": "Item A", "right": "Match A" },
                        { "left": "Item B", "right": "Match B" }
                    ],
                    "solution": "A-A, B-B"
                }
            }
        ]
    },
    calendar: {
        label: "Calendar Reading",
        formats: [
            {
                name: "Date Finding",
                instructions: "Generate questions that require reading a calendar month.",
                schema: {
                    "type": "mcq",
                    "template": "calendar",
                    "difficulty": "Easy",
                    "month": "October",
                    "year": 2023,
                    "highlight_date": 15,
                    "parts": [
                        { "type": "text", "content": "What day of the week is the 15th?" },
                        { "type": "calendar_view", "month": 10, "year": 2023, "highlight": [15] }
                    ],
                    "options": ["Monday", "Tuesday", "Wednesday", "Thursday"],
                    "correct_answer_index": 0,
                    "solution": "Look at the calendar."
                }
            }
        ]
    },
    image_choice: {
        label: "Image Choice",
        formats: [
            {
                name: "Select Image",
                instructions: "Generate multiple-choice questions where the options are images.",
                schema: {
                    "type": "imageChoice",
                    "difficulty": "Medium",
                    "marks": 1,
                    "sub_topic": "Visual Identification",
                    "parts": [
                        { "type": "text", "content": "Which object is a solid?" }
                    ],
                    "options": [
                        "https://example.com/image1.png",
                        "https://example.com/image2.png",
                        "https://example.com/image3.png",
                        "https://example.com/image4.png"
                    ],
                    "correct_answer_index": 0,
                    "solution": "The first image shows a solid object."
                }
            }
        ]
    },
    drag_drop: {
        label: "Drag and Drop",
        formats: [
            {
                name: "Categorization",
                instructions: "Generate drag-and-drop questions with groups and items.",
                schema: {
                    "type": "dragAndDrop",
                    "difficulty": "Medium",
                    "marks": 1,
                    "sub_topic": "Categorization",
                    "parts": [
                        { "type": "text", "content": "Drag the items to the correct category." }
                    ],
                    "drag_groups": [
                        { "id": "g1", "image": "https://placehold.co/100?text=Group A", "label": "Group A" },
                        { "id": "g2", "image": "https://placehold.co/100?text=Group B", "label": "Group B" }
                    ],
                    "drag_items": [
                        { "id": "i1", "type": "text", "content": "Item 1", "target_group_id": "g1" },
                        { "id": "i2", "type": "text", "content": "Item 2", "target_group_id": "g2" }
                    ],
                    "solution": "Item 1 goes to Group A, Item 2 goes to Group B."
                }
            }
        ]
    },
    sorting: {
        label: "Sorting / Ordering",
        formats: [
            {
                name: "Standard Sort",
                instructions: "Generate questions where items need to be sorted in a specific order (e.g., ascending, chronological).",
                schema: {
                    "type": "sorting",
                    "difficulty": "Medium",
                    "marks": 1,
                    "sub_topic": "Ordering",
                    "parts": [
                        { "type": "text", "content": "Sort the numbers from lowest to highest." }
                    ],
                    "options": ["4", "8", "12", "16"],
                    "solution": "4, 8, 12, 16 is the correct order."
                }
            }
        ]
    }
};

export function AutoQuestionGenerator() {
    const [grades, setGrades] = useState([]);
    const [subjects, setSubjects] = useState([]);
    const [units, setUnits] = useState([]);
    const [microSkills, setMicroSkills] = useState([]);

    const [selectedGrade, setSelectedGrade] = useState('');
    const [selectedSubject, setSelectedSubject] = useState('');
    const [selectedUnit, setSelectedUnit] = useState('');
    const [selectedMicroSkill, setSelectedMicroSkill] = useState('');

    const [numQuestions, setNumQuestions] = useState(5);
    const [promptText, setPromptText] = useState('');
    const [apiKey, setApiKey] = useState('');

    const [isGenerating, setIsGenerating] = useState(false);
    const [generatedQuestions, setGeneratedQuestions] = useState([]);
    const [error, setError] = useState('');

    useEffect(() => {
        fetchGrades();
        // Check local storage for API key for convenience
        const storedKey = localStorage.getItem('AIzaSyBpEOSzAXzl7a2csy9pea5aUP7_nHnPSqU');
        if (storedKey) setApiKey(storedKey);
    }, []);

    const fetchGrades = async () => {
        const { data, error } = await supabase.from('grades').select('id, name').order('sort_order');
        if (error) console.error('Error fetching grades:', error);
        else setGrades(data || []);
    };

    const handleGradeChange = async (e) => {
        const gradeId = e.target.value;
        setSelectedGrade(gradeId);
        setSelectedSubject('');
        setSelectedUnit('');
        setSelectedMicroSkill('');
        setSubjects([]);
        setUnits([]);
        setMicroSkills([]);

        if (gradeId) {
            const { data } = await supabase.from('subjects').select('id, name').eq('grade_id', gradeId).order('name');
            setSubjects(data || []);
        }
    };

    const handleSubjectChange = async (e) => {
        const subjectId = e.target.value;
        setSelectedSubject(subjectId);
        setSelectedUnit('');
        setSelectedMicroSkill('');
        setUnits([]);
        setMicroSkills([]);

        if (subjectId) {
            const { data } = await supabase.from('units').select('id, name').eq('subject_id', subjectId).order('sort_order');
            setUnits(data || []);
        }
    };

    const handleUnitChange = async (e) => {
        const unitId = e.target.value;
        setSelectedUnit(unitId);
        setSelectedMicroSkill('');
        setMicroSkills([]);

        if (unitId) {
            const { data } = await supabase.from('micro_skills').select('id, name, code, prompt').eq('unit_id', unitId).order('sort_order');
            setMicroSkills(data || []);
        }
    };

    const handleMicroSkillChange = (e) => {
        const skillId = e.target.value;
        setSelectedMicroSkill(skillId);

        const skill = microSkills.find(m => m.id === skillId);
        if (skill?.prompt) {
            setPromptText(skill.prompt);
        }
    };

    const handleApiKeyChange = (e) => {
        const key = e.target.value;
        setApiKey(key);
        localStorage.setItem('gemini_api_key', key);
    };

    const [generationType, setGenerationType] = useState('mcq');
    const [selectedFormatIndex, setSelectedFormatIndex] = useState(0);
    const [jsonSchema, setJsonSchema] = useState(JSON.stringify(QUESTION_TEMPLATES['mcq'].formats[0].schema, null, 2));

    // Update schema when type or format changes
    useEffect(() => {
        if (QUESTION_TEMPLATES[generationType]) {
            const formats = QUESTION_TEMPLATES[generationType].formats;
            const format = formats[selectedFormatIndex] || formats[0];
            setJsonSchema(JSON.stringify(format.schema, null, 2));
        }
    }, [generationType, selectedFormatIndex]);

    const handleGenerate = async () => {
        if (!selectedMicroSkill && generationType === 'mcq') { // Micro Skill not strictly needed for place_value
            setError('Please select a Micro Skill');
            return;
        }
        if (!apiKey) {
            setError('Please enter a Gemini API Key');
            return;
        }

        setError('');
        setIsGenerating(true);

        try {
            const genAI = new GoogleGenerativeAI(apiKey);
            const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

            const microSkillName = microSkills.find(m => m.id === selectedMicroSkill)?.name || 'the selected topic';
            const gradeName = grades.find(g => g.id === selectedGrade)?.name || '';
            const subjectName = subjects.find(s => s.id === selectedSubject)?.name || '';
            const unitName = units.find(u => u.id === selectedUnit)?.name || '';

            const template = QUESTION_TEMPLATES[generationType];
            const format = template.formats[selectedFormatIndex];

            // Build the prompt
            const baseInstructions = format.instructions || `Generate ${numQuestions} questions based on the context provided.`;

            let prompt = `
                Role: Educational Content Generator
                Task: Generate ${numQuestions} questions for the following context.
                
                Context:
                Grade: ${gradeName}
                Subject: ${subjectName}
                Unit: ${unitName}
                Micro-Skill: ${microSkillName}
                User Constraints: ${promptText}
                
                Specific Instructions:
                ${baseInstructions}
                
                Output Format:
                Format the output as a JSON array strictly following this schema for each question:
                ${jsonSchema}
                
                Constraints:
                - Do not include markdown formatting (like \`\`\`json).
                - Return STRICTLY the raw JSON array.
                - Ensure valid JSON syntax.
            `;

            console.log('Sending prompt to Gemini:', prompt);

            const result = await model.generateContent(prompt);
            const response = await result.response;
            const text = response.text();

            console.log('Gemini response:', text);

            // Clean up code blocks if present (sometimes models add markdown despite instructions)
            const cleanText = text.replace(/```json/g, '').replace(/```/g, '').trim();

            const questions = JSON.parse(cleanText);

            // Validate structure
            if (!Array.isArray(questions)) throw new Error('Response is not an array');

            setGeneratedQuestions(questions);
        } catch (err) {
            console.error('Generation Error:', err);
            setError('Failed to generate questions. ' + (err.message || 'Check API key.'));
        } finally {
            setIsGenerating(false);
        }
    };

    const [isCopied, setIsCopied] = useState(false);

    const handleCopyJson = () => {
        navigator.clipboard.writeText(JSON.stringify(generatedQuestions, null, 2));
        setIsCopied(true);
        setTimeout(() => setIsCopied(false), 2000);
    };

    // Recursive helper to render parts
    const renderPart = (p, idx, context = {}) => {
        if (p.type === 'text') {
            // Check if content contains HTML/SVG tags
            if (p.content && (p.content.includes('<svg') || p.content.includes('<div') || p.content.includes('<img'))) {
                return <div key={idx} className="my-2" dangerouslySetInnerHTML={{ __html: p.content }} />;
            }
            return <span key={idx} className="mr-1">{p.content}</span>;
        }
        if (p.type === 'svg' || p.type === 'html') {
            return <div key={idx} className="my-2" dangerouslySetInnerHTML={{ __html: p.content }} />;
        }
        if (p.type === 'image') return <img key={idx} src={p.imageUrl || p.content} height={p.height} className="inline-block mx-1 rounded border border-slate-200" alt="" />;
        if (p.type === 'sequence' && p.children) {
            return (
                <div key={idx} className="flex gap-1 flex-wrap items-end my-2 p-2 bg-slate-100 rounded-lg justify-center">
                    {p.children.map((child, cIdx) => renderPart(child, `${idx}-${cIdx}`))}
                </div>
            );
        }
        if (p.type === 'input') {
            const correctVal = context.correct_answer_text?.[p.id];
            return (
                <span key={idx} className="inline-flex items-center gap-1">
                    <input disabled className="w-12 text-center border border-slate-300 rounded p-1 bg-white text-slate-900 font-bold" placeholder="?" />
                    {correctVal && <span className="text-[10px] text-green-600 font-mono bg-green-50 px-1 rounded border border-green-200">{correctVal}</span>}
                </span>
            );
        }
        if (p.type === 'calendar_view') {
            return (
                <div key={idx} className="my-2 p-4 bg-white border rounded shadow-sm max-w-[200px] mx-auto">
                    <div className="font-bold text-center mb-2 text-sm">{p.month} {p.year}</div>
                    <div className="grid grid-cols-7 gap-1 text-center text-[10px]">
                        {['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map(d => <div key={d} className="font-bold text-slate-400">{d}</div>)}
                        {/* Placeholder for days - standard 30 day visualization for preview */}
                        {Array.from({ length: 30 }).map((_, i) => {
                            const date = i + 1;
                            const isHighlight = p.highlight && p.highlight.includes(date);
                            return <div key={i} className={`p-1 ${isHighlight ? 'bg-brand-100 text-brand-700 rounded-full font-bold' : ''}`}>{date}</div>
                        })}
                    </div>
                </div>
            );
        }
        return null;
    };

    return (
        <div className="space-y-6">
            <header>
                <h1 className="text-3xl font-bold text-slate-900 flex items-center gap-2">
                    <Wand2 className="w-8 h-8 text-brand-500" />
                    Auto Question Generator
                </h1>
                <p className="text-slate-500 mt-1">Generate questions automatically using AI based on micro-skills</p>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Configuration Panel */}
                <div className="lg:col-span-1 space-y-6">
                    <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm space-y-4">
                        <h2 className="font-semibold text-slate-900 flex items-center gap-2">
                            <FileText className="w-5 h-5 text-slate-400" />
                            Configuration
                        </h2>

                        <div className="space-y-4">
                            {/* API Key Input */}
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1 flex items-center gap-1">
                                    <Key className="w-3 h-3" /> Gemini API Key
                                </label>
                                <input
                                    type="password"
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                                    placeholder="Enter your Gemini API key"
                                    value={apiKey}
                                    onChange={handleApiKeyChange}
                                />
                                <p className="text-xs text-slate-400 mt-1">Key is saved locally in your browser.</p>
                            </div>

                            <hr className="border-slate-100" />

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Question Type</label>
                                    <select
                                        className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                                        value={generationType}
                                        onChange={(e) => {
                                            setGenerationType(e.target.value);
                                            setSelectedFormatIndex(0);
                                        }}
                                    >
                                        {Object.entries(QUESTION_TEMPLATES).map(([key, tmpl]) => (
                                            <option key={key} value={key}>{tmpl.label}</option>
                                        ))}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 mb-1">Format</label>
                                    <select
                                        className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                                        value={selectedFormatIndex}
                                        onChange={(e) => setSelectedFormatIndex(parseInt(e.target.value))}
                                    >
                                        {QUESTION_TEMPLATES[generationType].formats.map((fmt, idx) => (
                                            <option key={idx} value={idx}>{fmt.name}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200" data-tour="schema-editor">
                                <label className="block text-xs font-semibold text-slate-500 mb-1 flex items-center justify-between">
                                    <span className="flex items-center gap-1"><Code className="w-3 h-3" /> JSON Schema (Editable)</span>
                                    <button
                                        onClick={() => {
                                            const fmt = QUESTION_TEMPLATES[generationType].formats[selectedFormatIndex];
                                            setJsonSchema(JSON.stringify(fmt.schema, null, 2));
                                        }}
                                        className="text-brand-600 hover:text-brand-700 text-[10px] font-medium"
                                    >
                                        Reset
                                    </button>
                                </label>
                                <textarea
                                    className="w-full bg-white text-slate-600 font-mono text-xs p-2 rounded border border-slate-200 h-32 focus:ring-1 focus:ring-brand-500 outline-none resize-y"
                                    value={jsonSchema}
                                    onChange={(e) => setJsonSchema(e.target.value)}
                                    spellCheck={false}
                                />
                                <p className="text-[10px] text-slate-400 mt-1">This schema defines the exact output format for the AI.</p>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Grade</label>
                                <select
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                                    value={selectedGrade}
                                    onChange={handleGradeChange}
                                >
                                    <option value="">Select Grade</option>
                                    {grades.map(g => <option key={g.id} value={g.id}>{g.name}</option>)}
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Subject</label>
                                <select
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500 disabled:bg-slate-50 disabled:text-slate-400"
                                    value={selectedSubject}
                                    onChange={handleSubjectChange}
                                    disabled={!selectedGrade}
                                >
                                    <option value="">Select Subject</option>
                                    {subjects.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Unit</label>
                                <select
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500 disabled:bg-slate-50 disabled:text-slate-400"
                                    value={selectedUnit}
                                    onChange={handleUnitChange}
                                    disabled={!selectedSubject}
                                >
                                    <option value="">Select Unit</option>
                                    {units.map(u => <option key={u.id} value={u.id}>{u.name}</option>)}
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Micro Skill</label>
                                <select
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500 disabled:bg-slate-50 disabled:text-slate-400"
                                    value={selectedMicroSkill}
                                    onChange={handleMicroSkillChange}
                                    disabled={!selectedUnit || generationType === 'place_value'} // Disable if place_value
                                >
                                    <option value="">Select Micro Skill</option>
                                    {microSkills.map(m => <option key={m.id} value={m.id}>{m.name} ({m.code})</option>)}
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Number of Questions</label>
                                <input
                                    type="number"
                                    min="1"
                                    max="20"
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                                    value={numQuestions}
                                    onChange={(e) => setNumQuestions(parseInt(e.target.value) || 1)}
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Prompt / Context</label>
                                <textarea
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm min-h-[100px] focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                                    placeholder="Enter additional context or instructions for generation..."
                                    value={promptText}
                                    onChange={(e) => setPromptText(e.target.value)}
                                />
                            </div>

                            {error && (
                                <div className="p-3 bg-red-50 text-red-600 text-sm rounded-lg">
                                    {error}
                                </div>
                            )}

                            <button
                                onClick={handleGenerate}
                                disabled={isGenerating || (generationType === 'mcq' && !selectedMicroSkill) || !apiKey}
                                className="w-full bg-brand-600 hover:bg-brand-700 disabled:bg-slate-300 disabled:cursor-not-allowed text-white font-medium py-2.5 rounded-lg flex items-center justify-center gap-2 transition-colors shadow-sm"
                            >
                                {isGenerating ? (
                                    <>
                                        <Loader2 className="w-5 h-5 animate-spin" />
                                        Generating...
                                    </>
                                ) : (
                                    <>
                                        <Wand2 className="w-5 h-5" />
                                        Generate Questions
                                    </>
                                )}
                            </button>
                        </div>
                    </div>
                </div>

                {/* Preview Panel */}
                <div className="lg:col-span-2 space-y-6">
                    <div className="bg-white p-6 rounded-xl border border-slate-200 shadow-sm min-h-[400px]">
                        <div className="flex items-center justify-between mb-6">
                            <h2 className="font-semibold text-slate-900 flex items-center gap-2">
                                <CheckCircle className="w-5 h-5 text-slate-400" />
                                Generated Output
                            </h2>
                            {generatedQuestions.length > 0 && (
                                <button
                                    onClick={handleCopyJson}
                                    className="text-sm font-medium text-brand-600 hover:text-brand-700 flex items-center gap-1"
                                >
                                    {isCopied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                                    {isCopied ? 'Copied!' : 'Copy JSON'}
                                </button>
                            )}
                        </div>

                        {generatedQuestions.length === 0 ? (
                            <div className="h-64 flex flex-col items-center justify-center text-slate-400 border-2 border-dashed border-slate-200 rounded-xl bg-slate-50">
                                <Wand2 className="w-12 h-12 mb-3 opacity-20" />
                                <p>No questions generated yet</p>
                                <p className="text-sm">Configure settings, enter API Key, and click generate to start</p>
                            </div>
                        ) : (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {generatedQuestions.map((q, idx) => (
                                    <div key={idx} className="relative group">
                                        <div className="w-full bg-slate-900 rounded-[2rem] p-2 shadow-xl border-4 border-slate-800">
                                            {/* Fake Phone UI */}
                                            <div className="bg-slate-50 rounded-[1.5rem] overflow-hidden min-h-[400px] text-left relative flex flex-col">
                                                {/* Status Bar */}
                                                <div className="bg-white px-4 py-2 flex justify-between items-center text-[10px] text-slate-900 font-bold border-b border-slate-100">
                                                    <span>9:41</span>
                                                    <span>100%</span>
                                                </div>

                                                <div className="p-4 space-y-4 flex-1 overflow-y-auto">
                                                    {/* Header */}
                                                    <div className="flex items-center justify-between flex-wrap gap-2">
                                                        <div className="flex items-center gap-2">
                                                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded text-white uppercase ${q.difficulty === 'Easy' ? 'bg-green-500' : q.difficulty === 'Hard' ? 'bg-red-500' : 'bg-yellow-500'}`}>
                                                                {q.difficulty || 'Medium'}
                                                            </span>
                                                            <span className="text-[10px] bg-slate-200 text-slate-600 px-2 py-0.5 rounded font-medium">
                                                                {q.sub_topic || 'General'}
                                                            </span>
                                                        </div>
                                                        <div className="flex items-center gap-2 text-[10px] text-slate-400 font-medium">
                                                            <span>Comp: {q.complexity || '-'}</span>
                                                            <span>•</span>
                                                            <span>{q.marks || 1} Pts</span>
                                                        </div>
                                                    </div>

                                                    {/* Content (Parts) */}
                                                    <div className="text-slate-900 font-medium text-base leading-relaxed">
                                                        {q.parts && q.parts.map((p, i) => renderPart(p, i, q))}
                                                    </div>

                                                    {/* Options (MCQ, Image Choice, True/False, Calendar, Sorting) */}
                                                    {(q.type === 'mcq' || q.type === 'imageChoice' || q.type === 'sorting' || (q.options && !q.type?.includes('drag'))) && (
                                                        <div className="space-y-2 mt-4">
                                                            {q.type === 'sorting' && <p className="text-xs text-slate-500 font-medium italic">Items to sort:</p>}
                                                            {q.options?.map((opt, i) => {
                                                                const isCorrect = i === q.correct_answer_index;
                                                                // Simple check if option looks like a URL for imageChoice
                                                                const isUrl = typeof opt === 'string' && (opt.startsWith('http') || opt.startsWith('/'));

                                                                return (
                                                                    <div key={i} className={`p-3 rounded-lg border-2 transition-all ${isCorrect && q.type !== 'sorting' ? 'border-green-500 bg-green-50' : 'border-slate-200 bg-white'}`}>
                                                                        <div className="flex justify-between items-center">
                                                                            {q.type === 'imageChoice' || (isUrl && q.type !== 'sorting') ? (
                                                                                <img src={opt} alt={`Option ${i + 1}`} className="h-24 object-contain rounded" />
                                                                            ) : (
                                                                                <span className="text-sm font-medium text-slate-700">{opt}</span>
                                                                            )}

                                                                            {isCorrect && q.type !== 'sorting' && <CheckCircle className="w-4 h-4 text-green-500" />}
                                                                        </div>
                                                                    </div>
                                                                );
                                                            })}
                                                        </div>
                                                    )}

                                                    {/* Match Pairs */}
                                                    {q.type === 'match' && q.pairs && (
                                                        <div className="grid grid-cols-2 gap-2 mt-4">
                                                            {q.pairs.map((pair, idx) => (
                                                                <React.Fragment key={idx}>
                                                                    <div className="p-3 bg-slate-100 rounded border border-slate-200 text-sm font-medium flex items-center">{pair.left}</div>
                                                                    <div className="p-3 bg-white rounded border border-slate-200 text-sm flex items-center">{pair.right}</div>
                                                                </React.Fragment>
                                                            ))}
                                                        </div>
                                                    )}

                                                    {/* Drag and Drop */}
                                                    {q.type === 'dragAndDrop' && (
                                                        <div className="mt-4 space-y-4">
                                                            {/* Drop Zones */}
                                                            <div className="flex flex-wrap gap-4 justify-center">
                                                                {q.drag_groups?.map((group, idx) => (
                                                                    <div key={idx} className="w-32 min-h-[100px] border-2 border-dashed border-slate-300 rounded-lg p-2 bg-slate-50 flex flex-col items-center">
                                                                        {group.image && <img src={group.image} className="w-16 h-16 object-contain mb-1" />}
                                                                        <span className="text-xs font-bold text-slate-600 text-center">{group.label}</span>
                                                                        {/* Simulated items dropped here */}
                                                                        <div className="mt-2 w-full space-y-1">
                                                                            {q.drag_items?.filter(i => i.target_group_id === group.id).map((item, itemIdx) => (
                                                                                <div key={itemIdx} className="bg-white border border-slate-200 rounded px-2 py-1 text-[10px] shadow-sm text-center flex justify-center items-center">
                                                                                    {item.content && item.content.includes('<svg') ? (
                                                                                        <div dangerouslySetInnerHTML={{ __html: item.content }} className="w-full flex justify-center" />
                                                                                    ) : (item.content && (item.content.startsWith('http') || item.content.startsWith('/'))) ? (
                                                                                        <img src={item.content} className="h-8 w-auto object-contain" alt="" />
                                                                                    ) : (
                                                                                        item.content
                                                                                    )}
                                                                                </div>
                                                                            ))}
                                                                        </div>
                                                                    </div>
                                                                ))}
                                                            </div>

                                                            {/* Draggable Items Source */}
                                                            {q.drag_items && (
                                                                <div className="p-2 bg-slate-100 rounded border border-slate-200">
                                                                    <p className="text-[10px] text-slate-400 mb-2">Draggable Items:</p>
                                                                    <div className="flex flex-wrap gap-2">
                                                                        {q.drag_items.map((item, idx) => (
                                                                            <span key={idx} className="bg-white px-2 py-1 rounded shadow-sm border border-slate-200 text-xs font-bold flex items-center justify-center p-1">
                                                                                {item.content && item.content.includes('<svg') ? (
                                                                                    <div dangerouslySetInnerHTML={{ __html: item.content }} className="scale-75 origin-center" />
                                                                                ) : (item.content && (item.content.startsWith('http') || item.content.startsWith('/'))) ? (
                                                                                    <img src={item.content} className="h-8 w-auto object-contain" alt="" />
                                                                                ) : (
                                                                                    item.content
                                                                                )}
                                                                            </span>
                                                                        ))}
                                                                    </div>
                                                                </div>
                                                            )}
                                                        </div>
                                                    )}

                                                    {/* Ordering Items (Legacy or if using 'items' instead of 'options') */}
                                                    {q.type === 'ordering' && q.items && (
                                                        <div className="space-y-2 mt-4">
                                                            {q.items.map((item, idx) => (
                                                                <div key={idx} className="p-3 bg-white rounded border border-slate-200 shadow-sm flex items-center gap-3">
                                                                    <div className="bg-slate-100 w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold text-slate-500">{idx + 1}</div>
                                                                    <span className="text-sm">{item.content}</span>
                                                                </div>
                                                            ))}
                                                        </div>
                                                    )}

                                                    {/* Solution */}
                                                    {q.solution && (
                                                        <div className="mt-4 p-3 bg-blue-50 rounded-lg text-xs text-blue-800 border border-blue-100">
                                                            <span className="font-bold block mb-1">Solution:</span>
                                                            {q.solution}
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                        </div>
                                        <div className="absolute -top-3 -right-3 bg-brand-600 text-white w-8 h-8 flex items-center justify-center rounded-full font-bold shadow-lg z-10">
                                            {idx + 1}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
