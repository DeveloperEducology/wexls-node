
"use client";

import 'katex/dist/katex.min.css';
import Latex from 'react-latex-next';

interface MathTextProps {
    content: string;
}

export function MathText({ content }: MathTextProps) {
    // Wrap delimiters to match format, if necessary. Usually content is already formatted.
    // Standard delimiters: $ inline $, $$ block $$
    return (
        <span className="font-serif text-lg mx-1">
            <Latex>{content}</Latex>
        </span>
    );
}
