'use client';

import { useMemo, useRef, useState } from 'react';
import QuestionParts from './QuestionParts';
import styles from './ShadeGridRenderer.module.css';

function parseFinite(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function normalizeColor(value, fallback) {
  const raw = String(value ?? '').trim();
  if (!raw) return fallback;
  const safeColorPattern = /^(#[0-9a-fA-F]{3,8}|rgba?\([^)]{1,64}\)|hsla?\([^)]{1,64}\)|[a-zA-Z]{3,24})$/;
  return safeColorPattern.test(raw) ? raw : fallback;
}

function parseFraction(value) {
  const text = String(value ?? '').trim();
  const match = text.match(/^(-?\d+)\s*\/\s*(\d+)$/);
  if (!match) return null;
  const numerator = Number(match[1]);
  const denominator = Number(match[2]);
  if (!Number.isFinite(numerator) || !Number.isFinite(denominator) || denominator <= 0) return null;
  return { numerator, denominator };
}

function extractFractionFromParts(parts) {
  const list = Array.isArray(parts) ? parts : [];
  for (const part of list) {
    const content = String(part?.content ?? '');
    const fraction = parseFraction(content);
    if (fraction) return fraction;
    const embedded = content.match(/(-?\d+)\s*\/\s*(\d+)/);
    if (embedded) {
      return {
        numerator: Number(embedded[1]),
        denominator: Number(embedded[2]),
      };
    }
  }
  return null;
}

function normalizeSelected(answer) {
  if (Array.isArray(answer)) return new Set(answer.map((v) => String(v)));
  if (answer && typeof answer === 'object' && Array.isArray(answer.selected)) {
    return new Set(answer.selected.map((v) => String(v)));
  }
  return new Set();
}

function normalizeAngle(angle) {
  const twoPi = Math.PI * 2;
  return ((angle % twoPi) + twoPi) % twoPi;
}

function describeSectorPath(cx, cy, radius, startAngle, endAngle) {
  const x1 = cx + radius * Math.cos(startAngle);
  const y1 = cy + radius * Math.sin(startAngle);
  const x2 = cx + radius * Math.cos(endAngle);
  const y2 = cy + radius * Math.sin(endAngle);
  const largeArcFlag = endAngle - startAngle > Math.PI ? 1 : 0;
  return `M ${cx} ${cy} L ${x1} ${y1} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${x2} ${y2} Z`;
}

function resolveGrid(question) {
  const config = question?.adaptiveConfig || {};
  const explicitRows = parseFinite(config.gridRows);
  const explicitCols = parseFinite(config.gridCols);
  const orientation = String(
    config.orientation || config.gridOrientation || config.barOrientation || 'vertical'
  ).toLowerCase() === 'horizontal'
    ? 'horizontal'
    : 'vertical';
  const gridMode = String(config.gridMode || 'auto').toLowerCase();

  const fraction = (
    parseFraction(question?.correctAnswerText) ||
    extractFractionFromParts(question?.parts) ||
    (parseFinite(config.numerator) != null && parseFinite(config.denominator) != null
      ? { numerator: parseFinite(config.numerator), denominator: parseFinite(config.denominator) }
      : null)
  );

  let rows = explicitRows;
  let cols = explicitCols;

  const denominator = parseFinite(config.denominator) ?? fraction?.denominator ?? null;
  const shouldUseFractionBar = (
    gridMode === 'fractionbar' ||
    (gridMode === 'auto' && denominator && denominator > 1 && denominator <= 20)
  );

  if (shouldUseFractionBar && denominator) {
    if (orientation === 'horizontal') {
      rows = denominator;
      cols = 1;
    } else {
      rows = 1;
      cols = denominator;
    }
  } else if (!rows || !cols) {
    const denominator = parseFinite(config.denominator) ?? fraction?.denominator ?? null;
    if (denominator === 100) {
      rows = 10;
      cols = 10;
    } else {
      rows = 10;
      cols = 10;
    }
  }

  rows = Math.max(1, Math.min(20, Math.floor(rows)));
  cols = Math.max(1, Math.min(20, Math.floor(cols)));
  const modelType = String(config.modelType || config.visualModel || config.shapeModel || '').toLowerCase();
  const isPieModel = modelType === 'pie' || modelType === 'fractioncircle' || modelType === 'circlefraction';
  const totalCells = isPieModel
    ? Math.max(2, Math.min(36, Math.floor(parseFinite(config.segments) ?? denominator ?? (rows * cols))))
    : (rows * cols);

  const explicitTarget = parseFinite(config.targetShaded);
  const numericCorrect = parseFinite(question?.correctAnswerText);
  const fractionTarget = fraction
    ? Math.round((fraction.numerator / fraction.denominator) * totalCells)
    : null;

  const targetRaw = explicitTarget ?? fractionTarget ?? numericCorrect ?? 0;
  const target = Math.max(0, Math.min(totalCells, Math.round(targetRaw)));
  const isBarModel = (rows === 1 && cols >= 5) || (cols === 1 && rows >= 5);
  const shape = String(config.cellShape || config.shape || 'square').toLowerCase() === 'circle'
    ? 'circle'
    : 'square';
  const fillColor = normalizeColor(config.fillColor || config.shadedColor || config.selectedColor, '#b2a0f0');
  const lineColor = normalizeColor(config.lineColor || config.strokeColor || config.borderColor, '#7561ea');
  const baseColor = normalizeColor(config.baseColor || config.unshadedColor || config.backgroundColor, '#ffffff');
  const gap = Math.max(0, Math.min(6, Math.floor(parseFinite(config.cellGap) ?? 0)));

  return {
    rows,
    cols,
    target,
    totalCells,
    isBarModel,
    orientation,
    shape,
    fillColor,
    lineColor,
    baseColor,
    gap,
    isPieModel,
  };
}

export default function ShadeGridRenderer({
  question,
  userAnswer,
  onAnswer,
  onSubmit,
  isAnswered,
}) {
  const {
    rows,
    cols,
    target,
    totalCells,
    isBarModel,
    orientation,
    shape,
    fillColor,
    lineColor,
    baseColor,
    gap,
    isPieModel,
  } = resolveGrid(question);
  const selected = normalizeSelected(userAnswer);
  const [isPainting, setIsPainting] = useState(false);
  const [paintMode, setPaintMode] = useState(null); // add | remove
  const gridRef = useRef(null);
  const visitedRef = useRef(new Set());

  const cellIds = useMemo(
    () => Array.from({ length: totalCells }, (_, i) => String(i)),
    [totalCells]
  );

  const emitSelection = (nextSet) => {
    onAnswer({
      selected: Array.from(nextSet),
      count: nextSet.size,
    });
  };

  const applyToCell = (cellId, modeOverride = null) => {
    if (isAnswered || cellId == null) return;
    if (visitedRef.current.has(cellId)) return;
    visitedRef.current.add(cellId);

    const next = new Set(selected);
    const mode = modeOverride || paintMode || (next.has(cellId) ? 'remove' : 'add');
    if (mode === 'add') next.add(cellId);
    else next.delete(cellId);
    emitSelection(next);
    setPaintMode(mode);
  };

  const getPieSectorIdFromPoint = (clientX, clientY) => {
    const svg = gridRef.current;
    if (!svg) return null;
    const rect = svg.getBoundingClientRect();
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    const x = clientX - cx;
    const y = clientY - cy;
    const distance = Math.sqrt((x * x) + (y * y));
    const radius = Math.min(rect.width, rect.height) / 2;
    if (distance > radius) return null;

    const sectorCount = Math.max(2, totalCells);
    const angle = normalizeAngle(Math.atan2(y, x) + (Math.PI / 2));
    const sector = Math.min(sectorCount - 1, Math.floor((angle / (Math.PI * 2)) * sectorCount));
    return String(sector);
  };

  const getCellIdFromPoint = (clientX, clientY) => {
    const grid = gridRef.current;
    if (!grid) return null;
    const rect = grid.getBoundingClientRect();
    if (clientX < rect.left || clientX > rect.right || clientY < rect.top || clientY > rect.bottom) return null;

    const col = Math.min(cols - 1, Math.max(0, Math.floor(((clientX - rect.left) / rect.width) * cols)));
    const row = Math.min(rows - 1, Math.max(0, Math.floor(((clientY - rect.top) / rect.height) * rows)));
    return String((row * cols) + col);
  };

  const handleGridPointerDown = (event) => {
    if (isAnswered) return;
    event.preventDefault();
    gridRef.current?.setPointerCapture?.(event.pointerId);
    visitedRef.current = new Set();
    const cellId = isPieModel
      ? getPieSectorIdFromPoint(event.clientX, event.clientY)
      : getCellIdFromPoint(event.clientX, event.clientY);
    if (cellId == null) return;
    setIsPainting(true);
    const nextMode = selected.has(cellId) ? 'remove' : 'add';
    applyToCell(cellId, nextMode);
  };

  const handleGridPointerMove = (event) => {
    if (!isPainting || isAnswered) return;
    const cellId = isPieModel
      ? getPieSectorIdFromPoint(event.clientX, event.clientY)
      : getCellIdFromPoint(event.clientX, event.clientY);
    if (cellId == null) return;
    applyToCell(cellId);
  };

  const handleGridPointerEnd = () => {
    setIsPainting(false);
    setPaintMode(null);
    visitedRef.current = new Set();
  };

  return (
    <div className={styles.container}>
      <div className={styles.questionCard}>
        <div className={styles.questionContent}>
          <QuestionParts parts={question.parts} />
          <p className={styles.hintText}>Click and drag to shade.</p>
        </div>

        {isPieModel ? (
          <svg
            ref={gridRef}
            className={styles.pieSvg}
            viewBox="0 0 240 240"
            onPointerDown={handleGridPointerDown}
            onPointerMove={handleGridPointerMove}
            onPointerUp={handleGridPointerEnd}
            onPointerCancel={handleGridPointerEnd}
            onPointerLeave={handleGridPointerEnd}
            role="img"
            aria-label={`Fraction circle with ${totalCells} equal parts`}
          >
            {Array.from({ length: totalCells }, (_, index) => {
              const start = (-Math.PI / 2) + ((Math.PI * 2 * index) / totalCells);
              const end = (-Math.PI / 2) + ((Math.PI * 2 * (index + 1)) / totalCells);
              const id = String(index);
              return (
                <path
                  key={id}
                  d={describeSectorPath(120, 120, 108, start, end)}
                  fill={selected.has(id) ? fillColor : baseColor}
                  stroke={lineColor}
                  strokeWidth="1.5"
                />
              );
            })}
            <circle cx="120" cy="120" r="108" fill="none" stroke={lineColor} strokeWidth="2" />
          </svg>
        ) : (
          <div
            ref={gridRef}
            className={`${styles.grid} ${isBarModel ? styles.barGrid : ''} ${isBarModel && orientation === 'horizontal' ? styles.barHorizontal : ''}`}
            style={{
              '--rows': rows,
              '--cols': cols,
              '--grid-line-color': lineColor,
              '--grid-base-color': baseColor,
              '--grid-fill-color': fillColor,
              '--cell-gap': `${gap}px`,
              '--cell-inset': `${Math.max(1, gap + 1)}px`,
            }}
            onPointerDown={handleGridPointerDown}
            onPointerMove={handleGridPointerMove}
            onPointerUp={handleGridPointerEnd}
            onPointerCancel={handleGridPointerEnd}
            onPointerLeave={handleGridPointerEnd}
          >
            {cellIds.map((cellId) => (
              <div
                key={cellId}
                className={`${styles.cell} ${shape === 'circle' ? styles.cellCircle : ''} ${selected.has(cellId) ? styles.shaded : ''}`}
                aria-hidden="true"
              />
            ))}
          </div>
        )}

        <div className={styles.counterRow}>
          <span>Shaded: {selected.size}</span>
          <span>Target: {target}</span>
        </div>

        {!isAnswered && (
          <button className={styles.submitButton} onClick={() => onSubmit()}>
            Submit
          </button>
        )}
      </div>
    </div>
  );
}
