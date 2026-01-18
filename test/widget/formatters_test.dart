import 'package:flutter_test/flutter_test.dart';
import 'package:transfort_app/core/utils/formatters.dart';

void main() {
  group('Formatters Tests', () {
    group('maskMobileNumber', () {
      test('masks 10-digit mobile number showing last 4 digits', () {
        final result = Formatters.maskMobileNumber('9876543210');
        expect(result, '******3210');
      });

      test('masks mobile number with custom visible digits', () {
        final result = Formatters.maskMobileNumber('9876543210', visibleDigits: 2);
        expect(result, '********10');
      });

      test('returns original number if shorter than visible digits', () {
        final result = Formatters.maskMobileNumber('123', visibleDigits: 4);
        expect(result, '123');
      });

      test('handles empty string', () {
        final result = Formatters.maskMobileNumber('');
        expect(result, '');
      });

      test('removes spaces before masking', () {
        final result = Formatters.maskMobileNumber('98 76 54 32 10');
        expect(result, '******3210');
      });

      test('masks entire number when visibleDigits is 0', () {
        final result = Formatters.maskMobileNumber('9876543210', visibleDigits: 0);
        expect(result, '**********');
      });
    });

    group('formatMobileNumber', () {
      test('formats mobile number with country code', () {
        final result = Formatters.formatMobileNumber('9876543210', '+91');
        expect(result, '+91 9876543210');
      });
    });

    group('formatCurrency', () {
      test('formats amount in INR', () {
        final result = Formatters.formatCurrency(499.0);
        expect(result, '₹499');
      });

      test('formats large amount', () {
        final result = Formatters.formatCurrency(123456.0);
        expect(result, '₹1,23,456');
      });
    });
  });
}
