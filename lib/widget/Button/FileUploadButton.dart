import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadButton extends StatefulWidget {
  String? errorText;
  final ValueChanged<PlatformFile?> onFileSelected;

  FileUploadButton({
    Key? key,
    this.errorText,
    required this.onFileSelected,
  }) : super(key: key);

  @override
  _FileUploadButtonState createState() => _FileUploadButtonState();
}

class _FileUploadButtonState extends State<FileUploadButton> {
  Color _buttonColor = Color(0xFF8391A1);
  bool _isUploading = false;
  bool _isUploaded = false;

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile? _selectedFile = result.files.first;

      setState(() {
        _isUploading = true;
        _isUploaded = false;
        widget.errorText = null;
      });

      try {
        await Future.delayed(Duration(seconds: 2));
        widget.onFileSelected(_selectedFile);
        setState(() {
          _buttonColor = Color(0xFF35C2C1);
          _isUploading = false;
          _isUploaded = true;
          widget.errorText = null;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
          _isUploaded = false;
          _buttonColor = Color(0xFF8391A1);
          widget.onFileSelected(null);
        });
      }
    } else {
      setState(() {
        _isUploading = false;
        _isUploaded = false;
        _buttonColor = Color(0xFF8391A1);
        widget.onFileSelected(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFDADADA)),
            borderRadius: BorderRadius.circular(12.r),
            color: Color(0xFFF7F8F9),
          ),
          child: InkWell(
            onTap: _isUploading ? null : _pickAndUploadFile,
            child: Container(
              padding: EdgeInsets.fromLTRB(10.w, 16.h, 10.w, 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: SvgPicture.asset(
                      'assets/svgs/upload_duotone_line.svg',
                      color: _isUploading || _isUploaded ? _buttonColor : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _isUploading
                        ? 'Uploading...'
                        : _isUploaded
                        ? 'File Uploaded'
                        : 'Upload your file',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      height: 1.3,
                      color: _isUploading || _isUploaded ? _buttonColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(left: 10.w, top: 5.h),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                height: 1.3,
                color: Color(0xFF821131),
              ),
            ),
          ),
      ],
    );
  }
}
