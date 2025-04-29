import 'package:cjmshimlaparent/UI/Assignment/view_assignments.dart';
import 'package:cjmshimlaparent/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';

class AssignmentDetalis extends StatefulWidget {
  final String title;
  final String descripation;
  final String date;
  final String attach;

  const AssignmentDetalis(
      {super.key, required this.title, required this.descripation, required this.date, required this.attach});

  @override
  State<AssignmentDetalis> createState() => _AssignmentDetalisState();
}

class _AssignmentDetalisState extends State<AssignmentDetalis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Home Work Detalis',
          style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600),
        ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width* 0.95,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.sp)),
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.title}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.date.toString())),

                        style: GoogleFonts.montserrat(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(
                        height: 20.sp,
                      ),
                      Text(
                        '${html_parser.parse(widget.descripation ?? 'N/A').body?.text ?? ''}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500),
                      ),


                      SizedBox(
                        height: 20.sp,
                      ),
                      if (widget.attach.toString()!='null')


                        Center(
                          child: SizedBox(
                            width: 150.sp,
                            child: _buildButton(
                              text: 'View',
                              color: AppColors.secondary,
                              onTap: () async {
                                FileOpener.openFile(widget.attach.toString());
                              },
                            ),
                          ),
                        ),


                      SizedBox(
                        height: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50.sp,
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildButton(
      {required String text,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: MediaQuery.of(context).size.width*0.85,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 8.sp),
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attachment,color: Colors.white,),
                SizedBox(width: 10.sp,),
                Text(
                  text.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }

}
