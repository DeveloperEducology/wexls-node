export default function OnboardingPage() {
    return (
        <div className="container max-w-2xl py-10">
            <div className="space-y-6">
                <div>
                    <h1 className="text-3xl font-bold">Complete your Tutor Profile</h1>
                    <p className="text-muted-foreground">
                        Step 1 of 2: Tell us about your expertise
                    </p>
                </div>

                <form className="space-y-8 border p-6 rounded-lg">
                    <div className="space-y-2">
                        <label className="text-sm font-medium">Bio</label>
                        <textarea
                            className="flex min-h-[80px] w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                            placeholder="Tell students about your teaching style..."
                        />
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-medium">Hourly Rate ($)</label>
                        <input
                            type="number"
                            className="flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                            placeholder="50"
                        />
                    </div>

                    <button className="bg-black text-white hover:bg-gray-800 h-10 px-4 py-2 rounded-md w-full">
                        Continue to Verification
                    </button>
                </form>
            </div>
        </div>
    )
}
