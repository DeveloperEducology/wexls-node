
export type Json =
    | string
    | number
    | boolean
    | null
    | { [key: string]: Json | undefined }
    | Json[]

export interface Database {
    public: {
        Tables: {
            grades: {
                Row: {
                    id: string
                    created_at: string
                    name: string
                    sort_order: number // Changed from level to match screenshot
                    color_hex: string // Added based on screenshot
                }
                Insert: {
                    id?: string
                    created_at?: string
                    name: string
                    sort_order: number
                    color_hex?: string
                }
                Update: {
                    id?: string
                    created_at?: string
                    name?: string
                    sort_order?: number
                    color_hex?: string
                }
            }
            subjects: {
                Row: {
                    id: string
                    created_at: string
                    name: string
                    slug: string
                    icon?: string
                    color?: string
                    description?: string
                }
                Insert: {
                    id?: string
                    created_at?: string
                    name: string
                    slug: string
                    icon?: string
                    color?: string
                    description?: string
                }
                Update: {
                    id?: string
                    created_at?: string
                    name?: string
                    slug?: string
                    icon?: string
                    color?: string
                    description?: string
                }
            }
            units: {
                Row: {
                    id: string
                    created_at: string
                    name: string // Changed from title to name
                    code: string // Added code based on screenshot
                    grade_id: string
                    subject_id: string
                    // order_index removed or optional if not seen, but better keep it optional
                    sort_order?: number
                }
                Insert: {
                    id?: string
                    created_at?: string
                    name: string
                    code: string
                    grade_id: string
                    subject_id: string
                    sort_order?: number
                }
                Update: {
                    id?: string
                    created_at?: string
                    name?: string
                    code?: string
                    grade_id?: string
                    subject_id?: string
                    sort_order?: number
                }
            }
            micro_skills: {
                Row: {
                    id: string
                    created_at: string
                    name: string
                    code: string
                    unit_id: string
                    sort_order?: number // using sort_order or order_index
                }
                Insert: {
                    id?: string
                    created_at?: string
                    name: string
                    code: string
                    unit_id: string
                    sort_order?: number
                }
                Update: {
                    id?: string
                    created_at?: string
                    name?: string
                    code?: string
                    unit_id?: string
                    sort_order?: number
                }
            }
            questions: {
                Row: {
                    id: string
                    created_at: string
                    micro_skill_id: string
                    type: string
                    difficulty: string
                    parts: Json
                    options: Json
                    correct_answer_index?: number
                    correct_answer_indices?: Json
                    correct_answer_text?: string
                    solution: string
                    drag_groups?: Json
                    drag_items?: Json
                }
                Insert: {
                    id?: string
                    created_at?: string
                    micro_skill_id: string
                    type: string
                    difficulty: string
                    parts: Json
                    options: Json
                    correct_answer_index?: number
                    correct_answer_indices?: Json
                    correct_answer_text?: string
                    solution: string
                    drag_groups?: Json
                    drag_items?: Json
                }
                Update: {
                    id?: string
                    created_at?: string
                    micro_skill_id?: string
                    type?: string
                    difficulty?: string
                    parts?: Json
                    options?: Json
                    correct_answer_index?: number
                    correct_answer_indices?: Json
                    correct_answer_text?: string
                    solution?: string
                    drag_groups?: Json
                    drag_items?: Json
                }
            }
            user_progress: {
                Row: {
                    id: string
                    created_at: string
                    user_id: string
                    micro_skill_id: string
                    score: number
                    questions_answered: number
                    time_spent: number
                    last_practiced_at: string
                }
                Insert: {
                    id?: string
                    created_at?: string
                    user_id: string
                    micro_skill_id: string
                    score?: number
                    questions_answered?: number
                    time_spent?: number
                    last_practiced_at?: string
                }
                Update: {
                    id?: string
                    created_at?: string
                    user_id?: string
                    micro_skill_id?: string
                    score?: number
                    questions_answered?: number
                    time_spent?: number
                    last_practiced_at?: string
                }
            }
        }
    }
}
