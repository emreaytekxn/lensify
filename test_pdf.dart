import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  final pdf = pw.Document();
  // Is PdfSecurity available?
  final security = PdfSecurity(userPassword: '123', ownerPassword: '123');
  // How to apply? 
}
