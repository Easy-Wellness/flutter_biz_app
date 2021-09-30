import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/screens/set_place_id_app_state/set_place_id_app_state_screen.dart';
import 'package:easy_wellness_biz_app/utils/navigate_to_root_screen.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/widgets/custom_bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'change_scheduling_policy_screen.dart';
import 'edit_business_info_screen.dart';

class SettingListScreen extends StatelessWidget {
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Consumer<BusinessPlaceIdNotifier>(
        builder: (_, notifier, child) => Container(
          width: double.maxFinite,
          child: TextButtonTheme(
            data: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black87,
                alignment: Alignment.centerLeft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShortBusinessInfo(placeId: notifier.businessPlaceId),
                if (child != null) child,
              ],
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(
                  context, EditBusinessInfoScreen.routeName),
              icon: Icon(Icons.store_outlined),
              label: Text('Edit Business Info'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(
                  context, ChangeSchedulingPolicyScreen.routeName),
              icon: Icon(Icons.book_online_outlined),
              label: Text('Change default scheduling policy'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(
                  context, SetPlaceIdAppStateScreen.routeName),
              icon: Icon(Icons.dvr_outlined),
              label: Text('View your other business place'),
            ),
            const SizedBox(height: 40),
            const Divider(indent: 10, endIndent: 10, thickness: 1),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Permanently delete this business place?'),
                  content: Text(
                      'After you delete a business, you will lose access to all of its assets (bookings, services, chats, etc.). This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final docId = Provider.of<BusinessPlaceIdNotifier>(
                                context,
                                listen: false)
                            .businessPlaceId;
                        await FirebaseFirestore.instance
                            .collection('places')
                            .doc(docId)
                            .delete();
                        navigateToRootScreen(
                            context, RootScreen.setPlaceIdAppStateScreen);
                        showCustomSnackBar(
                            context, 'Business is successfully deleted');
                        Provider.of<BusinessPlaceIdNotifier>(context,
                                listen: false)
                            .businessPlaceId = null;
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ),
              ),
              icon: Icon(Icons.domain_disabled_outlined),
              label: Text('Permanently delete this business place'),
              style:
                  TextButton.styleFrom(primary: Theme.of(context).errorColor),
            ),
            const Divider(indent: 10, endIndent: 10, thickness: 1),
            TextButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.logout_outlined),
              label: Text('Sign Out'),
              style:
                  TextButton.styleFrom(primary: Theme.of(context).errorColor),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class ShortBusinessInfo extends StatefulWidget {
  const ShortBusinessInfo({Key? key, required this.placeId}) : super(key: key);

  final String? placeId;

  @override
  _ShortBusinessInfoState createState() => _ShortBusinessInfoState();
}

class _ShortBusinessInfoState extends State<ShortBusinessInfo> {
  Future<DocumentSnapshot<DbPlace>>? docSnapshot;

  @override
  void initState() {
    super.initState();
    if (widget.placeId == null) return;
    docSnapshot = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .withConverter<DbPlace>(
          fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
          toFirestore: (place, _) => place.toJson(),
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<DocumentSnapshot<DbPlace>>(
        future: docSnapshot,
        builder: (_, snapshot) {
          if (snapshot.hasError) return const Text('Something went wrong 😞');
          if (!snapshot.hasData) return const LinearProgressIndicator();
          final place = snapshot.data!.data()!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  place.name,
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text(
                  place.address,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
