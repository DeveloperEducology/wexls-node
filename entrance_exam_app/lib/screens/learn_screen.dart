import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _videoLessons = [
    {
      "title": "Introduction to Motion",
      "subject": "Physics",
      "duration": "12:30",
      "thumbnail": "https://img.youtube.com/vi/dyjEw4a-8iI/sddefault.jpg", // Placeholder
      "color": Color(0xFF6C63FF)
    },
    {
      "title": "Number System Tricks",
      "subject": "Math",
      "duration": "08:45",
      "thumbnail": "https://img.youtube.com/vi/F-tL8_A5vjA/sddefault.jpg",
       "color": Color(0xFFFF6584)
    },
    {
      "title": "Photosynthesis Explained",
      "subject": "Biology",
      "duration": "15:20",
      "thumbnail": "https://img.youtube.com/vi/sQK3Yr4Sc_k/sddefault.jpg",
       "color": Color(0xFFFFC069)
    },
    {
      "title": "Parts of Speech",
      "subject": "English",
      "duration": "10:15",
      "thumbnail": "https://img.youtube.com/vi/8_s6b_2F9cE/sddefault.jpg",
       "color": Color(0xFF4DB6AC)
    },
  ];

  final List<Map<String, dynamic>> _studyNotes = [
    {
      "title": "Force and Laws of Motion",
      "subject": "Physics",
      "pages": 12,
      "color": Color(0xFF6C63FF)
    },
    {
      "title": "Algebraic Formulas Cheat Sheet",
      "subject": "Math",
      "pages": 4,
      "color": Color(0xFFFF6584)
    },
    {
      "title": "Periodic Table Trends",
      "subject": "Chemistry",
      "pages": 8,
      "color": Color(0xFF29C7AC)
    },
    {
      "title": "Indian Constitution Summary",
      "subject": "GK",
      "pages": 15,
      "color": Color(0xFF90A4AE)
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Study Material",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0052D4),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0052D4),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: "Video Lessons"),
            Tab(text: "Notes & PDFs"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideoList(),
          _buildNotesList(),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _videoLessons.length,
      itemBuilder: (context, index) {
        final lesson = _videoLessons[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail placeholder
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(lesson['thumbnail']), // Placeholder
                    fit: BoxFit.cover,
                    onError: (e, s) {}, // Fallback handled by color
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: Color(0xFF0052D4), size: 32),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (lesson['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.videocam_outlined, color: lesson['color'], size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson['title'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${lesson['subject']} • ${lesson['duration']} mins",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _studyNotes.length,
      itemBuilder: (context, index) {
        final note = _studyNotes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (note['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description_outlined, color: note['color'], size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${note['subject']}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${note['pages']} Pages • PDF",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.download_rounded, color: Colors.grey),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download started for ${note['title']}")));
                },
              )
            ],
          ),
        );
      },
    );
  }
}
