from pathlib import Path

OUT = Path('output/pdf/app-summary-one-page.pdf')
OUT.parent.mkdir(parents=True, exist_ok=True)

# Letter page (612 x 792 points)
WIDTH, HEIGHT = 612, 792
MARGIN_X = 54

lines = [
    ("F2", 18, 54, 756, "IIXL Next.js App - One-Page Summary"),

    ("F2", 12, 54, 730, "What it is"),
    ("F1", 10, 54, 715, "A Next.js educational web app modeled after IXL-style learning flows for school students."),
    ("F1", 10, 54, 702, "It lets users pick a grade, browse subject skills, and practice question types with live feedback."),

    ("F2", 12, 54, 680, "Who it's for"),
    ("F1", 10, 54, 665, "Primary persona: school students (Class 1 to Class 9) practicing Math/English/Science microskills."),
    ("F1", 10, 54, 652, "Secondary audience shown in copy/metadata: educators and parents. (Auth roles: Not found in repo.)"),

    ("F2", 12, 54, 630, "What it does"),
    ("F1", 10, 66, 615, "- Shows a landing page with grade cards and subject entry points."),
    ("F1", 10, 66, 602, "- Computes per-subject skill counts from in-repo curriculum data."),
    ("F1", 10, 66, 589, "- Renders a skills catalog by grade + subject with unit grouping in 3 columns."),
    ("F1", 10, 66, 576, "- Opens a practice experience per microskill route with mixed question types."),
    ("F1", 10, 66, 563, "- Tracks SmartScore, streak, tokens, challenge stages, and elapsed time in client state."),
    ("F1", 10, 66, 550, "- Validates answers and shows immediate correctness + solution feedback."),

    ("F2", 12, 54, 528, "How it works (repo evidence only)"),
    ("F1", 10, 66, 513, "- Routing/UI components: App Router pages at /, /skills/[gradeId]/[subjectSlug], /practice/[microskillId]."),
    ("F1", 10, 66, 500, "- Data layer: src/data/curriculum.js exports grade/subject/unit/microskill arrays + helper selectors."),
    ("F1", 10, 66, 487, "- Practice engine: page-level state + validateAnswer logic + QuestionRenderer type dispatch map."),
    ("F1", 10, 66, 474, "- Service/backend boundary: API routes, DB integration, auth, and persistence are Not found in repo."),

    ("F2", 12, 54, 452, "How to run (minimal)"),
    ("F1", 10, 66, 437, "1. From repo root, install dependencies: npm install"),
    ("F1", 10, 66, 424, "2. Start dev server: npm run dev"),
    ("F1", 10, 66, 411, "3. Open http://localhost:3000"),
    ("F1", 10, 66, 398, "4. Optional production check: npm run build && npm run start"),
    ("F1", 10, 66, 385, "Node.js version requirement: Not found in repo."),
    ("F1", 10, 66, 372, "Environment variables/config secrets: Not found in repo."),

    ("F1", 9, 54, 346, "Evidence files: src/app/page.js, src/app/skills/[gradeId]/[subjectSlug]/page.js,"),
    ("F1", 9, 54, 335, "src/app/practice/[microskillId]/page.js, src/components/practice/QuestionRenderer.js,"),
    ("F1", 9, 54, 324, "src/data/curriculum.js, package.json, README.md"),
]

def escape_pdf_text(s: str) -> str:
    return s.replace('\\', '\\\\').replace('(', '\\(').replace(')', '\\)')

content_parts = []
for font, size, x, y, text in lines:
    text_escaped = escape_pdf_text(text)
    content_parts.append(f"BT /{font} {size} Tf 1 0 0 1 {x} {y} Tm ({text_escaped}) Tj ET")

content_stream = "\n".join(content_parts).encode('latin-1', errors='replace')

objects = []
objects.append(b"1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n")
objects.append(b"2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n")
objects.append(
    (
        f"3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {WIDTH} {HEIGHT}] "
        f"/Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>\nendobj\n"
    ).encode('latin-1')
)
objects.append(b"4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n")
objects.append(b"5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n")
objects.append(
    b"6 0 obj\n<< /Length " + str(len(content_stream)).encode('ascii') + b" >>\nstream\n" + content_stream + b"\nendstream\nendobj\n"
)

pdf = bytearray()
pdf.extend(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")

offsets = [0]
for obj in objects:
    offsets.append(len(pdf))
    pdf.extend(obj)

xref_start = len(pdf)
pdf.extend(f"xref\n0 {len(objects)+1}\n".encode('ascii'))
pdf.extend(b"0000000000 65535 f \n")
for i in range(1, len(objects)+1):
    pdf.extend(f"{offsets[i]:010d} 00000 n \n".encode('ascii'))

pdf.extend(
    f"trailer\n<< /Size {len(objects)+1} /Root 1 0 R >>\nstartxref\n{xref_start}\n%%EOF\n".encode('ascii')
)

OUT.write_bytes(pdf)
print(OUT)
