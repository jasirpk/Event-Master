import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithDivider(title: 'Privacy Policy'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Event Master, an event management application for clients to hand over their events to registered companies. This app collects the following information from clients to provide the best possible service:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '1. Email\n2. Phone Number\n3. Location',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Features of Event Master:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '• Chatbot for communication with entrepreneurs\n• Event templates for easy form filling\n• Notes and instant meetings\n• Media sharing\n• Company ratings\n• Favorites\n• Search queries\n• Authentication with Google and email/password',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'All company data displayed in this application is validated through the developer. Your data will be stored securely and will not be shared with any third parties. Payments are handled directly between you and the companies, and this application does not include any payment features.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'For more information, please read our full Privacy Policy:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                // ignore: deprecated_member_use
                launch(
                    'https://www.termsfeed.com/live/b1913076-1c66-4784-95a5-c19456373139');
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.024,
                  letterSpacing: 1,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Us:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'For any inquiries, please contact us at jasijasu959@gmail.com.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
