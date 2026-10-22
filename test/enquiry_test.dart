import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/enquiry.dart';

void main() {
  group('EnquiryRequest', () {
    test('serializes to json matching backend expectation', () {
      const enquiry = EnquiryRequest(
        name: 'Suganesh Flavio',
        email: 'name@example.com',
        category: 'General Inquiry',
        message: 'I would like to know more about the courses.',
      );

      final json = enquiry.toJson();

      expect(json, {
        'name': 'Suganesh Flavio',
        'email': 'name@example.com',
        'category': 'General Inquiry',
        'message': 'I would like to know more about the courses.',
      });
    });
  });
}
