import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:marrir/services/Employer/companyInfo_service.dart';
import 'package:marrir/services/Employee/reserves_service.dart'; // Import your reserve service
import 'package:shared_preferences/shared_preferences.dart';

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key});

  @override
  State<CompanyInfoPage> createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  String? selectedYear;
  File? companyLicenseFile;
  File? companyLogoFile;
  bool isLoading = false;
  bool isSubmitting = false;
  bool isLoadingAgreements = false;
  Map<String, dynamic>? companyData;
  List<ReserveBatchItem> agreements = [];
  int currentPage = 0;
  int limit = 10;
  bool hasMoreAgreements = true;

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final ReserveService _reserveService = ReserveService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
    _loadAgreements();
  }

  Future<void> _loadCompanyData() async {
    try {
      setState(() => isLoading = true);
      final data = await CompanyInfoService.getSingleCompanyInfo();
      setState(() => companyData = data);
      _populateFormFields(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadAgreements() async {
    if (isLoadingAgreements || !hasMoreAgreements) return;

    try {
      setState(() => isLoadingAgreements = true);
      final reserves = await _reserveService.getMyIncomingReserves(
        skip: currentPage * limit,
        limit: limit,
      );

      setState(() {
        agreements.addAll(reserves);
        if (reserves.length < limit) {
          hasMoreAgreements = false;
        }
        currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading agreements: $e')),
      );
    } finally {
      setState(() => isLoadingAgreements = false);
    }
  }

  Future<void> _handleReserveAction(int reserveId, String action) async {
    try {
      // You'll need to implement this method in your ReserveService
      // For now, let's just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Reserve $action functionality would be implemented here')),
      );

      // Refresh agreements
      setState(() {
        agreements = [];
        currentPage = 0;
        hasMoreAgreements = true;
      });
      await _loadAgreements();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating reserve: $e')),
      );
    }
  }

  void _populateFormFields(Map<String, dynamic> data) {
    if (data['data'] != null) {
      final companyInfo = data['data'];
      companyNameController.text = companyInfo['company_name'] ?? '';
      emailController.text = companyInfo['alternative_email'] ?? '';
      phoneController.text = companyInfo['alternative_phone'] ?? '';
      tinController.text = companyInfo['ein_tin'] ?? '';
      locationController.text = companyInfo['location'] ?? '';
      selectedYear = companyInfo['year_established']?.toString();
    }
  }

  Future<void> _pickFile(bool isLicense) async {
    try {
      FilePickerResult? result;

      if (isLicense) {
        // For license files (documents)
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );
      } else {
        // For logo files (images) - use image_picker for better reliability
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            companyLogoFile = File(image.path);
          });
          return;
        }
        return;
      }

      if (result?.files.isNotEmpty ?? false) {
        final filePath = result!.files.first.path;
        if (filePath != null) {
          setState(() {
            if (isLicense) {
              companyLicenseFile = File(filePath);
            } else {
              companyLogoFile = File(filePath);
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _submitCompanyInfo() async {
    if (!_validateForm()) return;

    setState(() => isSubmitting = true);

    try {
      // Get user_id from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      final companyData = {
        "company_name": companyNameController.text,
        "alternative_email": emailController.text,
        "alternative_phone": phoneController.text,
        "ein_tin": tinController.text,
        "location": locationController.text,
        "year_established":
            selectedYear != null ? int.parse(selectedYear!) : null,
        "agent_ids": [],
        "recruitment_ids": [],
        "user_id": userId, // <-- add this
      };

      final response = await CompanyInfoService.createUpdateCompanyInfo(
        companyData: companyData,
        companyLicense: companyLicenseFile,
        companyLogo: companyLogoFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Company information saved successfully!')),
      );

      await _loadCompanyData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  bool _validateForm() {
    if (companyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company name is required')),
      );
      return false;
    }

    if (emailController.text.isNotEmpty &&
        !_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading && companyData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==== DASHBOARD STYLE HEADER ====
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color.fromARGB(255, 220, 220, 220)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Company Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'You can add company information below',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ==== FORM FIELDS ====
                  _buildTextField('Company Name', companyNameController,
                      'Enter company name'),
                  const SizedBox(height: 12),
                  _buildTextField('Alternative Email', emailController,
                      'Enter Alternative Email'),
                  const SizedBox(height: 12),
                  _buildTextField('Alternative Phone Number', phoneController,
                      'Enter Alternative Phone number'),
                  const SizedBox(height: 12),

                  // Year and TIN Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Year of Establishment',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedYear,
                              items: List.generate(30, (index) {
                                String year =
                                    (DateTime.now().year - index).toString();
                                return DropdownMenuItem(
                                    value: year, child: Text(year));
                              }),
                              onChanged: (value) =>
                                  setState(() => selectedYear = value),
                              decoration: _inputDecoration('Select year'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EIN or TIN Number',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: tinController,
                              decoration: _inputDecoration('123456789'),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                      'Location', locationController, 'Enter location'),

                  const SizedBox(height: 18),
                  // ==== UPLOAD LICENSE ====
                  _buildUploadContainer(
                    'Upload Company License',
                    'PDF, DOC, JPG, PNG (Max 5MB)',
                    companyLicenseFile,
                    () => _pickFile(true),
                  ),

                  const SizedBox(height: 16),
                  // ==== UPLOAD LOGO ====
                  _buildUploadContainer(
                    'Upload Company Logo',
                    'JPG, PNG (Max 2MB)',
                    companyLogoFile,
                    () => _pickFile(false),
                  ),

                  const SizedBox(height: 20),
                  // ==== SUBMIT BUTTON ====
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submitCompanyInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65b2c9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ==== GRAY LINE DIVIDER ====
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.1,
                    height: 0.8,
                  ),
                  const SizedBox(height: 30),

                  // ==== AGREEMENT TABLE ====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agreement Table',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Refresh agreements
                          setState(() {
                            agreements = [];
                            currentPage = 0;
                            hasMoreAgreements = true;
                          });
                          _loadAgreements();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF65b2c9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  _buildAgreementTable(),

                  if (isLoadingAgreements)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (hasMoreAgreements && !isLoadingAgreements)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _loadAgreements,
                          child: const Text('Load More'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
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
        ),
      ],
    );
  }

  Widget _buildUploadContainer(
      String title, String description, File? file, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 10),
        DottedBorder(
          color: Colors.grey,
          strokeWidth: 1.5,
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          dashPattern: const [2, 1],
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    file != null
                        ? 'File selected: ${file.path.split('/').last}'
                        : 'Tap to select file',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65b2c9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Choose File',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file != null ? 'Ready to upload' : 'No file chosen',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementTable() {
    if (agreements.isEmpty && !isLoadingAgreements) {
      return const Center(
        child: Text(
          'No agreements found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

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
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Reserver Name',
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
                      'Status',
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
                      'Actions',
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
          ...agreements.map((agreement) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      agreement.reserverFullName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(0.2), // Default color for pending
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'PENDING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check,
                              color: Colors.green, size: 20),
                          onPressed: () =>
                              _handleReserveAction(agreement.id, 'accepted'),
                          tooltip: 'Accept',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                          onPressed: () =>
                              _handleReserveAction(agreement.id, 'declined'),
                          tooltip: 'Decline',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    tinController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
