import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabaseClient';
import { ArrowLeft, Upload, AlertCircle, CheckCircle, FileJson } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';

export function JsonImport() {
    const navigate = useNavigate();
    const [jsonInput, setJsonInput] = useState('');
    const [status, setStatus] = useState({ type: '', message: '' });
    const [loading, setLoading] = useState(false);

    // State for Cascading Dropdowns
    const [grades, setGrades] = useState([]);
    const [units, setUnits] = useState([]);
    const [microSkills, setMicroSkills] = useState([]);
    const [selectedGrade, setSelectedGrade] = useState('');
    const [selectedUnit, setSelectedUnit] = useState('');
    const [selectedSkill, setSelectedSkill] = useState('');

    // Fetch Grades on load
    useEffect(() => {
        const fetchGrades = async () => {
            const { data } = await supabase.from('grades').select('*');
            if (data) setGrades(data);
        };
        fetchGrades();
    }, []);

    const fetchUnits = async (gradeId) => {
        // First get subjects for this grade
        const { data: subjects } = await supabase.from('subjects').select('id').eq('grade_id', gradeId);

        if (subjects && subjects.length > 0) {
            const subjectIds = subjects.map(s => s.id);
            // Then get units for these subjects
            const { data: units } = await supabase.from('units').select('*').in('subject_id', subjectIds);
            setUnits(units || []);
        } else {
            // Fallback: Check if units actally have grade_id (legacy support)
            const { data: units } = await supabase.from('units').select('*').eq('grade_id', gradeId);
            setUnits(units || []);
        }
    };

    const fetchMicroSkills = async (unitId) => {
        const { data } = await supabase.from('micro_skills').select('*').eq('unit_id', unitId);
        setMicroSkills(data || []);
    };

    const handleGradeChange = (e) => {
        const gradeId = e.target.value;
        setSelectedGrade(gradeId);
        setSelectedUnit('');
        setSelectedSkill('');
        setUnits([]);
        setMicroSkills([]);
        if (gradeId) fetchUnits(gradeId);
    };

    const handleUnitChange = (e) => {
        const unitId = e.target.value;
        setSelectedUnit(unitId);
        setSelectedSkill('');
        setMicroSkills([]);
        if (unitId) fetchMicroSkills(unitId);
    };

    // Helper to clean malformed JSON input
    const cleanJsonInput = (input) => {
        let clean = input.trim();

        // 1. Fix common typos and missing quotes on keys
        const replacements = {
            'grages': '"grades"',
            'grades': '"grades"',
            'subjects': '"subjects"',
            'units': '"units"',
            'micro_skills': '"micro_skills"',
            'questions': '"questions"'
        };

        // Regex to find unquoted keys followed by [ or :
        // e.g. grages[[ -> "grades": [
        Object.keys(replacements).forEach(key => {
            const regex = new RegExp(`${key}\\s*(\\[\\[|:|\\[)`, 'gi');
            clean = clean.replace(regex, (match, separator) => {
                // If double bracket [[, treat as start of array
                if (separator === '[[' || separator === '[') return `${replacements[key]}: [`;
                return `${replacements[key]}:`;
            });
        });

        // 2. Fix double brackets at end like ]] -> ]
        clean = clean.replace(/\]\]/g, ']');

        // 3. Fix double commas ,, -> ,
        clean = clean.replace(/,,/g, ',');

        // 4. Wrap in curly braces if it looks like a list of keys
        if (!clean.startsWith('{') && !clean.startsWith('[')) {
            // Check if it starts with a key we know
            if (clean.includes('"grades":') || clean.includes('"subjects":')) {
                clean = `{ ${clean} }`;
            } else if (clean.includes('"type":')) {
                // Should be an array of questions?
                clean = `[ ${clean} ]`;
            }
        }

        return clean;
    };

    const handleImport = async () => {
        if (!jsonInput.trim()) {
            setStatus({ type: 'error', message: 'Please paste valid JSON code.' });
            return;
        }

        setLoading(true);
        setStatus({ type: 'info', message: 'Parsing...' });

        try {
            const cleanedInput = cleanJsonInput(jsonInput);
            console.log("Cleaned Input:", cleanedInput); // For debugging
            const parsedData = JSON.parse(cleanedInput);

            // MODE 1: Full Database Restore (Grades, Subjects, Units, MicroSkills)
            if (parsedData.grades || parsedData.subjects || parsedData.units || parsedData.micro_skills) {
                let log = [];

                // 1. Grades
                if (parsedData.grades) {
                    // Flatten if nested arrays (handle grages[[...]])
                    const gradesData = parsedData.grades.flat();
                    setStatus({ type: 'info', message: `Importing ${gradesData.length} Grades...` });
                    const { error } = await supabase.from('grades').upsert(gradesData, { onConflict: 'id' });
                    if (error) throw new Error('Grades Import: ' + error.message);
                    log.push(`✓ ${gradesData.length} Grades`);
                }

                // 2. Subjects
                if (parsedData.subjects) {
                    const subjectsData = parsedData.subjects.flat();
                    setStatus({ type: 'info', message: `Importing ${subjectsData.length} Subjects...` });
                    const { error } = await supabase.from('subjects').upsert(subjectsData, { onConflict: 'id' });
                    if (error) throw new Error('Subjects Import: ' + error.message);
                    log.push(`✓ ${subjectsData.length} Subjects`);
                }

                // 3. Units
                if (parsedData.units) {
                    const unitsData = parsedData.units.flat();
                    setStatus({ type: 'info', message: `Importing ${unitsData.length} Units...` });
                    const { error } = await supabase.from('units').upsert(unitsData, { onConflict: 'id' });
                    if (error) throw new Error('Units Import: ' + error.message);
                    log.push(`✓ ${unitsData.length} Units`);
                }

                // 4. Micro Skills
                if (parsedData.micro_skills) {
                    const skillsData = parsedData.micro_skills.flat();
                    setStatus({ type: 'info', message: `Importing ${skillsData.length} Micro Skills...` });
                    const { error } = await supabase.from('micro_skills').upsert(skillsData, { onConflict: 'id' });
                    if (error) throw new Error('Micro Skills Import: ' + error.message);
                    log.push(`✓ ${skillsData.length} Micro Skills`);
                }

                setStatus({ type: 'success', message: 'Full Structure Imported: ' + log.join(', ') });
                setJsonInput('');
                // Refresh dropdowns
                navigate(0); // Reload page to fetch new dropdown data
                return;
            }

            // MODE 2: Question Import
            if (!selectedSkill) {
                setStatus({ type: 'error', message: 'Please select a Micro Skill to associate these questions with.' });
                setLoading(false);
                return;
            }

            const items = Array.isArray(parsedData) ? parsedData : [parsedData];
            setStatus({ type: 'info', message: `Importing ${items.length} questions...` });

            const payload = items.flat().map(item => ({
                micro_skill_id: selectedSkill,
                type: item.type || 'mcq',
                difficulty: (item.difficulty || 'medium').toLowerCase(),
                solution: item.solution || item.solution_text || '',
                marks: parseInt(item.marks) || 1,
                parts: item.parts || (item.question_text ? [{ type: 'text', content: item.question_text }] : []),
                options: typeof item.options === 'string' ? JSON.parse(item.options) : (item.options || []),
                drag_groups: typeof item.drag_groups === 'string' ? JSON.parse(item.drag_groups) : (item.drag_groups || []),
                drag_items: typeof item.drag_items === 'string' ? JSON.parse(item.drag_items) : (item.drag_items || []),
                correct_answer_index: item.correct_answer_index ?? -1,
                correct_answer_text: typeof item.correct_answer_text === 'object' ? JSON.stringify(item.correct_answer_text) : item.correct_answer_text
            }));

            const { error } = await supabase.from('questions').insert(payload);
            if (error) throw error;

            setStatus({ type: 'success', message: `Successfully imported ${payload.length} questions!` });
            setJsonInput('');

        } catch (err) {
            console.error(err);
            setStatus({ type: 'error', message: 'Import Failed. Check JSON format. Error: ' + err.message });
        } finally {
            setLoading(false);
        }
    };

    // Helper to extract text from parts if question_text is missing
    const getQuestionTextFromParts = (parts) => {
        if (!parts) return '';
        try {
            const p = typeof parts === 'string' ? JSON.parse(parts) : parts;
            const textPart = p.find(x => x.type === 'text');
            return textPart ? textPart.content : '';
        } catch (e) { return ''; }
    };

    return (
        <div className="max-w-4xl mx-auto space-y-6">
            <header className="flex items-center gap-4 py-4 border-b border-slate-200">
                <Link to="/" className="p-2 hover:bg-slate-100 rounded-full text-slate-500 hover:text-slate-900 transition-colors">
                    <ArrowLeft className="w-5 h-5" />
                </Link>
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Import Questions via JSON</h1>
                    <p className="text-slate-500 text-sm">Paste a JSON array of question objects to bulk import.</p>
                </div>
            </header>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* Configuration Panel */}
                <div className="space-y-4 bg-white p-5 rounded-xl border border-slate-200 shadow-sm h-fit">
                    <h3 className="font-semibold text-slate-800 flex items-center gap-2">
                        <CheckCircle className="w-4 h-4 text-brand-600" /> Target Skill
                    </h3>

                    <div className="space-y-3">
                        <div>
                            <label className="block text-xs font-medium text-slate-500 uppercase mb-1">Grade</label>
                            <select value={selectedGrade} onChange={handleGradeChange} className="w-full text-sm border-slate-300 rounded-lg">
                                <option value="">Select Grade</option>
                                {grades.map(g => <option key={g.id} value={g.id}>{g.name || g.level} (ID: {g.id})</option>)}
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-medium text-slate-500 uppercase mb-1">Unit</label>
                            <select value={selectedUnit} onChange={handleUnitChange} disabled={!selectedGrade || !units.length} className="w-full text-sm border-slate-300 rounded-lg disabled:bg-slate-100 disabled:text-slate-400 disabled:cursor-not-allowed">
                                <option value="">
                                    {!selectedGrade ? "Select Grade First..." : units.length === 0 ? "No Units Found" : "Select Unit"}
                                </option>
                                {units.map(u => <option key={u.id} value={u.id}>{u.name || u.description}</option>)}
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-medium text-slate-500 uppercase mb-1">Micro Skill</label>
                            <select value={selectedSkill} onChange={(e) => setSelectedSkill(e.target.value)} disabled={!selectedUnit || !microSkills.length} className="w-full text-sm border-slate-300 rounded-lg disabled:bg-slate-100 disabled:text-slate-400 disabled:cursor-not-allowed">
                                <option value="">
                                    {!selectedUnit ? "Select Unit First..." : microSkills.length === 0 ? "No Skills Found" : "Select Skill"}
                                </option>
                                {microSkills.map(ms => <option key={ms.id} value={ms.id}>{ms.name || ms.code}</option>)}
                            </select>
                        </div>
                    </div>

                    <div className="pt-4 border-t border-slate-100">
                        <button
                            onClick={handleImport}
                            disabled={loading}
                            className="w-full py-2 bg-brand-600 hover:bg-brand-700 disabled:bg-slate-300 text-white rounded-lg font-medium flex items-center justify-center gap-2 transition-all shadow-sm"
                        >
                            {loading ? 'Importing...' : <><Upload className="w-4 h-4" /> Import JSON</>}
                        </button>
                    </div>

                    {status.message && (
                        <div className={`p-3 rounded-lg text-xs leading-relaxed ${status.type === 'error' ? 'bg-red-50 text-red-700' : 'bg-green-50 text-green-700'}`}>
                            {status.type === 'error' && <AlertCircle className="w-3 h-3 inline mr-1 mb-0.5" />}
                            {status.message}
                        </div>
                    )}
                </div>

                {/* JSON Editor */}
                <div className="md:col-span-2 space-y-2">
                    <label className="text-sm font-medium text-slate-700 flex items-center justify-between">
                        <span>JSON Payload</span>
                        <span className="text-xs text-slate-400 font-mono">Questions Array [] OR Full DB Object { }</span>
                    </label>
                    <div className="relative">
                        <textarea
                            value={jsonInput}
                            onChange={(e) => setJsonInput(e.target.value)}
                            className="w-full h-[600px] font-mono text-xs bg-slate-900 text-slate-200 p-4 rounded-xl focus:ring-2 focus:ring-brand-500 border-0 resize-none leading-relaxed"
                            placeholder={`// QUESTION IMPORT:\n[\n  {\n    "type": "mcq",\n    "question_text": "Example?",\n    ...\n  }\n]\n\n// OR FULL RESTORE:\n{\n  "grades": [...],\n  "units": [...],\n  "micro_skills": [...]\n}`}
                        />
                        <FileJson className="absolute top-4 right-4 text-slate-600 w-5 h-5" />
                    </div>
                </div>
            </div>
        </div>
    );
}
