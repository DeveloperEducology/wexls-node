import { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
    const baseUrl = 'https://your-domain.com'

    // Real implementation would fetch all tutors from DB
    const tutors = ['john-doe-math', 'jane-smith-physics']

    const tutorUrls = tutors.map((slug) => ({
        url: `${baseUrl}/tutors/${slug}`,
        lastModified: new Date(),
        changeFrequency: 'weekly' as const,
        priority: 0.8,
    }))

    return [
        {
            url: baseUrl,
            lastModified: new Date(),
            changeFrequency: 'daily',
            priority: 1,
        },
        {
            url: `${baseUrl}/search`,
            lastModified: new Date(),
            changeFrequency: 'daily',
            priority: 0.9,
        },
        ...tutorUrls,
    ]
}
