import 'package:easy_wellness_biz_app/models/working_hours/working_hours.model.dart';

const specialties = [
  'dermatology', // skin, hair, nails, and some cosmetic problems.
  'ophthalmology', // diagnosis and treatment of disorders of the eye
  'dental',
  'pediatrics', // medical care of infants, children, and adolescents
  'spa',
  'psychology',
  'plastic surgery',
  'chiropractic',
];

final defaultWorkingHoursInSecs = WorkingHours.fromJson({
  'monday': [
    {'start': 28800, 'end': 61200}
  ],
  'tuesday': [
    {'start': 28800, 'end': 61200}
  ],
  'wednesday': [
    {'start': 28800, 'end': 61200}
  ],
  'thursday': [
    {'start': 28800, 'end': 61200}
  ],
  'friday': [
    {'start': 28800, 'end': 61200}
  ],
  'saturday': [],
  'sunday': []
});
