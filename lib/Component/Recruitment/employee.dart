import 'package:flutter/material.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Employee Summary Card =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Employee",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Chip(
                    label: Text("This Month"),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 17),

              ///==== bar ===////
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // shadow color
                      spreadRadius: 2, // how much the shadow spreads
                      blurRadius: 8, // softness of the shadow
                      offset: const Offset(0, 2), // x,y offset
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Total Employees",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "0",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "+0%",
                        style: TextStyle(
                            fontSize: 19,
                            color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ===== Employees Section =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Employees",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF65B2C9), // button background
                      foregroundColor: Colors.white, // text and icon color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // rounded corners
                      ),
                    ),
                    child: const Text("+ Add Employee"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ===== Search Bar =====
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search transfers...",
                        hintStyle: TextStyle(color: Colors.grey.shade500), 
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey, // border color
                            width: 1, // border width
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 228, 227,
                                227), // border color when focused
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.filter_list),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== Filters =====
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.start, // align items to the start
                children: [
                  _buildDropdown("Age", ["Age", "Height", "Weight"]),
                  const SizedBox(width: 8), // small gap
                  _buildDropdown("Height", ["Age", "Height", "Weight"]),
                  const SizedBox(width: 8),
                  _buildDropdown("Weight", ["Age", "Height", "Weight"]),
                ],
              ),
              const SizedBox(height: 20),
              // ===== Employee Table Header =====
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF65B2C9), // header background color
                  borderRadius: BorderRadius.circular(10), // rounded corners
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        "Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Passport No.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4), // small gap between header and rows

// ===== Employee Table Rows =====
              Expanded(
                child: ListView.separated(
                  itemCount: 4, // sample rows
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey, // gray line between rows
                    height: 0.7,
                    thickness: 0.2,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      color: Colors.white,
                      child: Row(
                        children: const [
                          Expanded(child: Text("Hanan")),
                          Expanded(child: Text("123456789")),
                          Expanded(child: Text("Email@abc.com")),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for dropdown with border
  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromARGB(255, 207, 207, 207),
        ), // border color
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (newValue) {},
        underline: const SizedBox(), // remove default underline
        isDense: true, // makes dropdown more compact
      ),
    );
  }
}
