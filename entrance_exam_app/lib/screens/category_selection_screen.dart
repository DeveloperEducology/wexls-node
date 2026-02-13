import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../models/data_models.dart';
import 'home_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<ExamCategory> _categories = [];
  Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _supabaseService.getExamCategories();
      final profile = await _supabaseService.getUserProfile();
      
      List<String> currentSelected = [];
      if (profile != null && profile['exam_categories'] != null) {
         currentSelected = List<String>.from(profile['exam_categories']);
      }

      setState(() {
        _categories = data.map((e) => ExamCategory.fromJson(e)).toList();
        _selectedIds = currentSelected.toSet();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load categories")));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSelection() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select at least one category")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _supabaseService.updateUserCategories(_selectedIds.toList());
      if(mounted) {
         // If we are already signed in and just updating, navigating to Home refreshes everything.
         // Using pushReplacement to reset stack or just pop if we want to go back?
         // Simpler to just restart Home to reflect changes.
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save selection: $e")));
    } finally {
      if(mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Select Your Goals", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text("Choose the exams you are preparing for:", style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
               ),
               Expanded(
                 child: GridView.builder(
                   padding: EdgeInsets.all(16),
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                     childAspectRatio: 1.5,
                   ),
                   itemCount: _categories.length,
                   itemBuilder: (context, index) {
                     final cat = _categories[index];
                     final isSelected = _selectedIds.contains(cat.id);
                     
                     IconData iconData = Icons.menu_book;
                     if (cat.iconName == 'science') iconData = Icons.science;
                     else if (cat.iconName == 'calculate') iconData = Icons.calculate;
                     else if (cat.iconName == 'biotech') iconData = Icons.biotech;
                     else if (cat.iconName == 'eco') iconData = Icons.eco;
                     else if (cat.iconName == 'public') iconData = Icons.public;
                     
                     return GestureDetector(
                       onTap: () {
                         setState(() {
                           if (isSelected) _selectedIds.remove(cat.id);
                           else _selectedIds.add(cat.id);
                         });
                       },
                       child: Container(
                         padding: EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: isSelected ? Color(0xFF0052D4) : Colors.white,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: isSelected ? Color(0xFF0052D4) : Colors.grey.withOpacity(0.2)),
                           boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2)),
                           ],
                         ),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(iconData, color: isSelected ? Colors.white : Color(0xFF0052D4), size: 28),
                             SizedBox(height: 8),
                             Text(
                               cat.displayName,
                               textAlign: TextAlign.center,
                               style: GoogleFonts.poppins(
                                 color: isSelected ? Colors.white : Colors.black87,
                                 fontWeight: FontWeight.w600,
                                 fontSize: 16,
                               ),
                             ),
                             if (cat.subText.isNotEmpty) ...[
                               SizedBox(height: 4),
                               Text(
                                 cat.subText,
                                 textAlign: TextAlign.center,
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                                 style: GoogleFonts.poppins(
                                   color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey,
                                   fontSize: 10,
                                 ),
                               ),
                             ]
                           ],
                         ),
                       ),
                     );
                   },
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: SizedBox(
                   width: double.infinity,
                   height: 50,
                   child: ElevatedButton(
                     onPressed: _isSaving ? null : _saveSelection,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Color(0xFF0052D4),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     child: _isSaving 
                       ? CircularProgressIndicator(color: Colors.white) 
                       : Text("Continue", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                   ),
                 ),
               )
            ],
          ),
    );
  }
}
