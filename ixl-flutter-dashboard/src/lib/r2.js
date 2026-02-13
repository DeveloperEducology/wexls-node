import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

// NOTE: Exposing Secret Keys in the frontend is not recommended for public production apps.
// For a secure internal dashboard, ensure this is only accessible to trusted admins.

const accountId = import.meta.env.VITE_R2_ACCOUNT_ID;
const accessKeyId = import.meta.env.VITE_R2_ACCESS_KEY_ID;
const secretAccessKey = import.meta.env.VITE_R2_SECRET_ACCESS_KEY;

let r2Client = null;

if (accountId && accessKeyId && secretAccessKey) {
    r2Client = new S3Client({
        region: "auto",
        endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
        credentials: {
            accessKeyId,
            secretAccessKey,
        },
    });
}

export const uploadToR2 = async (file, path) => {
    if (!r2Client) {
        throw new Error("R2 Client not configured. Please check .env variables.");
    }

    const bucketName = import.meta.env.VITE_R2_BUCKET_NAME;
    const publicUrl = import.meta.env.VITE_R2_PUBLIC_URL;

    if (!bucketName) throw new Error("VITE_R2_BUCKET_NAME is missing.");

    // Remove leading slash from path to prevent empty 'folders' or double slash issues
    const sanitizedPath = path.replace(/^\/+/, '');

    const arrayBuffer = await file.arrayBuffer();

    const command = new PutObjectCommand({
        Bucket: bucketName,
        Key: sanitizedPath,
        Body: new Uint8Array(arrayBuffer),
        ContentType: file.type,
    });

    try {
        console.log(`[R2] Attempting upload to: https://${import.meta.env.VITE_R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${bucketName}/${sanitizedPath}`);
        const data = await r2Client.send(command);
        // Construct public URL
        if (publicUrl) {
            // Ensure standard URL formatting
            const baseUrl = publicUrl.endsWith('/') ? publicUrl : `${publicUrl}/`;
            const finalPath = sanitizedPath;
            return `${baseUrl}${finalPath}`;
        }
        return `Verified Upload: ${sanitizedPath} (Configure VITE_R2_PUBLIC_URL to view)`;
    } catch (error) {
        console.error("R2 Upload Error:", error);
        if (error.name === 'TypeError' && error.message === 'Failed to fetch') {
            throw new Error("Network error (Failed to fetch). This is most likely a CORS issue. Please check your R2 Bucket CORS settings in Cloudflare.");
        }
        throw error;
    }
};
