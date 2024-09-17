import 'dart:developer';
import 'dart:io';
import 'PrescriptionScreen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/Button/BlackButton.dart';
import '../../widget/PageHeaderWithBackButton.dart';

class QRScanScreen extends StatefulWidget {

  const QRScanScreen({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 20.h),
            child: PageHeaderWithBackButton(
              title: 'QR scan',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
            height: 360.h,
            child: _buildQrView(context),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(30.w, 30.h, 30.w, 20.h),
            child: Text(
              result != null
                  ? 'Prescription QR code scanned successfully.'
                  : 'Please ask the patient to present their prescription QR code.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: Color(0xFF0A0909),
              ),
            ),
          ),
          if (result != null)
            Container(
                margin: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 20.h),
                child:  BlackButton(
                text: 'Go!',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PrescriptionScreen(prescriptionId: '$result',isArchive: false,),
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = 280.w;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Color(0xFF35C2C1),
        borderRadius: 12.r,
        borderLength: 32.w,
        borderWidth: 8.w,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
