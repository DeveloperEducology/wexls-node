import GradeCard from '@/components/GradeCard';
import styles from '@/app/page.module.css';
import { getHomeGradesData } from '@/lib/curriculum/server';

export default async function GradesDisplay() {
    const grades = await getHomeGradesData();

    return (
        <div className={styles.gradesGrid}>
            {grades.map((grade, index) => (
                <GradeCard
                    key={grade.id}
                    grade={grade}
                    index={index}
                    subjects={grade.subjects || []}
                />
            ))}
        </div>
    );
}

export function GradesSkeleton() {
    return (
        <div className={styles.gradesGrid}>
            {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className={styles.gradeCardSkeleton} />
            ))}
        </div>
    );
}
