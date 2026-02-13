
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Plus, Search, Filter, MoreHorizontal, Edit, Trash2, Upload } from 'lucide-react';
import { cn } from '../lib/utils';
import { supabase } from '../lib/supabaseClient';

const MOCK_QUESTIONS = [];

export function Dashboard() {
    const [questions, setQuestions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filterType, setFilterType] = useState('all');
    const [filterDifficulty, setFilterDifficulty] = useState('all');

    // Cascade State
    const [grades, setGrades] = useState([]);
    const [units, setUnits] = useState([]);
    const [microSkills, setMicroSkills] = useState([]);

    const [selectedGrade, setSelectedGrade] = useState('');
    const [selectedUnit, setSelectedUnit] = useState('');
    const [selectedSkill, setSelectedSkill] = useState('');

    // Hierarchy Map for client-side filtering (when DB relations are missing)
    const [hierarchyMap, setHierarchyMap] = useState({});

    useEffect(() => {
        const fetchQuestions = async () => {
            setLoading(true);
            try {
                // 1. Try fetching with deep relationship nesting
                const { data, error } = await supabase
                    .from('questions')
                    .select('*, micro_skills ( *, units ( *, subjects ( * ) ) )')
                    .order('created_at', { ascending: false });

                if (error) throw error;
                setQuestions(data || []);
            } catch (err) {
                console.warn('Deep fetch failed. Using simple fetch + client-side mapping.', err);
                // 2. Fallback: Simple fetch
                const { data } = await supabase
                    .from('questions')
                    .select('*')
                    .order('created_at', { ascending: false });
                setQuestions(data || []);
            } finally {
                setLoading(false);
            }
        };

        const fetchHierarchy = async () => {
            // Fetch independent hierarchy to build a lookup map
            // This allows filtering even if 'questions' table isn't joined to 'micro_skills'
            try {
                const { data } = await supabase
                    .from('micro_skills')
                    .select('id, units ( id, subjects ( id, grade_id ) )');

                if (data) {
                    const map = {};
                    data.forEach(skill => {
                        const unit = Array.isArray(skill.units) ? skill.units[0] : skill.units;
                        const subject = Array.isArray(unit?.subjects) ? unit.subjects[0] : unit?.subjects;

                        map[skill.id] = {
                            unitId: unit?.id,
                            gradeId: subject?.grade_id
                        };
                    });
                    setHierarchyMap(map);
                }
            } catch (e) {
                console.error("Error fetching hierarchy map:", e);
            }
        };

        const fetchGrades = async () => {
            const { data } = await supabase.from('grades').select('*').order('name');
            if (data) setGrades(data);
        };

        fetchQuestions();
        fetchHierarchy();
        fetchGrades();
    }, []);

    // Cascade Handlers
    const handleGradeChange = async (e) => {
        const gradeId = e.target.value;
        setSelectedGrade(gradeId);
        setSelectedUnit('');
        setSelectedSkill('');
        setUnits([]);
        setMicroSkills([]);

        if (gradeId) {
            // Units are linked to Subjects, which are linked to Grades
            // 1. Get Subjects for Grade
            const { data: subjects } = await supabase.from('subjects').select('id').eq('grade_id', gradeId);
            if (subjects && subjects.length > 0) {
                const subjectIds = subjects.map(s => s.id);
                // 2. Get Units for Subjects
                const { data: unitsData } = await supabase.from('units').select('*').in('subject_id', subjectIds).order('name');
                setUnits(unitsData || []);
            } else {
                // Fallback if schema differs (some units might link directly?) - stick to subject path for now based on App.jsx
                setUnits([]);
            }
        }
    };

    const handleUnitChange = async (e) => {
        const unitId = e.target.value;
        setSelectedUnit(unitId);
        setSelectedSkill('');
        setMicroSkills([]);

        if (unitId) {
            const { data } = await supabase.from('micro_skills').select('*').eq('unit_id', unitId).order('name');
            setMicroSkills(data || []);
        }
    };

    // Text Search State
    const [searchTerm, setSearchTerm] = useState('');

    const filteredQuestions = questions.filter(q => {
        // 1. Text Search
        if (searchTerm) {
            const term = searchTerm.toLowerCase();
            const qText = q.question_text || (q.parts && q.parts.find(p => p.type === 'text')?.content) || '';
            const matchesText = qText.toLowerCase().includes(term);
            const matchesId = q.id.toString().toLowerCase().includes(term);
            if (!matchesText && !matchesId) return false;
        }

        // 2. Type Filter
        if (filterType !== 'all' && q.type !== filterType) return false;

        // 3. Difficulty Filter
        if (filterDifficulty !== 'all' && q.difficulty !== filterDifficulty) return false;

        // 4. Hierarchy Filters
        // Use Direct Join Data OR Client-Side Map
        let gradeId, unitId, skillId;

        // Try getting data from join if available
        if (q.micro_skills) {
            const skill = Array.isArray(q.micro_skills) ? q.micro_skills[0] : q.micro_skills;
            const unit = Array.isArray(skill?.units) ? skill.units[0] : skill?.units;
            const subject = Array.isArray(unit?.subjects) ? unit.subjects[0] : unit?.subjects;

            gradeId = subject?.grade_id;
            unitId = skill?.unit_id;
            skillId = q.micro_skill_id;
        } else {
            // Fallback to Map
            const qSkillId = q.micro_skill_id || q.skill_id;
            if (qSkillId && hierarchyMap[qSkillId]) {
                const mapped = hierarchyMap[qSkillId];
                gradeId = mapped.gradeId;
                unitId = mapped.unitId;
                skillId = qSkillId;
            }
        }

        if (selectedGrade && gradeId != selectedGrade) return false;
        if (selectedUnit && unitId != selectedUnit) return false;
        if (selectedSkill && skillId != selectedSkill) return false;

        return true;
    });

    return (
        <div className="space-y-6">
            <header className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900">Questions</h1>
                    <p className="text-slate-500 mt-1">Manage all quiz questions and assessments</p>
                </div>
                <div className="flex gap-2">
                    <Link
                        to="/import"
                        className="bg-white hover:bg-slate-50 text-slate-700 border border-slate-200 px-4 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors shadow-sm"
                    >
                        <Upload className="w-5 h-5" />
                        Import JSON
                    </Link>
                    <Link
                        to="/create"
                        className="bg-brand-600 hover:bg-brand-700 text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors shadow-sm"
                    >
                        <Plus className="w-5 h-5" />
                        Create Question
                    </Link>
                </div>
            </header>

            {/* Filters & Search */}
            <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm space-y-4">
                {/* Text Search & Basic Filters */}
                <div className="flex flex-wrap gap-4 items-center justify-between">
                    <div className="flex items-center gap-2 flex-1 min-w-[300px]">
                        <div className="relative flex-1">
                            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                            <input
                                type="text"
                                placeholder="Search questions..."
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                className="w-full pl-10 pr-4 py-2 border border-slate-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-brand-500/20 focus:border-brand-500 transition-all"
                            />
                        </div>
                    </div>

                    <div className="flex items-center gap-3">
                        <div className="flex items-center gap-2 text-sm text-slate-600 font-medium">
                            <Filter className="w-4 h-4" />
                            Filters:
                        </div>
                        <select
                            className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand-500"
                            value={filterType}
                            onChange={(e) => setFilterType(e.target.value)}
                        >
                            <option value="all">All Types</option>
                            <option value="mcq">MCQ</option>
                            <option value="drag_drop">Drag & Drop</option>
                            <option value="sorting">Sorting</option>
                            <option value="4pics">4 Pics 1 Word</option>
                        </select>

                        <select
                            className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand-500"
                            value={filterDifficulty}
                            onChange={(e) => setFilterDifficulty(e.target.value)}
                        >
                            <option value="all">All Difficulties</option>
                            <option value="Easy">Easy</option>
                            <option value="Medium">Medium</option>
                            <option value="Hard">Hard</option>
                        </select>
                    </div>
                </div>

                {/* Advanced Hierarchy Filters */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 border-t border-slate-100">
                    <select
                        value={selectedGrade}
                        onChange={handleGradeChange}
                        className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand-500"
                    >
                        <option value="">Filter by Grade</option>
                        {grades.map(g => <option key={g.id} value={g.id}>{g.name || g.level}</option>)}
                    </select>

                    <select
                        value={selectedUnit}
                        onChange={handleUnitChange}
                        disabled={!units.length}
                        className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand-500 disabled:bg-slate-50 disabled:text-slate-400"
                    >
                        <option value="">Filter by Unit</option>
                        {units.map(u => <option key={u.id} value={u.id}>{u.name || u.code}</option>)}
                    </select>

                    <select
                        value={selectedSkill}
                        onChange={(e) => setSelectedSkill(e.target.value)}
                        disabled={!microSkills.length}
                        className="border border-slate-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-brand-500 disabled:bg-slate-50 disabled:text-slate-400"
                    >
                        <option value="">Filter by Skill</option>
                        {microSkills.map(s => <option key={s.id} value={s.id}>{s.name || s.code}</option>)}
                    </select>
                </div>
            </div>

            {/* Data Table */}
            <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
                <table className="w-full text-left text-sm">
                    <thead className="bg-slate-50 border-b border-slate-200">
                        <tr>
                            <th className="px-6 py-4 font-semibold text-slate-700">ID</th>
                            <th className="px-6 py-4 font-semibold text-slate-700">Question</th>
                            <th className="px-6 py-4 font-semibold text-slate-700">Type</th>
                            <th className="px-6 py-4 font-semibold text-slate-700">Difficulty</th>
                            <th className="px-6 py-4 font-semibold text-slate-700">Skill Linked</th>
                            <th className="px-6 py-4 font-semibold text-slate-700 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                        {filteredQuestions.map((q) => {
                            // Helper to extract question text from parts
                            const qText = q.parts && Array.isArray(q.parts)
                                ? q.parts.find(p => p.type === 'text')?.content
                                : (q.question_text || 'No Text');

                            return (
                                <tr key={q.id} className="hover:bg-slate-50 transition-colors">
                                    <td className="px-6 py-4 text-slate-500 text-xs font-mono">#{q.id.slice(0, 8)}</td>
                                    <td className="px-6 py-4">
                                        <div className="max-w-xs">
                                            <span className="font-medium text-slate-900 block truncate" title={qText}>{qText}</span>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <span className={cn(
                                            "px-2.5 py-1 rounded-full text-xs font-medium border",
                                            q.type === 'mcq' && "bg-blue-50 text-blue-700 border-blue-100",
                                            q.type === 'dragAndDrop' && "bg-purple-50 text-purple-700 border-purple-100",
                                            q.type === 'sorting' && "bg-orange-50 text-orange-700 border-orange-100",
                                            q.type === 'fillInTheBlank' && "bg-teal-50 text-teal-700 border-teal-100",
                                            q.type === 'fourPicsOneWord' && "bg-pink-50 text-pink-700 border-pink-100",
                                            q.type === 'imageChoice' && "bg-indigo-50 text-indigo-700 border-indigo-100",
                                            (!['mcq', 'dragAndDrop', 'sorting', 'fillInTheBlank', 'fourPicsOneWord', 'imageChoice'].includes(q.type)) && "bg-slate-100 text-slate-700 border-slate-200"
                                        )}>
                                            {q.type?.replace(/([A-Z])/g, ' $1').trim().toUpperCase() || 'UNKNOWN'}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4">
                                        <span className={cn(
                                            "inline-flex items-center gap-1.5",
                                            q.difficulty?.toLowerCase() === 'easy' && "text-green-600",
                                            q.difficulty?.toLowerCase() === 'medium' && "text-yellow-600",
                                            q.difficulty?.toLowerCase() === 'hard' && "text-red-600",
                                        )}>
                                            <span className={cn("w-2 h-2 rounded-full",
                                                q.difficulty?.toLowerCase() === 'easy' ? "bg-green-500" :
                                                    q.difficulty?.toLowerCase() === 'medium' ? "bg-yellow-500" : "bg-red-500"
                                            )} />
                                            {q.difficulty}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 text-slate-500 font-mono text-xs">
                                        {q.micro_skills?.name || q.skill_id}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            <Link to={`/edit/${q.id}`} className="p-2 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-brand-600 transition-colors">
                                                <Edit className="w-4 h-4" />
                                            </Link>
                                            <button className="p-2 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-red-600 transition-colors">
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            );
                        })}
                        {filteredQuestions.length === 0 && (
                            <tr>
                                <td colSpan={6} className="px-6 py-12 text-center text-slate-500">
                                    No questions found matching your filters.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
