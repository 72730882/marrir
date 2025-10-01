import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'package:marrir/Component/Language/language_provider.dart'; // Import your LanguageProvider
import 'package:provider/provider.dart';

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key});

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  String? year;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? licenseFile;
  File? logoFile;

  final picker = ImagePicker();

  File? agreementFile;

  Future<void> pickAgreementFile() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        agreementFile = File(picked.path);
      });
      await uploadAgreement();
    }
  }

  Future<void> uploadAgreement() async {
    try {
      if (agreementFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a file first.")),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final dealerId =
          prefs.getString("user_id") ?? ""; // using logged-in user's id

      if (token.isEmpty || dealerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login required before uploading.")),
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${ApiService.baseUrl}/api/v1/company_info/assign-agent-recruitment'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['dealer_id'] = dealerId;
      request.files.add(await http.MultipartFile.fromPath(
        'document',
        agreementFile!.path,
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Agreement uploaded successfully.")),
        );
        setState(() {
          agreementFile = null;
        });
      } else {
        final resBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $resBody")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading: $e")),
      );
    }
  }

  Future<void> pickFile(bool isLicense) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isLicense) {
          licenseFile = File(picked.path);
        } else {
          logoFile = File(picked.path);
        }
      });
    }
  }

  Future<void> submitForm() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token") ?? "";
      final userId = prefs.getString("user_id") ?? "";
      final email = prefs.getString("email") ?? "";

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No token found, please login again.")),
        );
        return;
      }

      // Make sure year is int
      final intYear = int.tryParse(year ?? '') ?? 2023;

      // Correct JSON structure
      final companyData = {
        "user_id": prefs.getString("user_id") ?? "", // <--- add this
        "company_name": companyNameController.text,
        "alternative_email": emailController.text,
        "alternative_phone": phoneController.text,
        "location": locationController.text,
        "year_established": intYear,
        "ein_tin": tinController.text,
      };

      final result = await ApiService.createOrUpdateCompanyInfo(
        token: token,
        fields: companyData,
        licenseFile: licenseFile,
        logoFile: logoFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company info updated")),
      );

      print("Response: $result");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== HEADER ====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('company_information'),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        lang.t('add_company_info_desc'),
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // ==== FORM FIELDS ====
            _buildTextField(
              lang.t('company_name1'), // label
              companyNameController,
              lang.t('enter_company_name'), // placeholder
            ),
            const SizedBox(height: 12),
            _buildTextField(
              lang.t('alternative_email'),
              emailController,
              lang.t('enter_alternative_email'),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              lang.t('alternative_phone_number'),
              phoneController,
              lang.t('enter_alternative_phone_number'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('year_of_establishment'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      DropdownButtonFormField<String>(
                        value: year,
                        items: List.generate(10, (index) {
                          String yr = (2023 - index).toString();
                          return DropdownMenuItem(value: yr, child: Text(yr));
                        }),
                        onChanged: (value) => setState(() => year = value),
                        decoration: _dropdownDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    lang.t('ein_or_tin_number_of_company'), // label
                    tinController,
                    lang.t('enter_ein_or_tin'), // placeholder
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            _buildTextField(
              lang.t('location'), // Label
              locationController,
              lang.t('enter_location'), // Placeholder
            ),

            const SizedBox(height: 18),
// ==== UPLOAD LICENSE ====
            _buildUploadContainer(
              lang.t('upload_company_license'), // Title
              lang.t('tap_to_upload_license'), // Subtitle
              true,
              licenseFile,
            ),

            const SizedBox(height: 16),
// ==== UPLOAD LOGO ====
            _buildUploadContainer(
              lang.t('upload_company_logo'), // Title
              lang.t('tap_to_upload_logo'), // Subtitle
              false,
              logoFile,
            ),

            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 300,
                height: 48,
                child: ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65b2c9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(lang.t('submit'),
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // ==== GRAY LINE DIVIDER ====
            const Divider(
              color: Colors.grey,
              thickness: 0.1, // you can adjust thickness
              height: 0.8, // height of the divider widget
            ),
            const SizedBox(height: 30),
            // ==== AGREEMENT TABLE ====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.t('agreement_table'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                ElevatedButton(
                  onPressed: pickAgreementFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65b2c9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    lang.t('add_agreement'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            _buildAgreementTable(),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      hintText: '2025',
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 0.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 0.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 0.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 0.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 155, 154, 154), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 0.8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        )
      ],
    );
  }

  Widget _buildUploadContainer(
      String title, String hint, bool isLicense, File? file) {
    final lang = Provider.of<LanguageProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DottedBorder(
          color: Colors.grey,
          strokeWidth: 1.5,
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          dashPattern: const [2, 1],
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (file != null)
                  Image.file(file, height: 60)
                else
                  const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
                const SizedBox(height: 10),
                Text(hint),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => pickFile(isLicense),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 238, 233, 233),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(lang.t('upload'),
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementTable() {
    final lang = Provider.of<LanguageProvider>(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==== TABLE HEADER ====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF65b2c9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      lang.t('reserve_name'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      lang.t('status'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ==== TABLE ROWS ====
          Column(
            children: List.generate(5, (index) {
              bool isActive = index % 2 == 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Hanan N',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.2)
                            : const Color.fromARGB(255, 245, 221, 12)
                                .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Pending',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isActive ? Colors.green[800] : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
