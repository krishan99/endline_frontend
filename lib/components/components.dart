
import 'package:business_app/components/buttons.dart';
import 'package:flutter/material.dart';

import 'package:business_app/theme/themes.dart';
import 'package:business_app/business_app/models/queues.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:reorderables/reorderables.dart';

//TODO: Have "SilvePersistentHeader" resize to allow smaller button while scrolling down. Using Temp Button rn.
class SlideableList extends StatefulWidget {
  static const cellPadding = EdgeInsets.fromLTRB(30, 10, 30, 10);
  
  final List<Widget> cells;
  final SliverPersistentHeader header;
  final Function onPlusTap;
  final String buttonText;
  final double topSpacing;
  final bool enableReorder;
  final Function(int, int) onReorder;


  const SlideableList({
    Key key,
    this.onPlusTap,
    @required this.header, 
    @required this.cells, 
    this.buttonText = "Add Person", 
    @required this.enableReorder,
    this.onReorder,
    this.topSpacing = 95}) : super(key: key);

  @override
  _SlideableListState createState() => _SlideableListState();
}

class _SlideableListState extends State<SlideableList> {

  ScrollController _scrollController;
  final double closedSpacing = 50;

  @override
  void initState() {
    super.initState();
    this._scrollController = ScrollController();
    this._scrollController.addListener(() {
      setState(() {
        
      });
    });
  }

  @override
  void dispose() {
    this._scrollController.dispose();
    super.dispose();
  }

  Widget _buildFab() {
    double top = widget.topSpacing + closedSpacing;
    if (_scrollController.hasClients) {
      top -= _scrollController.offset;
    }

    return Positioned(
      top: top < -10 ? -10 : top,
      child: Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: closedSpacing,
              width: MediaQuery.of(context).size.width,
              color: MyStyles.of(context).colors.background2
            ),
            Transform.translate(
              offset: Offset(0, 25),
              child: AccentedActionButton(
                text: widget.buttonText,
                onPressed: widget.onPlusTap,
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var delegate = ReorderableSliverChildBuilderDelegate(
      (context, index) {
        return Column(
          children: [
            Container(
              padding: SlideableList.cellPadding,
              child: widget.cells[index]
            ),
          ],
        );
      },
      childCount: widget.cells.length,
    );

    

                

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          color: MyStyles.of(context).colors.background1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    widget.header,
                    SliverPadding(
                      padding: EdgeInsets.only(top: 70),
                      sliver: ReorderableSliverList(
                        onReorder: widget.onReorder ?? (oldIndex, newIndex) => {},
                        buildDraggableFeedback: (context, constraints, widget) {
                          return Material(
                            color: Colors.transparent,
                            child: Container(
                              constraints: constraints,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: SlideableList.cellPadding,
                                    child: Container(
                                      decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                        boxShadow: [BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 15,
                                          offset: Offset(0, 3), // changes position of shadow
                                        )],
                                      ),
                                    ),
                                  ),
                                  widget,
                                ],
                              )
                            ),
                          );
                        },
                        enabled: widget.enableReorder,
                        delegate: delegate
                      ),
                    )
                  ]
                ),
              ),
              _buildFab()
            ],
          ),
        ),
      ),
    );
  }
}