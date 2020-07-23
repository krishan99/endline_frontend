import 'dart:math';

import 'package:business_app/business_app/models/queues.dart';
import 'package:business_app/components/cells/slideable_list_cell.dart';
import 'package:business_app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:business_app/business_app/models/user.dart';
import 'package:business_app/components/components.dart';
import 'package:business_app/theme/themes.dart';

import 'package:toast/toast.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AllQueuesInfo>(
      builder: (context, qinfo, _) {
        return FutureBuilder(
            future: qinfo.retrieveServer(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Scaffold(
                      body: Container(
                    alignment: Alignment.center,
                    color: MyStyles.of(context).colors.background2,
                    child: Text(
                      "Loading Queues...",
                      style: MyStyles.of(context).textThemes.bodyText2,
                    ),
                  ));
                default:
                  if (snapshot.hasError)
                    return Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Text('Error: ${snapshot.error.toString()}',
                            style: MyStyles.of(context).textThemes.h2));
                  else
                    return Container(
                      // color: Colors.black,
                      child: Container(
                        child: SlideableList(
                          topSpacing: 55,
                          buttonText: "Add Queue",
                          onPlusTap: () async {
                            try {
                              Navigator.of(context)
                                  .pushNamed("/createQueue", arguments: qinfo);
                            } catch (error) {
                              Toast.show(error.toString(), context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.BOTTOM);
                            }
                          },
                          header: SliverPersistentHeader(
                            pinned: false,
                            delegate: _SliverAppBarDelegate(
                              color: MyStyles.of(context).colors.background2,
                              minExtent: 60,
                              maxExtent: 130,
                            ),
                          ),
                          cells: qinfo.body
                              .map((element) => ChangeNotifierProvider.value(
                                  value: element,
                                  child: Consumer<Queue>(
                                    builder: (context, queue, _) {
                                      return SlideableListCell.queue(
                                          queue: queue,
                                          onDelete: (isActive) async {
                                            try {
                                              await qinfo.deleteQueue(queue.id);
                                              return true;
                                            } catch (error) {
                                              return false;
                                            }
                                          },
                                          onActivate: (isActive) async {
                                            return false;
                                          },
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                "/queue",
                                                arguments: queue);
                                            // return false;
                                          });
                                    },
                                  )))
                              .toList(),
                        ),
                      ),
                    );
              }
            });
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Color color;
  final double minExtent;
  final double maxExtent;

  const _SliverAppBarDelegate({this.color, this.minExtent, this.maxExtent});

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration();

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: Column(children: <Widget>[
        DashboardAppBar(),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 7),
            alignment: Alignment.center,
            child: Text(
              "Dashboard",
              style: MyStyles.of(context).textThemes.h2,
            ),
          ),
        ),
      ]),
    );
  }
}

class DashboardAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MyStyles.of(context)
                                .images
                                .userAccountIcon
                                .image)),
                  )),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Consumer<User>(builder: (context, user, _) {
                    return Text(
                      user.businessName ?? "Company Name",
                      style: MyStyles.of(context).textThemes.h3,
                    );
                  }),
                  Text(
                    "View Account",
                    style: MyStyles.of(context).textThemes.h5,
                  )
                ]),
            Spacer(),
            Consumer<User>(
              builder: (context, user, _) {
                return GestureDetector(
                    onTap: () async {
                      await user.signOut();
                      Navigator.of(context).popAndPushNamed("/home");
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MyStyles.of(context)
                                        .images
                                        .gearIcon
                                        .image)),
                          )),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
