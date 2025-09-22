import 'package:flutter/material.dart';

class EditCvPage extends StatefulWidget {
  final Map<String, dynamic> employee; // Pass employee data here
  const EditCvPage({super.key, required this.employee});

  @override
  State<EditCvPage> createState() => _EditCvPageState();
}

class _EditCvPageState extends State<EditCvPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this); // 7 sections
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Curriculum Vitae"),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: download CV function
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF65B2C9),
              foregroundColor: Colors.white,
            ),
            child: const Text("Download CV"),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Passport Scan"),
            Tab(text: "Personal Information"),
            Tab(text: "Address"),
            Tab(text: "Summary"),
            Tab(text: "Educational Data"),
            Tab(text: "Photo and Language"),
            Tab(text: "previous Experience & Documents"),
            Tab(text: "References"),
            Tab(text: "Additional Contact Information"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _passportScanTab(),
          _personalInfoTab(),
          _addressTab(),
          _summaryTab(),
          _educationTab(),
          _photoLanguageTab(),
          _experienceTab(),
          _referencesTab(),
          _additionalContactInformationTab(),
          
        ],
      ),
    );
  }

 Widget _passportScanTab() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        // ==== Title ====
        const Text(
          "Scan your passport",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // ==== Upload Section ====
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // File picker logic
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF65B2C9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // not circle
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(
                  "Choose File",
                  style: TextStyle(color: Colors.white, ),
                  
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "No file chosen",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ElevatedButton(
          onPressed: () {
            // Upload passport logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF65B2C9),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // rectangular
            ),
          ),
          child: const Text(
            "CV Upload Passport",
            style: TextStyle(color: Colors.white, ),
          ),
        ),

        const SizedBox(height: 16),

        // ==== National ID ====
        TextFormField(
  initialValue: widget.employee['national_id'] ?? "",
  decoration: const InputDecoration(
    labelText: "National ID",
    hintText: "123456789",
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.white, 
    
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
  ),
),
const SizedBox(height: 12),


        // ==== Passport Number ====
        TextFormField(
          initialValue: widget.employee['passport_number'] ?? "",
          decoration: const InputDecoration(
            labelText: "Passport Number *",
            hintText: "12345",
            border: OutlineInputBorder(),
            filled: true,
    fillColor: Colors.white, 
    
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
          ),
        ),
        const SizedBox(height: 12),

        // ==== Date Issued ====
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Date Issued",
            hintText: "Select date",
            border: OutlineInputBorder(),
            filled: true,
    fillColor: Colors.white, 
    
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () {
            // date picker
          },
          
        ),
        const SizedBox(height: 12),

        // ==== Place Issued ====
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Place Issued",
            hintText: "cv_id_place_issued_placeholder",
            border: OutlineInputBorder(),
            filled: true,
    fillColor: Colors.white, 
    
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
          ),
        ),
        const SizedBox(height: 12),

        // ==== Date of Expiry ====
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Date of Expiry",
            hintText: "Select date",
            border: OutlineInputBorder(),
            filled: true,
    fillColor: Colors.white, 
    
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () {
            // date picker
          },
        ),
        const SizedBox(height: 12),

        // ==== Nationality Dropdown ====
        DropdownButtonFormField<String>(
          value: "Ethiopia (ETH)",
          items: const [
            DropdownMenuItem(
              value: "Ethiopia (ETH)",
              child: Text("Ethiopia (ETH)"),
            ),
            DropdownMenuItem(
              value: "Kenya (KEN)",
              child: Text("Kenya (KEN)"),
            ),
            DropdownMenuItem(
              value: "Nigeria (NGA)",
              child: Text("Nigeria (NGA)"),
            ),
          ],
          onChanged: (value) {},
          decoration: const InputDecoration(
            labelText: "Nationality *",
            border: OutlineInputBorder(),
            filled: true,
    fillColor: Colors.white, 
    
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
          ),
        ),
        const SizedBox(height: 16),

        // ==== Submit Button ====
        ElevatedButton(
          onPressed: () {
            // Submit passport info
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF65B2C9),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // rectangular
            ),
          ),
          child: const Text(
            "CV Submit Passport Info",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}


  Widget _personalInfoTab() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        // Amharic Full Name
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Amharic Full Name",
            hintText: "ሙሉ ስም",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Arabic Full Name
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Arabic Full Name",
            hintText: "الاسم الكامل",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // English Full Name
        TextFormField(
          decoration: const InputDecoration(
            labelText: "English Full Name",
            hintText: "Full Name",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Sex Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Sex",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),

        // Email
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Email",
            hintText: "example@email.com",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Phone Number (with flag)
        TextFormField(
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Phone Number",
            hintText: "+251912345678",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("🇪🇹"), // Ethiopian flag
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Height
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Height (cm)",
            hintText: "170",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Weight
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Weight (kg)",
            hintText: "60",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Marital Status Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Marital Status",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          items: const [
            DropdownMenuItem(value: "Single", child: Text("Single")),
            DropdownMenuItem(value: "Married", child: Text("Married")),
            DropdownMenuItem(value: "Divorced", child: Text("Divorced")),
            DropdownMenuItem(value: "Separated", child: Text("Separated")),
            DropdownMenuItem(value: "Widowed", child: Text("Widowed")),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),

        // Place of Birth (with Country Dropdown later)
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Place of Birth",
            hintText: "Addis Ababa",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Date of Birth
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Date of Birth",
            hintText: "YYYY-MM-DD",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          onTap: () {
            // showDatePicker logic
          },
        ),
        const SizedBox(height: 12),

        // Religion
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Religion",
            hintText: "Christian / Muslim / Other",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF65B2C9),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              // submit logic
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white, )),
          ),
        ),
      ],
    ),
  );
}


  Widget _addressTab() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        // Country Dropdown
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Country",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          items: const [
            DropdownMenuItem(value: "Ethiopia", child: Text("Ethiopia")),
            DropdownMenuItem(value: "Kenya", child: Text("Kenya")),
            DropdownMenuItem(value: "Sudan", child: Text("Sudan")),
            DropdownMenuItem(value: "USA", child: Text("USA")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),

        // Region
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Region",
            hintText: "Addis Ababa",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // City
        TextFormField(
          decoration: const InputDecoration(
            labelText: "City",
            hintText: "Addis Ababa",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Street
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Street",
            hintText: "Street Name",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Street 2
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Street 2",
            hintText: "Optional",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Street 3
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Street 3",
            hintText: "Optional",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Zip Code
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Zip Code",
            hintText: "1000",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // House Number
        TextFormField(
          decoration: const InputDecoration(
            labelText: "House Number",
            hintText: "123",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // PO-Box
        TextFormField(
          decoration: const InputDecoration(
            labelText: "P.O. Box",
            hintText: "4567",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF65B2C9),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              // submit address logic
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white, )),
          ),
        ),
      ],
    ),
  );
}


  Widget _summaryTab() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
      children: [
        // Summary
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Summary",
            hintText: "Write a short professional summary...",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        // Salary with Currency Dropdown
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Expected Salary",
                  hintText: "5000",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Currency",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                items: const [
                  DropdownMenuItem(value: "ETB", child: Text("ETB")),
                  DropdownMenuItem(value: "USD", child: Text("USD")),
                  DropdownMenuItem(value: "EUR", child: Text("EUR")),
                  DropdownMenuItem(value: "GBP", child: Text("GBP")),
                ],
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Skills
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Skill One",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Skill Two",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Skill Three",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Skill Four",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Skill Five",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 12),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Skill Six",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF65B2C9),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              // Submit summary logic
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white, )),
          ),
        ),
      ],
    ),
  );
}

 Widget _educationTab() {
  // Track graduate selection
  bool isGraduate = true;

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // ===== Graduate / Non Graduate Toggle =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Graduate"),
                  selected: isGraduate,
                  onSelected: (val) => setState(() => isGraduate = true),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Non-Graduate"),
                  selected: !isGraduate,
                  onSelected: (val) => setState(() => isGraduate = false),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===== Form =====
            if (isGraduate) ...[
              // Graduate Form
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Highest Level of Education",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                items: const [
                  DropdownMenuItem(value: "BSc", child: Text("BSc")),
                  DropdownMenuItem(value: "MSc", child: Text("MSc")),
                  DropdownMenuItem(value: "PhD", child: Text("PhD")),
                ],
                onChanged: (val) {},
              ),
            ] else ...[
              // Non-Graduate Form
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Highest Level of Education",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                items: const [
                  DropdownMenuItem(value: "Primary", child: Text("Primary")),
                  DropdownMenuItem(value: "Secondary", child: Text("Secondary")),
                  DropdownMenuItem(value: "Vocational", child: Text("Vocational")),
                  DropdownMenuItem(value: "Some College Course", child: Text("Some College Course")),
                  DropdownMenuItem(value: "Diploma", child: Text("Diploma")),
                ],
                onChanged: (val) {},
              ),
            ],

            const SizedBox(height: 12),

            // Institution Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Institution Name",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Country
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),

            // City
            TextFormField(
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Grade
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Grade",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Occupation Field Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Occupation Field",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              items: const [
                DropdownMenuItem(
                    value: "Healthcare and Medicine",
                    child: Text("Healthcare and Medicine")),
                DropdownMenuItem(
                    value: "Information Technology",
                    child: Text("Information Technology")),
                DropdownMenuItem(value: "Engineering", child: Text("Engineering")),
                DropdownMenuItem(value: "Education", child: Text("Education")),
                DropdownMenuItem(
                    value: "Finance and Accounting",
                    child: Text("Finance and Accounting")),
                DropdownMenuItem(
                    value: "Art and Entertainment",
                    child: Text("Art and Entertainment")),
                DropdownMenuItem(
                    value: "Business and Management",
                    child: Text("Business and Management")),
                DropdownMenuItem(
                    value: "Law and Public Policy",
                    child: Text("Law and Public Policy")),
                DropdownMenuItem(value: "Home Framer", child: Text("Home Framer")),
                DropdownMenuItem(
                    value: "Construction and Skilled Trade",
                    child: Text("Construction and Skilled Trade")),
                DropdownMenuItem(
                    value: "Hospitality and Tourism",
                    child: Text("Hospitality and Tourism")),
                DropdownMenuItem(
                    value: "Sales and Marketing",
                    child: Text("Sales and Marketing")),
                DropdownMenuItem(
                    value: "Agricultural and Env. Service",
                    child: Text("Agricultural and Env. Service")),
                DropdownMenuItem(value: "Household", child: Text("Household")),
                DropdownMenuItem(
                    value: "Transportation and Logistics",
                    child: Text("Transportation and Logistics")),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 12),

            // Occupation Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Occupation",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              items: const [
                DropdownMenuItem(
                    value: "Civil Engineering",
                    child: Text("Civil Engineering")),
                DropdownMenuItem(
                    value: "Mechanical Engineering",
                    child: Text("Mechanical Engineering")),
                DropdownMenuItem(
                    value: "Electrical Engineering",
                    child: Text("Electrical Engineering")),
                DropdownMenuItem(
                    value: "Aerospace Engineering",
                    child: Text("Aerospace Engineering")),
                DropdownMenuItem(
                    value: "Chemical Engineering",
                    child: Text("Chemical Engineering")),
              ],
              onChanged: (val) {},
            ),
            const SizedBox(height: 20),

            // ===== Submit Button =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF65B2C9),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Submit graduate/non-graduate logic
                },
                child: const Text("Submit", style: TextStyle(color: Colors.white, )),
              ),
            ),
          ],
        ),
      );
    },
  );
}


 Widget _photoLanguageTab() {
  const Color primaryColor = Color(0xFF8EC6D6);
  const Color textColor = Color(0xFF111111);
  const Color borderColor = Color(0xFFD1D1D6);

  final List<String> languageLevels = [
    "none",
    "basic",
    "intermediate",
    "fluent"
  ];

  String? englishLevel;
  String? amharicLevel;
  String? arabicLevel;

  return StatefulBuilder(
    builder: (context, setState) {
      Widget buildUploadBox({
        required IconData icon,
        required String title,
      }) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: primaryColor, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Choose File",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      Widget buildDropdownField(
        String label,
        String? selectedValue,
        ValueChanged<String?> onChanged,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                hintText: "Select Level",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
              items: languageLevels
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              ' Photo and Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            // Upload boxes
            buildUploadBox(
              icon: Icons.photo_camera_outlined,
              title: "Upload Head Photo",
            ),
            const SizedBox(height: 16),
            buildUploadBox(
              icon: Icons.person_outline,
              title: "Upload Full Body Photo",
            ),
            const SizedBox(height: 16),
            buildUploadBox(
              icon: Icons.videocam_outlined,
              title: "Upload Introductory Video",
            ),

            const SizedBox(height: 24),

            // Language dropdowns
            buildDropdownField(
              'English',
              englishLevel,
              (value) => setState(() => englishLevel = value),
            ),
            const SizedBox(height: 12),
            buildDropdownField(
              'Amharic',
              amharicLevel,
              (value) => setState(() => amharicLevel = value),
            ),
            const SizedBox(height: 12),
            buildDropdownField(
              'Arabic',
              arabicLevel,
              (value) => setState(() => arabicLevel = value),
            ),

            const SizedBox(height: 20),

            // Submit button (UI only)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}


  Widget _experienceTab() {
  const Color primaryColor = Color(0xFF8EC6D6);
  const Color textColor = Color(0xFF111111);
  const Color borderColor = Color(0xFFD1D1D6);

  final List<String> countries = [
    "Ethiopia",
    "USA",
    "UK",
    "Canada",
    "Germany",
    "UAE",
    "Other",
  ];

  String? selectedCountry;
  String? fromDate;
  String? toDate;
  String? city;
  String? company;
  String? summary;

  return StatefulBuilder(
    builder: (context, setState) {
      Future<void> pickDate(ValueChanged<String> onSelected) async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          onSelected(
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}",
          );
        }
      }

      Widget buildLabel(String text) {
        return Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        );
      }

      Widget buildTextField({
        required String hint,
        String? value,
        int maxLines = 1,
        required ValueChanged<String> onChanged,
      }) {
        return TextFormField(
          initialValue: value,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor, width: 2),
            ),
          ),
        );
      }

      Widget buildDateField({
        required String label,
        String? value,
        required ValueChanged<String> onSelected,
      }) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel(label),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => pickDate(onSelected),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: "Select Date",
                  suffixIcon: const Icon(Icons.calendar_today,
                      color: Colors.grey, size: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                ),
                child: Text(value ?? "",
                    style: TextStyle(
                        color: value == null ? Colors.grey : Colors.black)),
              ),
            ),
          ],
        );
      }

      Widget buildDropdown({
        required String label,
        String? selectedValue,
        required ValueChanged<String?> onChanged,
      }) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel(label),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                hintText: "Select Country",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
              items: countries
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previous Experience and Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            buildDropdown(
              label: "Country",
              selectedValue: selectedCountry,
              onChanged: (val) => setState(() => selectedCountry = val),
            ),
            const SizedBox(height: 16),

            buildLabel("City"),
            const SizedBox(height: 8),
            buildTextField(
              hint: "Enter City",
              value: city,
              onChanged: (val) => setState(() => city = val),
            ),
            const SizedBox(height: 16),

            buildLabel("Company"),
            const SizedBox(height: 8),
            buildTextField(
              hint: "Enter Company Name",
              value: company,
              onChanged: (val) => setState(() => company = val),
            ),
            const SizedBox(height: 16),

            buildDateField(
              label: "From",
              value: fromDate,
              onSelected: (val) => setState(() => fromDate = val),
            ),
            const SizedBox(height: 16),

            buildDateField(
              label: "To",
              value: toDate,
              onSelected: (val) => setState(() => toDate = val),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Experience',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),
            buildLabel("Previous Work"),
            const SizedBox(height: 8),
            buildTextField(
              hint: "Enter summary of the above input",
              value: summary,
              maxLines: 4,
              onChanged: (val) => setState(() => summary = val),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}


 Widget _referencesTab() {
  const Color textColor = Color(0xFF111111);
  const Color buttonColor = Color.fromRGBO(142, 198, 214, 1);
  DateTime? selectedDate;
  String? selectedGender;
  String? selectedCountry;

  return StatefulBuilder(
    builder: (context, setState) {
      Widget _buildLabel(String text) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          );

      Widget _buildTextField({
        required String placeholder,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
        return TextField(
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      Widget _buildPhoneField() {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D1D6)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('+251'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      Widget _buildDatePicker() {
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: selectedDate == null
                    ? "mm/dd/yyyy"
                    : "${selectedDate!.month.toString().padLeft(2, '0')}/"
                        "${selectedDate!.day.toString().padLeft(2, '0')}/"
                        "${selectedDate!.year}",
                suffixIcon: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF8E8E93)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      }

      Widget _buildDropdownField({
        required List<String> options,
        required String hint,
        required ValueChanged<String?> onChanged,
      }) {
        return DropdownButtonFormField<String>(
          value: null,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF8E8E93))),
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'References',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 30),
            _buildLabel('Name'),
            _buildTextField(placeholder: 'Enter Name'),
            const SizedBox(height: 16),
            _buildLabel('Email'),
            _buildTextField(placeholder: 'Enter Email'),
            const SizedBox(height: 16),
            _buildLabel('Phone Number'),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildLabel('Date of Birth'),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildLabel('Select Gender'),
            _buildDropdownField(
              options: ['Male', 'Female', 'Other'],
              hint: 'Select Gender',
              onChanged: (val) => setState(() => selectedGender = val),
            ),
            const SizedBox(height: 16),
            _buildLabel('Country'),
            _buildDropdownField(
              options: ['Ethiopia', 'USA', 'Other'],
              hint: 'Select Country',
              onChanged: (val) => setState(() => selectedCountry = val),
            ),
            const SizedBox(height: 16),
            _buildLabel('City'),
            _buildTextField(placeholder: 'Enter City'),
            const SizedBox(height: 16),
            _buildLabel('Sub City'),
            _buildTextField(placeholder: 'Enter Sub City'),
            const SizedBox(height: 16),
            _buildLabel('Zone'),
            _buildTextField(placeholder: 'Enter Zone'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('P.O. Box'),
                      _buildTextField(placeholder: 'Enter P.O.Box'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('House Number'),
                      _buildTextField(placeholder: 'Enter House Number'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Reference Summary'),
            _buildTextField(placeholder: 'Enter summary', maxLines: 4),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


Widget _additionalContactInformationTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Additional Contact Information',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 30),

        // Facebook
        _buildSocialInput("Facebook", Icons.facebook),

        // X / Twitter
        _buildSocialInput("X / Twitter", Icons.alternate_email),

        // Telegram
        _buildSocialInput("Telegram", Icons.send),

        // TikTok
        _buildSocialInput("TikTok", Icons.music_note),

        // Instagram
        _buildSocialInput("Instagram", Icons.camera_alt),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Submit clicked (UI only)")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(142, 198, 214, 1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

// Helper UI builder
Widget _buildSocialInput(String label, IconData icon) {
  const Color borderColor = Color(0xFFD1D1D6);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111111),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF111111)),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: borderColor),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        keyboardType: TextInputType.url,
      ),
      const SizedBox(height: 16),
    ],
  );
}

}
