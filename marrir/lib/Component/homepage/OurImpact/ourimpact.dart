import 'package:flutter/material.dart';

class OurImpact extends StatelessWidget {
  const OurImpact({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // FULL-WIDTH BACKGROUND (Who we are)
          Container(
            width: double.infinity,
            height: 330,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF65b2c9),
                  Color(0xFF88C3D5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Marrir',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  // const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      children: [
                        TextSpan(
                          text:
                             'We are a modern technology solution that aims to enhance the RECRUITMENT FIRMS matching activities via our platform Marrir.com. Marrir.com is an all-encompassing ONLINE PLATFORM dedicated to assessing human capabilities and energies. It functions as an effective link between qualified professionals and employers, agency Firms, staffing Offices, and RECRUITMENT FIRMS.'
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Color(0xFF65b2c9),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // OUR IMPACT (2x2 grid, full-width background)
          Container(
            width: double.infinity,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 13),
              child: Column(
                children: [
                  const Text(
                    'Our Impact',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Connecting talent with opportunities worldwide',
                    style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard('500K+', 'Employees'),
                      _buildStatCard('1K+', 'Foreign Employment\nAgencies'),
                      _buildStatCard('1K+', 'Recruitment Firms'),
                      _buildStatCard('3K+', 'Employers'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 218, 244, 253),
            Color.fromARGB(255, 236, 237, 237),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 143, 62, 141),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 102, 102, 102),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
