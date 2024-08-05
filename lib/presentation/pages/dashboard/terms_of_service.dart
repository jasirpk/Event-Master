import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Introduction'),
              _buildSectionContent(
                  'Welcome to Event Master, an event management application developed by an individual developer, Jasir. By using Event Master, you agree to comply with and be bound by the following terms and conditions. If you do not agree to these terms, please do not use our application.'),
              _buildSectionTitle('Developer Information'),
              _buildSectionContent(
                  'Event Master is developed and maintained by Jasir. For any inquiries, please contact us at jasijasu959@gmail.com.'),
              _buildSectionTitle('Application Purpose'),
              _buildSectionContent(
                  'Event Master is designed to help clients manage their events by allowing them to choose event management companies registered through the Admin Event Pro application. Clients can hand over their events based on their preferred companies.'),
              _buildSectionTitle('Data Collection and Usage'),
              _buildSectionContent(
                  'We collect the following information from clients:\n\n• Email\n• Phone number\n• Location\n\nThis data is collected to provide a better understanding of our clients\' needs and to facilitate communication with event management companies. Your data will not be shared with third-party services and will be stored securely.'),
              _buildSectionTitle('Authentication'),
              _buildSectionContent(
                  'Event Master uses Google Sign-In and email and password authentication for user authentication.'),
              _buildSectionTitle('Features'),
              _buildSectionContent(
                  'Event Master includes the following features:\n\n• Chatbot for communication with entrepreneurs\n• Event templates for easy form filling\n• Notes for instant meetings\n• Media sharing\n• Company rating system\n• Favorites for companies\n• Search query functionality'),
              _buildSectionTitle('Data Validation'),
              _buildSectionContent(
                  'All listed companies are validated through the developer to ensure the accuracy and reliability of the information provided.'),
              _buildSectionTitle('Security'),
              _buildSectionContent(
                  'Your data is stored securely, and we take appropriate measures to protect it. However, it is your responsibility to use the features of this application safely and not misuse them.'),
              _buildSectionTitle('No Payment Features'),
              _buildSectionContent(
                  'Event Master does not include any payment features. Payments are discussed and handled directly between the client and the event management company.'),
              _buildSectionTitle('User Responsibilities'),
              _buildSectionContent(
                  'Users are required to use the features of this application responsibly. Misuse of any feature is strictly prohibited.'),
              _buildSectionTitle('Acceptance of Terms'),
              _buildSectionContent(
                  'By using Event Master, you agree to these terms of service. Only users who accept these terms are authorized to use this application.'),
              _buildSectionTitle('Modifications to Terms'),
              _buildSectionContent(
                  'We reserve the right to modify these terms at any time. Any changes will be posted on this page, and your continued use of Event Master constitutes your acceptance of the modified terms.'),
              _buildSectionTitle('Contact Us'),
              _buildSectionContent(
                  'If you have any questions or concerns about these terms, please contact us at jasijasu959@gmail.com.'),
              _buildSectionContent('Effective Date: 08 - 03 - 2024'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}
