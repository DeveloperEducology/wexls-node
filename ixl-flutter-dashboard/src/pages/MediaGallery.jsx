import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabaseClient';
import { uploadToR2 } from '../lib/r2';
import { Search, Plus, Copy, Check, Upload, Trash2, ExternalLink, Image as ImageIcon, Filter, X, CloudRain, Database, Loader2, AlertCircle } from 'lucide-react';
import { cn } from '../lib/utils';

export function MediaGallery() {
    const [images, setImages] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterType, setFilterType] = useState('all'); // all, uploaded, question
    const [showAddModal, setShowAddModal] = useState(false);

    // Fetch Images
    useEffect(() => {
        fetchImages();
    }, []);

    const fetchImages = async () => {
        setLoading(true);
        try {
            // 1. Fetch from Questions (Usage)
            const { data: questions, error } = await supabase
                .from('questions')
                .select('id, type, parts, options, drag_groups');

            if (error) throw error;

            const extractedImages = new Map();

            questions.forEach(q => {
                // Helper to add image
                const addImg = (url, context) => {
                    if (!url || typeof url !== 'string' || !url.startsWith('http')) return;
                    if (!extractedImages.has(url)) {
                        extractedImages.set(url, {
                            url,
                            sources: [],
                            type: 'question_usage'
                        });
                    }
                    extractedImages.get(url).sources.push({ id: q.id, type: q.type, context });
                };

                // Check Parts
                if (q.parts && Array.isArray(q.parts)) {
                    q.parts.forEach(p => {
                        if (p.type === 'image' && p.imageUrl) addImg(p.imageUrl, 'Part');
                        // Some parts might have content as url if type is image but mapped differently
                        if (p.type === 'image' && p.content) addImg(p.content, 'Part');
                    });
                }

                // Check Options (Image Choice)
                if (q.type === 'imageChoice' && q.options && Array.isArray(q.options)) {
                    q.options.forEach(opt => addImg(opt, 'Option'));
                }

                // Check Drag Groups
                if (q.drag_groups && Array.isArray(q.drag_groups)) {
                    q.drag_groups.forEach(g => {
                        if (g.image) addImg(g.image, 'Drag Group');
                    });
                }
            });

            // 2. Fetch from Storage Bucket (if exists) - Optional enhancement
            // We'll skip this for now as we don't know the bucket name, 
            // but we can list files if we knew it. 
            // For now, we rely on the extracted unique URLs.

            setImages(Array.from(extractedImages.values()));

        } catch (err) {
            console.error("Error fetching media:", err);
        } finally {
            setLoading(false);
        }
    };

    const handleCopy = (url) => {
        navigator.clipboard.writeText(url);
        // You could add a toast here
        alert("URL copied to clipboard!");
    };

    const filteredImages = images.filter(img => {
        if (searchTerm && !img.url.toLowerCase().includes(searchTerm.toLowerCase())) return false;
        return true;
    });

    return (
        <div className="h-screen flex flex-col bg-slate-50">
            {/* Header */}
            <div className="bg-white border-b border-slate-200 px-6 py-4 flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-slate-900">Media Gallery</h1>
                    <p className="text-sm text-slate-500">Manage and view all images used in questions.</p>
                </div>
                <button
                    onClick={() => setShowAddModal(true)}
                    className="bg-brand-600 hover:bg-brand-700 text-white px-4 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors"
                >
                    <Plus className="w-4 h-4" />
                    Add Media
                </button>
            </div>

            {/* Toolbar */}
            <div className="px-6 py-4 flex items-center gap-4">
                <div className="relative flex-1 max-w-md">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                    <input
                        type="text"
                        placeholder="Search URL..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-9 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-brand-500 focus:border-brand-500"
                    />
                </div>
                <div className="flex items-center gap-2 text-sm text-slate-600">
                    <Filter className="w-4 h-4" />
                    <span>{filteredImages.length} images found</span>
                </div>
            </div>

            {/* Gallery Grid */}
            <div className="flex-1 overflow-y-auto p-6">
                {loading ? (
                    <div className="text-center py-20 text-slate-500">Loading media...</div>
                ) : filteredImages.length === 0 ? (
                    <div className="text-center py-20 text-slate-500">No images found matching your search.</div>
                ) : (
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                        {filteredImages.map((img, idx) => (
                            <div key={idx} className="group relative bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-all overflow-hidden flex flex-col">
                                <div className="aspect-square bg-slate-100 relative overflow-hidden">
                                    <img
                                        src={img.url}
                                        alt="Gallery Item"
                                        className="w-full h-full object-cover transition-transform group-hover:scale-105"
                                        loading="lazy"
                                        onError={(e) => {
                                            e.target.src = 'https://placehold.co/400x400?text=Broken+Image';
                                            e.target.className = "w-full h-full object-cover opacity-50";
                                        }}
                                    />
                                    {/* Overlay Actions */}
                                    <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                        <button
                                            onClick={() => handleCopy(img.url)}
                                            className="p-2 bg-white rounded-full hover:bg-slate-100 text-slate-900 transition-colors"
                                            title="Copy URL"
                                        >
                                            <Copy className="w-4 h-4" />
                                        </button>
                                        <a
                                            href={img.url}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            className="p-2 bg-white rounded-full hover:bg-slate-100 text-slate-900 transition-colors"
                                            title="Open Original"
                                        >
                                            <ExternalLink className="w-4 h-4" />
                                        </a>
                                    </div>
                                </div>
                                <div className="p-3">
                                    <div className="text-xs text-slate-500 truncate mb-1" title={img.url}>{img.url}</div>
                                    <div className="flex items-center justify-between">
                                        <span className="text-[10px] font-medium bg-slate-100 text-slate-600 px-2 py-0.5 rounded-full">
                                            Used in {img.sources.length} Qs
                                        </span>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* Add Media Modal */}
            {showAddModal && (
                <AddMediaModal
                    onClose={() => setShowAddModal(false)}
                    onUploaded={() => {
                        fetchImages();
                        setShowAddModal(false);
                    }}
                />
            )}
        </div>
    );
}

function AddMediaModal({ onClose, onUploaded }) {
    const [tab, setTab] = useState('url'); // url, upload
    const [url, setUrl] = useState('');
    const [uploading, setUploading] = useState(false);
    const [error, setError] = useState(null);
    const [provider, setProvider] = useState('supabase'); // supabase, r2

    // Check if R2 is configured
    const isR2Configured = import.meta.env.VITE_R2_ACCOUNT_ID && import.meta.env.VITE_R2_BUCKET_NAME;

    useEffect(() => {
        if (isR2Configured) setProvider('r2');
    }, [isR2Configured]);

    const handleUrlSubmit = () => {
        if (url) {
            onUploaded();
        }
    };

    const handleFileUpload = async (e) => {
        const file = e.target.files[0];
        if (!file) return;

        setUploading(true);
        setError(null);
        setUrl('');

        try {
            // Standardize filename
            const fileExt = file.name.split('.').pop();
            const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${fileExt}`;

            let publicUrl = '';

            if (provider === 'r2') {
                const path = fileName;
                publicUrl = await uploadToR2(file, path);
            } else {
                // Supabase Storage
                const filePath = `${fileName}`;
                const { data, error: uploadError } = await supabase.storage
                    .from('images') // Assumption!
                    .upload(filePath, file);

                if (uploadError) throw uploadError;

                const { data: { publicUrl: sbUrl } } = supabase.storage
                    .from('images')
                    .getPublicUrl(filePath);
                publicUrl = sbUrl;
            }

            setUrl(publicUrl);

        } catch (err) {
            console.error("Upload failed:", err);
            setError(err.message || "Upload failed. Please check your connection and configuration.");
        } finally {
            setUploading(false);
            e.target.value = null; // Reset input
        }
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden animate-in fade-in zoom-in duration-200">
                <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
                    <h3 className="font-bold text-lg text-slate-900">Add New Media</h3>
                    <button onClick={onClose}><X className="w-5 h-5 text-slate-400 hover:text-slate-600" /></button>
                </div>

                <div className="p-6 space-y-4">
                    <div className="flex gap-2 p-1 bg-slate-100 rounded-lg">
                        <button
                            onClick={() => setTab('url')}
                            className={cn("flex-1 py-2 text-sm font-medium rounded-md transition-all", tab === 'url' ? "bg-white text-slate-900 shadow-sm" : "text-slate-500 hover:text-slate-700")}
                        >
                            External URL
                        </button>
                        <button
                            onClick={() => setTab('upload')}
                            className={cn("flex-1 py-2 text-sm font-medium rounded-md transition-all", tab === 'upload' ? "bg-white text-slate-900 shadow-sm" : "text-slate-500 hover:text-slate-700")}
                        >
                            Upload File
                        </button>
                    </div>

                    {tab === 'url' ? (
                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-slate-700 mb-1">Image URL</label>
                                <input
                                    value={url}
                                    onChange={(e) => setUrl(e.target.value)}
                                    placeholder="https://example.com/image.png"
                                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm"
                                />
                            </div>
                            {url && (
                                <div className="aspect-video bg-slate-100 rounded-lg overflow-hidden border border-slate-200">
                                    <img src={url} className="w-full h-full object-contain" alt="Preview" onError={(e) => e.target.style.display = 'none'} />
                                </div>
                            )}
                        </div>
                    ) : (
                        <div className="space-y-4">
                            {/* Provider Toggle */}
                            <div className="flex items-center gap-4 mb-2">
                                <label className="flex items-center gap-2 text-sm cursor-pointer">
                                    <input
                                        type="radio"
                                        name="provider"
                                        checked={provider === 'supabase'}
                                        onChange={() => setProvider('supabase')}
                                        className="text-brand-600 focus:ring-brand-500"
                                    />
                                    <span className="flex items-center gap-1.5"><Database className="w-4 h-4 text-slate-500" /> Supabase</span>
                                </label>
                                <label className="flex items-center gap-2 text-sm cursor-pointer">
                                    <input
                                        type="radio"
                                        name="provider"
                                        checked={provider === 'r2'}
                                        onChange={() => setProvider('r2')}
                                        className="text-brand-600 focus:ring-brand-500"
                                    />
                                    <span className="flex items-center gap-1.5"><CloudRain className="w-4 h-4 text-slate-500" /> R2 Storage</span>
                                </label>
                            </div>

                            {!isR2Configured && provider === 'r2' && (
                                <div className="text-xs text-amber-600 bg-amber-50 px-3 py-2 rounded border border-amber-200 flex items-start gap-2">
                                    <AlertCircle className="w-4 h-4 mt-0.5 shrink-0" />
                                    <span>Warning: R2 credentials are missing in <code>.env</code>. Uploads will likely fail.</span>
                                </div>
                            )}

                            {error && (
                                <div className="text-sm text-red-600 bg-red-50 px-4 py-3 rounded-lg border border-red-200 flex items-start gap-2">
                                    <AlertCircle className="w-5 h-5 mt-0.5 shrink-0" />
                                    <div>
                                        <p className="font-semibold">Upload Failed</p>
                                        <p className="text-xs mt-1 opacity-90">{error}</p>
                                    </div>
                                </div>
                            )}

                            <div className={cn(
                                "border-2 border-dashed rounded-xl p-8 text-center transition-all cursor-pointer relative",
                                uploading ? "border-brand-300 bg-brand-50 cursor-wait" : "border-slate-300 hover:bg-slate-50 hover:border-slate-400"
                            )}>
                                <input
                                    type="file"
                                    accept="image/*"
                                    onChange={handleFileUpload}
                                    className="absolute inset-0 opacity-0 cursor-pointer disabled:cursor-not-allowed"
                                    disabled={uploading}
                                />
                                {uploading ? (
                                    <div className="flex flex-col items-center justify-center py-4">
                                        <Loader2 className="w-8 h-8 text-brand-600 animate-spin mb-3" />
                                        <p className="text-sm font-medium text-brand-700">Uploading to {provider === 'r2' ? 'R2' : 'Supabase'}...</p>
                                        <p className="text-xs text-brand-500 mt-1">Please wait...</p>
                                    </div>
                                ) : (
                                    <>
                                        <div className="w-12 h-12 bg-brand-50 rounded-full flex items-center justify-center text-brand-600 mx-auto mb-3">
                                            <Upload className="w-6 h-6" />
                                        </div>
                                        <p className="text-sm font-medium text-slate-900">Click to upload image</p>
                                        <p className="text-xs text-slate-500 mt-1">SVG, PNG, JPG, GIF</p>
                                    </>
                                )}
                            </div>

                            {url && !uploading && !error && (
                                <div className="animate-in fade-in slide-in-from-top-2 duration-300">
                                    <p className="text-xs font-medium text-green-600 mb-2 flex items-center gap-1">
                                        <Check className="w-3 h-3" /> Uploaded successfully!
                                    </p>
                                    <div className="flex items-center gap-2">
                                        <input value={url} readOnly className="flex-1 text-xs bg-slate-50 border border-slate-200 rounded px-2 py-1 select-all" />
                                        <button onClick={() => {
                                            navigator.clipboard.writeText(url);
                                            // You could add a toast here
                                        }} className="text-xs bg-slate-200 hover:bg-slate-300 px-3 py-1.5 rounded font-medium transition-colors">Copy</button>
                                    </div>
                                    <div className="mt-3 aspect-video bg-slate-100 rounded-lg overflow-hidden border border-slate-200">
                                        <img src={url} className="w-full h-full object-contain" alt="Uploaded Preview" />
                                    </div>
                                </div>
                            )}
                        </div>
                    )}
                </div>

                <div className="p-4 bg-slate-50 border-t border-slate-100 flex justify-end gap-2">
                    <button onClick={onClose} className="px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-900">Close</button>
                    {url && (
                        <button onClick={() => {
                            navigator.clipboard.writeText(url);
                            onClose();
                        }} className="px-4 py-2 text-sm font-medium bg-brand-600 text-white rounded-lg hover:bg-brand-700">
                            Copy & Close
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
}
