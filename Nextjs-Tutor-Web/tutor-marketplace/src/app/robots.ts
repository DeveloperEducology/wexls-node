import { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
    return {
        rules: {
            userAgent: '*',
            allow: '/',
            disallow: ['/dashboard/', '/onboarding/', '/api/'],
        },
        sitemap: 'https://your-domain.com/sitemap.xml',
    }
}
