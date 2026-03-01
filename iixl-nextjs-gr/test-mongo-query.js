const { createServerClient } = require("./src/lib/supabase/server");
require("dotenv").config({ path: ".env.local" });

async function run() {
    const supabase = createServerClient();
    const studentId = "non-existent-id";

    console.log("Querying with student_id:", studentId);
    const { data, error } = await supabase
        .from("attempt_events")
        .select("id,student_id")
        .eq("student_id", studentId)
        .limit(5);

    if (error) {
        console.error("Error:", error);
    } else {
        console.log("Results count (should be 0):", data.length);
        if (data.length > 0) {
            console.log("Sample:", data[0]);
        }
    }
}
run();
