import 'package:easy_wellness_biz_app/widgets/weekly_schedule_settings/weekly_schedule.model.dart';

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

const defaultWorkingHoursInSecs = WeeklySchedule(
  monday: [defaultWorkingTimeInterval],
  tuesday: [defaultWorkingTimeInterval],
  wednesday: [defaultWorkingTimeInterval],
  thursday: [defaultWorkingTimeInterval],
  friday: [defaultWorkingTimeInterval],
  saturday: [],
  sunday: [],
);

const defaultWorkingTimeInterval = TimeIntervalInSecs(start: 28800, end: 61200);
