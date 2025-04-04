import 'package:cjmshimlaparent/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/parser.dart' as html_parser;

class AssignmentDetalis extends StatefulWidget {
  final String title;
  final String descripation;

  const AssignmentDetalis(
      {super.key, required this.title, required this.descripation});

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
          'Assignment Detalis',
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
                        height: 50.sp,
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
}
