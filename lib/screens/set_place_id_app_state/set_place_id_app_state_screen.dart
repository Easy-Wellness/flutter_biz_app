import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/place/db_place.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/utils/navigate_to_root_screen.dart';
import 'package:easy_wellness_biz_app/utils/remove_diacritics_from_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'create_business_place_screen.dart';

class SetPlaceIdAppStateScreen extends StatelessWidget {
  static const String routeName = '/set_place_id_app_state';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(child: Body()),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(
                context, CreateBusinessPlaceScreen.routeName),
            child: Icon(Icons.add_business_outlined),
          ),
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final querySnapshot = FirebaseFirestore.instance
      .collection('places')
      .where(
        'owner_id',
        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
      )
      .orderBy('name')
      .withConverter<DbPlace>(
        fromFirestore: (snapshot, _) => DbPlace.fromJson(snapshot.data()!),
        toFirestore: (place, _) => place.toJson(),
      )
      .get();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            child: SvgPicture.asset(
              'assets/icons/microsoft_bookings_icon.svg',
              height: 64,
              width: 64,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose your business place',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 16),
          Text('Each place has its own booking calendar'),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<QuerySnapshot<DbPlace>>(
              future: querySnapshot,
              builder: (_, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text('Something went wrong 😞'));
                if (!snapshot.hasData)
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                return SearchablePlaceListView(places: snapshot.data!.docs);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchablePlaceListView extends StatefulWidget {
  const SearchablePlaceListView({
    Key? key,
    required this.places,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbPlace>> places;

  @override
  _SearchablePlaceListViewState createState() =>
      _SearchablePlaceListViewState();
}

class _SearchablePlaceListViewState extends State<SearchablePlaceListView> {
  final fsbController = FloatingSearchBarController();
  List<QueryDocumentSnapshot<DbPlace>>? placesToShow;

  @override
  void initState() {
    super.initState();
    placesToShow = widget.places;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchAppBar(
      controller: fsbController,
      elevation: 4,
      automaticallyImplyBackButton: false,
      automaticallyImplyDrawerHamburger: false,
      textInputType: TextInputType.streetAddress,
      transitionDuration: const Duration(seconds: 0),
      implicitDuration: const Duration(seconds: 0),
      title: TextButton(
        onPressed: () => fsbController.open(),
        child: SizedBox(
          width: 300,
          child: Text(
            'Search by address (district 1 or quan 1) ...',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: const Color(0x99000000),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      hint: 'Search by address (district 1 or quan 1) ...',
      onQueryChanged: (query) {
        final cleanQuery = query;
        if (cleanQuery.isEmpty)
          return setState(() => placesToShow = widget.places);
        if (cleanQuery.isNotEmpty)
          setState(() => placesToShow = widget.places
              .where((snapshot) =>
                  removeDiacriticsFromString(snapshot.data().address.trim())
                      .contains(
                    RegExp(
                      r'' + removeDiacriticsFromString(cleanQuery),
                      caseSensitive: false,
                      unicode: true,
                    ),
                  ))
              .toList());
      },
      body: widget.places.isEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Center(
                child: Text(
                  "You have no business places, start creating one by clicking the ➕ icon at the top right corner of the screen.",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : placesToShow!.isEmpty
              ? const Center(child: Text('No results found 🥺'))
              : Scrollbar(
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: placesToShow!.length,
                    itemBuilder: (_, idx) {
                      final place = placesToShow![idx].data();
                      return ListTile(
                        key: ValueKey<String>(placesToShow![idx].id),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          height: 30,
                          width: 30,
                          child: Center(
                            child: Text(
                              place.name.substring(0, 2).toUpperCase(),
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                          ),
                        ),
                        title: Text(place.name),
                        subtitle: Text(place.address),
                        trailing: OutlinedButton(
                          onPressed: () {
                            Provider.of<BusinessPlaceIdNotifier>(context,
                                    listen: false)
                                .businessPlaceId = placesToShow![idx].id;
                            navigateToRootScreen(
                                context, RootScreen.settingListScreen);
                          },
                          child: const Text('View'),
                          style:
                              OutlinedButton.styleFrom(primary: Colors.black54),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(thickness: 1),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    fsbController.dispose();
  }
}
