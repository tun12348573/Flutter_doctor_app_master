import 'package:practice/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import '../doctor/model/booking.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, this.onTap});
  final Booking booking;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.description,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(spacing: 16, runSpacing: 8, children: [
                      Text(context.appointmentDate(booking.date)),
                      Text(context.appointmentTime(booking.time)),
                      Text(
                          context.tr('Status: {status}',
                              {'status': context.tr(booking.status)}),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                    ]),
                    if (onTap != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(context.tr('Review appointment'))),
                  ]),
            )),
      );
}
