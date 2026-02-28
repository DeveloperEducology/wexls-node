import app from '../../../../backend/server';

export default async function handler(req, res) {
    // Trim the Next.js API route prefix so Express routes match correctly
    if (req.url.startsWith('/api/express')) {
        req.url = req.url.replace('/api/express', '');
    } else if (req.url.startsWith('/backend-api')) {
        req.url = req.url.replace('/backend-api', '');
    }

    if (!req.url.startsWith('/api')) {
        req.url = '/api' + req.url;
    }

    req.originalUrl = req.url;

    return app(req, res);
}

export const config = {
    api: {
        // Disable Next.js body parser because Express apps natively handle parsing bodies!
        // Without this Express will hang while trying to read a consumed stream.
        bodyParser: false,
        externalResolver: true, // Tells Next.js to not warn about unresolved promises when Express handles the route.
    },
};
