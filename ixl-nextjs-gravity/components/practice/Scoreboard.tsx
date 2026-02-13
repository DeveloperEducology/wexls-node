
"use client";

import { motion } from "framer-motion";

interface ScoreboardProps {
    questionsAnswered: number;
    timeElapsed: string;
    smartScore: number;
}

export function Scoreboard({ questionsAnswered, timeElapsed, smartScore }: ScoreboardProps) {
    return (
        <div className="w-full lg:w-48 bg-white border border-slate-200 rounded-lg shadow-sm sticky top-4">
            <div className="divide-y divide-slate-100">
                <div className="p-4 bg-green-500 rounded-t-lg">
                    <h4 className="text-white text-xs uppercase font-bold tracking-wider text-center">Questions Answered</h4>
                    <div className="text-3xl font-extrabold text-white text-center mt-1">{questionsAnswered}</div>
                </div>

                <div className="p-4 bg-blue-500">
                    <h4 className="text-white text-xs uppercase font-bold tracking-wider text-center">Time Elapsed</h4>
                    <div className="text-2xl font-bold text-white text-center mt-1 tabular-nums">{timeElapsed}</div>
                </div>

                <div className="p-4 bg-orange-500 rounded-b-lg relative overflow-hidden">
                    <motion.div
                        className="absolute inset-x-0 bottom-0 bg-white/20"
                        initial={{ height: "0%" }}
                        animate={{ height: `${smartScore}%` }}
                        transition={{ duration: 1 }}
                    />
                    <h4 className="text-white text-xs uppercase font-bold tracking-wider text-center relative z-10">SmartScore</h4>
                    <div className="text-4xl font-extrabold text-white text-center mt-1 relative z-10">{smartScore}</div>
                    <div className="text-[10px] text-white/80 text-center mt-1 relative z-10">out of 100</div>
                </div>
            </div>
        </div>
    );
}
