import StudentAnalyticsClient from './student-analytics-client';

export const metadata = {
    title: 'My Analytics',
    description: 'View your learning progress and performance history.',
};

export default function StudentAnalyticsPage() {
    return <StudentAnalyticsClient />;
}
