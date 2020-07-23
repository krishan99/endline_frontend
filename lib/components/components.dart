
import 'package:business_app/components/buttons.dart';
import 'package:flutter/material.dart';

import 'package:business_app/theme/themes.dart';
import 'package:business_app/business_app/models/queues.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

//TODO: Have "SilvePersistentHeader" resize to allow smaller button while scrolling down. Using Temp Button rn.
class SlideableList extends StatefulWidget {
  final List<Widget> cells;
  final SliverPersistentHeader header;
  final Function onPlusTap;
  final String buttonText;
  final double topSpacing;

  const SlideableList({Key key,this.onPlusTap, @required this.header, @required this.cells, this.buttonText = "Roar", this.topSpacing = 95}) : super(key: key);

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
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index != 0) {
                          return null;
                        }

                        return Container(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: MyStyles.of(context).colors.background1,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)
                                  ),
                                ),
                                child: Column(
                                  children: 
                                    <Widget>[
                                        SizedBox(
                                          height: 70,
                                        ),
                                    ] +
                                    
                                    widget.cells.map((cell) {
                                      return Container(
                                        padding:EdgeInsets.fromLTRB(30, 10, 30, 10),
                                        child: cell
                                      );
                                    }).toList()
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    ),
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