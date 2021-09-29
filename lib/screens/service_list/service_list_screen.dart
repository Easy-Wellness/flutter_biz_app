import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/models/nearby_service/db_nearby_service.model.dart';
import 'package:easy_wellness_biz_app/notifiers/business_place_id_notifier.dart';
import 'package:easy_wellness_biz_app/utils/remove_diacritics_from_string.dart';
import 'package:easy_wellness_biz_app/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import 'save_service_screen.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({Key? key}) : super(key: key);

  static const String routeName = '/service_list';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, SaveServiceScreen.routeName),
              child: Icon(Icons.add),
            )),
        body: SafeArea(
          child: Consumer<BusinessPlaceIdNotifier>(
            builder: (_, notifier, __) => Body(
              placeId: notifier.businessPlaceId!,
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key, required this.placeId}) : super(key: key);

  final String placeId;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Stream<QuerySnapshot<DbNearbyService>>? queryStream;

  @override
  void initState() {
    queryStream = FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .collection('services')
        .withConverter<DbNearbyService>(
          fromFirestore: (snapshot, _) =>
              DbNearbyService.fromJson(snapshot.data()!),
          toFirestore: (service, _) => service.toJson(),
        )
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            child: SvgPicture.asset(
              'assets/icons/services_icon.svg',
              height: 64,
              width: 64,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the three dots (...) next to a service to view more. Or tap the plus icon at the top right corner to add a new service.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<DbNearbyService>>(
              stream: queryStream,
              builder: (_, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text('Something went wrong 😞'));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                return SearchableServiceListView(services: snapshot.data!.docs);
              },
            ),
          )
        ],
      ),
    );
  }
}

class SearchableServiceListView extends StatefulWidget {
  const SearchableServiceListView({
    Key? key,
    required this.services,
  }) : super(key: key);

  final List<QueryDocumentSnapshot<DbNearbyService>> services;

  @override
  _SearchableServiceListViewState createState() =>
      _SearchableServiceListViewState();
}

class _SearchableServiceListViewState extends State<SearchableServiceListView> {
  final fsbController = FloatingSearchBarController();
  List<QueryDocumentSnapshot<DbNearbyService>>? servicesToShow;

  @override
  void initState() {
    servicesToShow = widget.services;
    super.initState();
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
            "Search by service's name ...",
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
      hint: "Search by service's name ...",
      onQueryChanged: (query) {
        final cleanQuery = removeDiacriticsFromString(query);
        if (cleanQuery.isEmpty)
          return setState(() => servicesToShow = widget.services);
        if (cleanQuery.isNotEmpty)
          setState(() => servicesToShow = widget.services
              .where((snapshot) =>
                  removeDiacriticsFromString(snapshot.data().serviceName.trim())
                      .contains(
                    RegExp(
                      r'' + cleanQuery,
                      caseSensitive: false,
                      unicode: true,
                    ),
                  ))
              .toList());
      },
      body: widget.services.isEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Center(
                child: Text(
                  "Your business has no services, start creating one by tapping the ➕ icon at the top right corner of the screen.",
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : servicesToShow!.isEmpty
              ? const Center(child: Text('No results found 🥺'))
              : Scrollbar(
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: servicesToShow!.length,
                    itemBuilder: (_, idx) {
                      final service = servicesToShow![idx].data();
                      return ListTile(
                        key: ValueKey<String>(servicesToShow![idx].id),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(
                          service.serviceName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: service.rating,
                                  itemCount: 5,
                                  itemSize: 10,
                                  itemBuilder: (_, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(
                                    ' (${service.rating == 0 ? 'No rating' : service.rating})'),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: SvgPicture.asset(
                                            'assets/icons/specialty_${service.specialty.snakeCase}_icon.svg'),
                                      ),
                                    ),
                                  ),
                                  TextSpan(text: service.specialty.headerCase),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<MoreOption>(
                          icon: const Icon(Icons.more_horiz),
                          offset: const Offset(0, 40),
                          onSelected: (option) {
                            switch (option) {
                              case MoreOption.edit:
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SaveServiceScreen(
                                      serviceId: servicesToShow![idx].id,
                                      initialData: service,
                                    ),
                                  ),
                                );
                                break;
                              case MoreOption.seeReviews:
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: MoreOption.edit,
                              child: Text('View & Edit'),
                            ),
                            PopupMenuItem(
                              value: MoreOption.seeReviews,
                              child: Text('See all reviews'),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(thickness: 1),
                  ),
                ),
    );
  }

  @override
  void didUpdateWidget(covariant SearchableServiceListView oldWidget) {
    servicesToShow = widget.services;
    super.didUpdateWidget(oldWidget);
  }
}

enum MoreOption { edit, seeReviews }
