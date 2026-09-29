import 'package:flutter_test/flutter_test.dart';
import 'package:payment_approval/features/payments/data/data_sources/recipient_mask.dart';

void main() {
  group('maskRecipientName', () {
    test('keeps the first letter and the initial of the last word', () {
      expect(maskRecipientName('Ahmed Khalil'), 'A•••• K.');
    });

    test('uses the last word for names with more than two words', () {
      expect(maskRecipientName('Sara Al Mansoori'), 'S•••• M.');
    });

    test('masks a single-word name without an initial', () {
      expect(maskRecipientName('Cher'), 'C••••');
    });

    test('ignores extra whitespace', () {
      expect(maskRecipientName('  Leo   Dubois '), 'L•••• D.');
    });

    test('hides a blank name completely', () {
      expect(maskRecipientName(''), '••••');
      expect(maskRecipientName('   '), '••••');
    });

    test('always uses four bullets, so the length of the name stays hidden', () {
      expect(maskRecipientName('Al B'), 'A•••• B.');
      expect(maskRecipientName('Alexandrina Bartholomew'), 'A•••• B.');
    });

    test('keeps a letter written with a combining mark intact', () {
      expect(maskRecipientName('E\u0301mile Zola'), 'E\u0301•••• Z.');
    });

    test('masks names written in non-Latin scripts', () {
      expect(maskRecipientName('أحمد خليل'), 'أ•••• خ.');
    });
  });
}
